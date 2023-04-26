output "HOSTNAME" {
  value = module.vsi.HOSTNAME
}

output "FLOATING-IP" {
  value = module.vsi.FLOATING-IP
}

output "PRIVATE-IP" {
  value = module.vsi.PRIVATE-IP
}

output "REGION" {
  value = var.REGION
}

output "VPC" {
  value = var.VPC
}

output "SECURITY_GROUP" {
  value = module.vpc-security-group.SECURITY_GROUP_NAME
}
