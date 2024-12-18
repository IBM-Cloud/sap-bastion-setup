variable "PRIVATE_SSH_KEY" {
  type        = string
  sensitive   = true
  description = "id_rsa private key content in OpenSSH format (Sensitive value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the deployment."
}

variable "SSH_KEYS" {
  type            = list(string)
  description     = "List of SSH Keys UUIDs that are allowed to connect to the VSI via SSH, as root user. Can contain one or more IDs. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys."
  validation {
    condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
    error_message = "At least one SSH KEY is needed to be able to access the VSI."
  }
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "The name of an EXISTING Resource Group for for VPC, subnet, FLOATING IP, security group, activity tracker, VSI and Volume resources. The list of Resource Groups is available here: https://cloud.ibm.com/account/resource-groups"
  default     = "Default"
}

data "ibm_resource_group" "group" {
  name = var.RESOURCE_GROUP
}

variable "REGION" {
  type            = string
  description     = "The cloud region where to deploy the SAP solution. The regions and zones for VPC are listed here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Review supported locations in IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations."
  validation {
    condition     = contains(["eu-de", "eu-gb", "us-south", "us-east", "ca-tor", "au-syd", "jp-osa", "jp-tok", "eu-es", "br-sao"], var.REGION)
    error_message = "The REGION must be one of: eu-de, eu-gb, us-south, us-east, ca-tor, au-syd, jp-osa, jp-tok, eu-es, br-sao."
  }
}

variable "ZONES" {
  type            = list(string)
  description     = "A list with the IBM Cloud zones accessible from the Deployment Server (BASTION Server), where the SAP solutions will be later deployed. Multiple values separated by comma are allowed. ZONE names must be a list of strings. The list should contain at least one zone name and maximum three zone names. Example [\"eu-de-1\", \"eu-de-2\", \"eu-de-3\"]"
  validation {
    condition     = length(var.ZONES) > 0 && length(var.ZONES) <= 3
    error_message = "Number of zones should be higher than 0 or less than or equal to 3"
  }
  validation {
    condition     = alltrue([for zone in var.ZONES : can(regex("^(eu-de|eu-gb|us-south|us-east|ca-tor|au-syd|jp-osa|jp-tok|eu-es|br-sao)-(1|2|3)$", zone))])
    error_message = "The ZONEs are not valid."
  }
}

variable "SUBNETS" {
  type        = list(string)
  description = "A list of subnets to be created or existing ones, corresponding to the IBM Cloud zones selected. Multiple values separated by comma are allowed. SUBNET names must be a list of strings. The list must contain at least one subnet name and maximum three subnet names. Example [\"sn-23000000-01\", \"sn-23000000-02\", \"sn-23000000-03\"]"
  validation {
    condition     = length(var.SUBNETS) > 0 && length(var.SUBNETS) <= 3
    error_message = "Number of subnets should be higher than 0 and less than or equal to 3"
  }
  validation {
    condition     = alltrue([for sub in var.SUBNETS : length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", sub)) > 0])
    error_message = "SUBNETs are not valid."
  }
}

variable "VPC_EXISTS" {
  type            = string
  description     = "Specifies if the VPC, having the provided name, already exists. Allowed values: 'yes' and 'no'.\n If the value 'no' is chosen, a new VPC will be created along with all supplied SUBNETS in the provided ZONES. If the VPC_EXISTS is set to yes, the specified SUBNETS are verified to determine if they exist in the provided VPC; if any of the user-provided SUBNETS do not exist in the existing VPC, those subnets are created using the selected ZONES and SUBNETS."
  validation {
    condition     = var.VPC_EXISTS == "yes" || var.VPC_EXISTS == "no"
    error_message = "The value for this parameter can only be yes or no."
  }
}

variable "VPC" {
  type            = string
  description     = "The name of the EXISTING / NEW VPC. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs"
  validation {
    condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
    error_message = "The VPC name is not valid."
  }
}

variable "ADD_SOURCE_IP_CIDR" {
  type            = string
  description     = "Specifies if a range of IP addresses or CIDR should be added as source INBOUND SSH access to the Deployment Server (BASTION Server). Allowed values: 'yes' and 'no'. Default value: 'no'"
  default         = "no"
  validation {
    condition     = var.ADD_SOURCE_IP_CIDR == "yes" || var.ADD_SOURCE_IP_CIDR == "no"
    error_message = "The value for this parameter can only be yes or no."
  }
}

variable "SSH_SOURCE_IP_CIDR_ACCESS" {
  type            = list(string)
  description     = "The list of CIDR/IPs for source SSH access. Multiple values separated by comma are allowed. The sample default value must be changed with your own CIDR/IPs. Sample input: [ \"10.243.64.0/27\" , \"89.76.89.156\" , \"5.15.114.40\" , \"161.156.167.199\" ]"
  default         = ["192.168.0.1/32"]
  validation {
    condition     = !contains(var.SSH_SOURCE_IP_CIDR_ACCESS, "0.0.0.0/0")
    error_message = "Not allowed source IP."
  }
}

variable "HOSTNAME" {
  type        = string
  description = "Deployment Server (BASTION Server) VSI Hostname. The hostname must have up to 13 characters."
}

variable "PROFILE" {
  type        = string
  description = "Deployment Server (BASTION Server) VSI Profile. The list of profiles is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles."
  default     = "bx2-2x8"
}

variable "IMAGE" {
  type        = string
  description = "Deployment Server (BASTION Server) VSI OS Image. A list of OS images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
  default     = "ibm-redhat-8-8-minimal-amd64-2"
}

variable "VOL1" {
  type        = string
  description = "The size, in GB, of the disk to be attached to the Deployment Server (BASTION Server), for later use as storage for the SAP deployment kits. The mount point for the new volume is: \"/storage\""
  default     = "100"
}

variable "VPN_PREFIX" {
  type        = string
  description = "The prefix to use for the VPN related elements."
  default = ""
  validation {
    condition = var.VPN_CREATE == false || (var.VPN_CREATE == true && (length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPN_PREFIX)) > 0))
    error_message = "VPN prefix must start with a lowercase letter or a digit and can contain lowercase letters, digits, and dashes, but no underscores or leading/trailing dashes."
  }
}

variable "VPN_NETWORK_PORT_NUMBER" {
  type        = number
  default     = 1194
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


variable "SM_PLAN" {
  type        = string
  default = "7713c3a8-3be8-4a9a-81bb-ee822fcaac3d"
  description = "The pricing plan that you want to use for the Secrets Manager instance, provided as a plan ID. Use 869c191a-3c2a-4faf-98be-18d48f95ba1f for trial or 7713c3a8-3be8-4a9a-81bb-ee822fcaac3d for standard."
  validation {
    condition     = var.SM_PLAN == "7713c3a8-3be8-4a9a-81bb-ee822fcaac3d" || var.SM_PLAN == "869c191a-3c2a-4faf-98be-18d48f95ba1f"
    error_message = "The value for this parameter can only be 7713c3a8-3be8-4a9a-81bb-ee822fcaac3d or 869c191a-3c2a-4faf-98be-18d48f95ba1f."
  }
}


variable "VPN_CLIENT_IP_POOL" {
  description = <<-EOD
    Optional variable to specify the CIDR for VPN client IP pool space. This is the IP space that will be
    used by machines connecting with the VPN. You should only need to change this if you have a conflict
    with your local network.
  EOD
  type        = string
  default     = "192.168.8.0/22"
  validation {
    condition     = can(cidrsubnet(var.VPN_CLIENT_IP_POOL, 0, 0)) && var.VPN_CLIENT_IP_POOL != "0.0.0.0/0"
    error_message = "This client IP pool is not allowed or not a valid CIDR."
  }
}

variable "VPN_CREATE" {
  type            = bool
  description     = "Specifies if you want a VPN solution to be added to your bastion setup. If 'yes' a VPN solution will be automatically deployed for you, allowing you access to the private ip addressing space of your VPC."
  default = false
}
variable "DESTROY_BASTION_SERVER_VSI" {
  type        = bool
  description = "For the initial deployment, should remain set to false. After the initial deployment, in case there is a wish to destroy the Deployment Server (BASTION Server) VSI, but preserve the rest of the Cloud resources (VPC, Subnet, Security Group, Activity Tracker), in Schematics, the value must be set to true and then the changes must be applied by pressing the \"Apply plan\" button."
  default     = false
}

data "local_file" "input" {
  filename = "modules/vpc/security-group/sg-sch-ssh/found.ip.tmpl"
}

data "local_file" "sm_guid" {
  filename = "/tmp/.schematics/sm_guid.tmpl"
  depends_on = [module.secretmanager]
  count  = var.VPN_CREATE == true ? 1 : 0
}

locals {
  subnets_zones = zipmap(var.SUBNETS, var.ZONES)
}
