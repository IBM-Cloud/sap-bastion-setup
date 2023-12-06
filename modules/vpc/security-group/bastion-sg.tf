
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

data "ibm_resource_group" "group" {
  name = var.RESOURCE_GROUP
}

# this is the SG applied to the bastion instance
resource "ibm_is_security_group" "securitygroup" {
  name = "bastion-sg-${var.HOSTNAME}"
  lifecycle {
    create_before_destroy = true
  }
  vpc            = data.ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.group.id
}

locals {
  sg_keys = ["direction", "remote", "type", "port_min", "port_max"]

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

resource "ibm_is_security_group_rule" "inbound_sg_all" {
  group     = ibm_is_security_group.securitygroup.id
  direction = "inbound"
  remote    = ibm_is_security_group.securitygroup.id
}
