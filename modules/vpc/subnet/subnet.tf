data "ibm_is_vpc" "vpc" {
  name = var.VPC
}

data "ibm_resource_group" "group" {
  name = var.RESOURCE_GROUP
}

resource "random_string" "random_suffix" {
  length  = 10
  special = false
  upper   = false
}


resource "ibm_is_public_gateway" "pg" {
  depends_on     = [random_string.random_suffix]
  name           = "public-gateway-${random_string.random_suffix.result}-${var.HOSTNAME}"
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.ZONE
  resource_group = data.ibm_resource_group.group.id

  timeouts {
    create = "20m"
  }
}

resource "ibm_is_subnet" "subnet" {
  zone                     = var.ZONE
  resource_group           = data.ibm_resource_group.group.id
  name                     = var.SUBNET
  vpc                      = data.ibm_is_vpc.vpc.id
  public_gateway           = ibm_is_public_gateway.pg.id
  total_ipv4_address_count = 256
}
