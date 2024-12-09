variable "certificate_crn" {
  description = "Server certificate CRN imported in secrets manager"
  type        = string
}

variable "zone" {
  description = "Zone where VPN will be located"
  type        = string
}

variable "VPN_CLIENT_IP_POOL" {
  description = <<-EOD
    Optional variable to specify the CIDR for VPN client IP pool space. This is the IP space that will be
    used by machines connecting with the VPN. You should only need to change this if you have a conflict
    with your local network.
  EOD
  type        = string
  default     = "192.168.8.0/22"
}

variable "VPN_NETWORK_PORT_NUMBER" {
  type        = number
  default     = 443
  description = "The port number to be used for the VPN solution. (must be between 1 and 65535)"

  validation {
    condition     = var.VPN_NETWORK_PORT_NUMBER >= 1 && var.VPN_NETWORK_PORT_NUMBER <= 65535
    error_message = "The VPN port number must be between 1 and 65535."
  }
}

variable "VPN_NETWORK_PORT_PROTOCOL" {
  type        = string
  default     = "udp"
  description = "The protocol to be used for the VPN solution. (must be either 'tcp' or 'udp')"

  validation {
    condition     = contains(["tcp", "udp"], var.VPN_NETWORK_PORT_PROTOCOL)
    error_message = "The VPN protocol must be either 'tcp' or 'udp'."
  }
}

variable "VPN_PREFIX" {
  type        = string
  description = "The prefix to use for the VPN related elements."
  validation {
    condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPN_PREFIX)) > 0
    error_message = "VPN prefix must start with a lowercase letter or a digit and can contain lowercase letters, digits, and dashes, but no underscores or leading/trailing dashes."
  }
}

variable "resource_group_id" {
  description = "Resource group ID to create VPN in"
  type        = string
}

variable "resource_group_id_bastion" {
  description = "Resource group ID to create VPN in"
  type        = string
}

variable "VPC" {
	type		= string
	description = "The name of an EXISTING VPC. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs."
}

data "ibm_is_vpc" "vpc_data" {
  name = var.VPC
}

variable "SUBNETS" {
	type		= list
	description = "The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets."
}

#### this might be replaces with the data source ibm_is_subnets which will retrieve all the subnets of a VPC
#### to be tested and implemented
data "ibm_is_subnet" "subnet_data" {
  for_each = { for name in var.SUBNETS : name => name }
  name = each.key
  vpc = data.ibm_is_vpc.vpc_data.id
}
