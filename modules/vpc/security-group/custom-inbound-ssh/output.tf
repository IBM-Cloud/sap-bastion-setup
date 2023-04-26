output "sg-ssh" {
  value = one(ibm_is_security_group.sg-ssh[*].id)
}
