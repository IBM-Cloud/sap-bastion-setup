locals {
  ovpn_data = templatefile("${path.module}/templates/client_config.ovpn.tpl", {
    "hostname"    = var.vpn_hostname,
    "ca"          = var.ca,
    "client_key"  = var.client_key,
    "client_cert" = var.client_cert
  })
}

resource "null_resource" "copy_ovpn" {

  connection {
    type        = "ssh"
    user        = "root"
    host        = var.bastion_ip
    private_key = var.private_key
  }

  provisioner "file" {
    content      = local.ovpn_data
    destination = "/root/OpenVPN.ovpn"
  }
}