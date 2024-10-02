output "VPN_HOSTNAME" {
  value       = ibm_is_vpn_server.vpn_server.hostname
  description = "Hostname of the VPN Server"
}
