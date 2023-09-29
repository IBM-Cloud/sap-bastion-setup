variable "RESOURCE_GROUP" {
  type        = string
  description = "Resource Group"
}

variable "VPC" {
  type        = string
  description = "VPC name"
}

variable "HOSTNAME" {
  type        = string
  description = "VSI Hostname"
}

variable "SSH_SOURCE_IP_CIDR_ACCESS" {
  type        = list(string)
  description = "List of CIDR/IPs for source SSH access."
}
