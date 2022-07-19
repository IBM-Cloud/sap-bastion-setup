variable "private_ssh_key" {
  type        = string
  sensitive   = true
  description = "Input id_rsa private key content."
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "SSH Keys ID list to access the VSI"
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the VSI."
	}
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "EXISTING Resource Group for VPC resources."
  default     = "Default"
}

variable "REGION" {
	type		= string
	description	= "Cloud Region"
	validation {
		condition     = contains(["eu-de", "eu-gb", "us-south", "us-east"], var.REGION )
		error_message = "The REGION must be one of: eu-de, eu-gb, us-south, us-east."
	}
}

variable "ZONE" {
	type		= string
	description	= "Cloud Zone"
	validation {
		condition     = length(regexall("^(eu-de|eu-gb|us-south|us-east)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "VPC_EXISTS" {
  type        = string
  description = "Please mention if the chosen VPC exists or not (use 'yes' or 'no').\n If you choose 'no' as an option, a new VPC will be created."
  validation {
    condition     = var.VPC_EXISTS == "yes" || var.VPC_EXISTS == "no"
    error_message = "The value for this parameter can only be yes or no."
  }
}

variable "SUBNET_EXISTS" {
  type        = string
  description = "Please mention if the chosen SUBNET/SECURITY_GROUP exist or not (use 'yes' or 'no').\n If you choose 'no' as an option, a new SUBNET/SECURITY_GROUP with OPEN PORTS will be created in the existing VPC."
  validation {
    condition     = var.SUBNET_EXISTS == "yes" || var.SUBNET_EXISTS == "no"
    error_message = "The value for this parameter can only be yes or no."
  }
}

variable "VPC" {
	type		= string
	description = "The EXISTING / NEW VPC name"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "SUBNET" {
	type		= string
	description = "The EXISTING / NEW Subnet name"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
		error_message = "The SUBNET name is not valid."
	}
}


variable "ADD-SOURCE-IP-CIDR" {
  type        = string
  description = "Please mention if you want to add a range of IPs or CIDR (use 'yes' or 'no').\n If you choose 'yes' as an option,  The IP/s or CIDR will be added as source INBOUND SSH access to the BASTION server."
  default     = "no"
  validation {
    condition     = var.ADD-SOURCE-IP-CIDR == "yes" || var.ADD-SOURCE-IP-CIDR == "no"
    error_message = "The value for this parameter can only be yes or no."
  }
}


variable "SSH-SOURCE-IP-CIDR-ACCESS" {
  type        = list(string)
  description = "Add the list of CIDR/IPs for source SSH access. Cam be multiple values separated by commas. Change the sample default one with your own CIDR/IPs"
  default     = ["192.168.0.1/32"]
  validation {
    condition     = !contains (var.SSH-SOURCE-IP-CIDR-ACCESS, "0.0.0.0/0")
    error_message = "Not allowed source IP."
 }
}

variable "HOSTNAME" {
  type        = string
  description = "VSI Hostname"
}


variable "PROFILE" {
  type        = string
  description = "VSI Profile"
  default     = "bx2-2x8"
}

variable "IMAGE" {
  type        = string
  description = "VSI OS Image"
  default     = "ibm-redhat-8-4-minimal-amd64-3"
}

variable "VOL1" {
  type        = string
  description = "Volume 1 Size"
  default     = "100"
}

data "local_file" "input" {
  filename = "modules/vpc/security-group/sg-sch-ssh/found.ip.tmpl"
}
