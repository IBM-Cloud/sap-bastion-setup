data "ibm_is_vpc" "exists" {
  name = var.VPC
}

locals {
  filter_subnets_zones = { for obj in data.ibm_is_vpc.exists.subnets : "${obj.name}" => obj.zone }
  subnets_to_create    = { for key, value in var.SUBNET_ZONE : key => value if !contains(keys(local.filter_subnets_zones), key) }
}

output "SUBNETS_WITH_ZONES" {
  value = local.subnets_to_create
}

