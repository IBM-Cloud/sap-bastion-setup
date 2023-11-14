output "HOSTNAME" {
  value = length(ibm_is_instance.vsi) > 0 ? ibm_is_instance.vsi.name : ""
}

output "FLOATING-IP" {
  value = length(ibm_is_floating_ip.fip) > 0 ? ibm_is_floating_ip.fip.address : ""
}

output "PRIVATE-IP" {
  value = length(ibm_is_instance.vsi) > 0 ? ibm_is_instance.vsi.primary_network_interface.0.primary_ip.0.address : ""
}
