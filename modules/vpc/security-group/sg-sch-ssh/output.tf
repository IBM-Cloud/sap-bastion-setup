output "sg-sch-ssh" {
  value = one(ibm_is_security_group.sg-sch-ssh[*].id)
}

output "SCHEMATICS_IP" {
  value = data.local_file.input
}
