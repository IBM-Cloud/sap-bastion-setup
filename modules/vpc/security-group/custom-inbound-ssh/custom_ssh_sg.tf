data "ibm_is_vpc" "vpc" {
  name = var.VPC
}

data "ibm_resource_group" "group" {
  name = var.RESOURCE_GROUP
}

# This is the custom SG applied to the bastion instance as coustom source ip/cidr
resource "ibm_is_security_group" "sg-ssh" {
  name           = "bastion-sg-custom-ssh-${var.HOSTNAME}"
  vpc            = data.ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_security_group_rule" "custom_inbound_ssh_access" {
  for_each  = toset(var.SSH-SOURCE-IP-CIDR-ACCESS)
  group     = ibm_is_security_group.sg-ssh.id
  direction = "inbound"
  remote    = each.value
  tcp {
    port_min = 22
    port_max = 22
  }
}
