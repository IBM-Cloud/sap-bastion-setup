output "HOSTNAME" {
  value =  length(module.vsi) > 0 ? module.vsi[0].HOSTNAME : ""
}

output "FLOATING_IP" {
  value = length(module.vsi) > 0 ? module.vsi[0].FLOATING-IP : ""
}

output "PRIVATE_IP" {
  value = length(module.vsi) > 0 ? module.vsi[0].PRIVATE-IP : ""
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

output "SUBNET" {
  value = [ for i in range(length(var.SUBNETS)) :
           var.SUBNETS[i]
  ]
}

output "ATR_INSTANCE_NAME" {
  description = "Activity Tracker instance name."
  value       = var.ATR_NAME
}
