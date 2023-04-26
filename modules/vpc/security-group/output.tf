
output "securitygroup" {
  value = one(ibm_is_security_group.securitygroup[*].id)
}

output "SECURITY_GROUP_NAME" {
  value = ibm_is_security_group.securitygroup.name
}
