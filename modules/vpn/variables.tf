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

variable "VPN_PREFIX" {
  type        = string
  description = "The prefix used for the VPN configuration."
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
