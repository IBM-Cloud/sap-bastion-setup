
##############################################################################
# Config to dynamically create bastion host Security Group and rules
#
# Base rules for access to DNS, repos are predefined. Inputs required for
# target SG's bastion host will connect to and the source CIDRs of the servers
# that will connect via the bastion host
##############################################################################

data "ibm_is_vpc" "vpc" {
  name = var.VPC
}

data "ibm_is_subnet" "subnet" {
  name = var.SUBNET
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

# this is the SG applied to the bastion instance
resource "ibm_is_security_group" "securitygroup" {
  name = "bastion-sg-${var.HOSTNAME}"
  lifecycle {
    create_before_destroy = true
  }
  vpc  = data.ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.group.id
}

locals {
  sg_keys = ["direction", "remote", "type", "port_min", "port_max"]

  cidr_schematics_EU = ["158.175.0.0/16", "158.176.0.0/15", "141.125.75.80/28", "161.156.139.192/28", "149.81.103.128/28", "161.156.37.164/27", "141.125.142.102/26", "158.176.111.68/30", "149.81.123.68/27"]
  cidr_schematics_US = ["169.44.0.0/14", "169.60.0.0/14", "169.55.82.140/26", "169.60.69.10/27", "169.62.49.135/27", "169.62.204.36/26"]

  schematics = concat (local.cidr_schematics_EU , local.cidr_schematics_US )

  # base rules for maintenance repo's, DNS
  sg_baserules = [
    ["outbound", "0.0.0.0/0", "all", 53, 53],
    ["outbound", "0.0.0.0/0", "tcp", 80, 80],
    ["outbound", "0.0.0.0/0", "tcp", 443, 443],
    ["outbound", "0.0.0.0/0", "tcp", 8443, 8443],
  ]


  sg_destrules = [
    ["outbound", "0.0.0.0/0", "tcp", 22, 22]
  ]


  #concatenate all sources of rules
  sg_rules = concat(local.sg_destrules, local.sg_baserules)
  sg_mappedrules = [
    for entry in local.sg_rules :
    merge(zipmap(local.sg_keys, entry))
  ]
}


output "list_sg_rules" {
  value = local.sg_mappedrules
}


resource "ibm_is_security_group_rule" "bastion_access" {
  count     = length(local.sg_mappedrules)
  group     = ibm_is_security_group.securitygroup.id
  direction = (local.sg_mappedrules[count.index]).direction
  remote    = (local.sg_mappedrules[count.index]).remote
  dynamic "tcp" {
    for_each = local.sg_mappedrules[count.index].type == "tcp" ? [
      {
        port_max = local.sg_mappedrules[count.index].port_max
        port_min = local.sg_mappedrules[count.index].port_min
      }
    ] : []
    content {
      port_max = tcp.value.port_max
      port_min = tcp.value.port_min

    }
  }
  dynamic "udp" {
    for_each = local.sg_mappedrules[count.index].type == "udp" ? [
      {
        port_max = local.sg_mappedrules[count.index].port_max
        port_min = local.sg_mappedrules[count.index].port_min
      }
    ] : []
    content {
      port_max = udp.value.port_max
      port_min = udp.value.port_min
    }
  }
}


resource "ibm_is_security_group_rule" "inbound_icmp_all" {
  group     = ibm_is_security_group.securitygroup.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  icmp {
    type = 8
  }
}


resource "ibm_is_security_group_rule" "inbound_ssh_schematics" {
  for_each = toset(local.schematics)
  group     = ibm_is_security_group.securitygroup.id
  direction = "inbound"
  remote    = each.value
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "inbound_sg_all" {
  group		= ibm_is_security_group.securitygroup.id
  direction	= "inbound"
  remote	= ibm_is_security_group.securitygroup.id
}
