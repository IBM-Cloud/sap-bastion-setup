output "HOSTNAME" {
  value		= module.vsi.HOSTNAME
}

output "FLOATING-IP" {
  value		= module.vsi.FLOATING-IP
}

output "PRIVATE-IP" {
  value		= module.vsi.PRIVATE-IP
}

output "REGION" {
  value		= var.REGION
}

output "ZONE" {
  value		= var.ZONE
}

output "VPC" {
  value		= var.VPC
}

output "SUBNET" {
  value		= var.SUBNET
}

output "SECURITY_GROUP" {
  value		= module.vpc-security-group.SECURITY_GROUP_NAME
}
