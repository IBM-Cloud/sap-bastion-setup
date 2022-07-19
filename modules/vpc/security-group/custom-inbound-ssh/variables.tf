variable "ZONE" {
  type        = string
  description = "Cloud Zone"
}

variable "RESOURCE_GROUP" {
    type = string
    description = "Resource Group"
}

variable "VPC" {
  type        = string
  description = "VPC name"
}

variable "SUBNET" {
  type        = string
  description = "Subnet name"
}

variable "HOSTNAME" {
  type        = string
  description = "VSI Hostname"
}

variable "SSH-SOURCE-IP-CIDR-ACCESS" {
  type        = list(string)
  description = "List of CIDR/IPs for source SSH access."
}
