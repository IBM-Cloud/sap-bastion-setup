variable "ca" {
  description = "CA used to create imported secret"
  type        = string
  sensitive = false
}

variable "client_key" {
  description = "Client key created from server cert"
  type        = string
  sensitive = false
}

variable "client_cert" {
  description = "Client certificate created from server cert"
  type        = string
  sensitive = false
}

variable "vpn_hostname" {
  description = "Publicly accessable hostname of the VPN server"
  type        = string
}

variable "bastion_ip" {
	type		= string
	description	= "The ip address of the bastion."
}

variable "private_key" {
  type        = string
  sensitive   = true
  description = "id_rsa private key content in OpenSSH format (Sensitive value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the deployment."
}
