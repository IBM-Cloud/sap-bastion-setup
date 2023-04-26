data "ibm_is_vpc" "vpc" {
  name = var.VPC
}

data "ibm_resource_group" "group" {
  name = var.RESOURCE_GROUP
}

data "local_file" "input" {
  filename = "${path.module}/found.ip.tmpl"
}

# This is the SG applied to the bastion instance as source ip from the Deployment Workspace Schematics Server
resource "ibm_is_security_group" "sg-sch-ssh" {
  name           = "bastion-sg-deployment-sch-ssh-${var.HOSTNAME}"
  vpc            = data.ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_security_group_rule" "inbound-sg-sch-ssh" {
  group     = ibm_is_security_group.sg-sch-ssh.id
  direction = "inbound"
  remote    = chomp(data.local_file.input.content)

  tcp {
    port_min = 22
    port_max = 22
  }
}
