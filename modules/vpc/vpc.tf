data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

resource "ibm_is_vpc" "vpc" {
  name		= var.VPC
  resource_group = data.ibm_resource_group.group.id
}
