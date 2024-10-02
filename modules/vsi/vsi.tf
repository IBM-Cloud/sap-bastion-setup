data "ibm_is_vpc" "vpc" {
  name = var.VPC
}

data "ibm_is_security_group" "securitygroup" {
  name = "bastion-sg-${var.HOSTNAME}"
}

data "ibm_is_security_group" "sg-sch-ssh" {
  name = "bastion-sg-deployment-sch-ssh-${var.HOSTNAME}"
}

data "ibm_is_subnet" "subnet" {
  name = var.SUBNET
  vpc = data.ibm_is_vpc.vpc.id
}

data "ibm_is_image" "image" {
  name = var.IMAGE
}

data "ibm_resource_group" "group" {
  name = var.RESOURCE_GROUP
}

resource "ibm_is_instance" "vsi" {
  tags = [ "wes-sap-automation" ]
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.ZONE
  resource_group = data.ibm_resource_group.group.id
  keys           = var.SSH_KEYS
  name           = var.HOSTNAME
  profile        = var.PROFILE
  image          = data.ibm_is_image.image.id

  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnet.id
    security_groups = compact([var.securitygroup, var.sg-ssh, var.sg-sch-ssh])

  }
  volumes = var.VOLUMES_LIST

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

resource "ibm_is_floating_ip" "fip" {
  name           = "${var.HOSTNAME}-fip"
  resource_group = data.ibm_resource_group.group.id
  target         = ibm_is_instance.vsi.primary_network_interface[0].id
}
