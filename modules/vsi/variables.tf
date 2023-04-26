variable "ZONE" {
  type        = string
  description = "Cloud Zone"
}

variable "VPC" {
  type        = string
  description = "VPC name"
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "Resource Group"
}

variable "SUBNET" {
  type        = string
  description = "Subnet name"
}

variable "HOSTNAME" {
  type        = string
  description = "VSI Hostname"
}

variable "PROFILE" {
  type        = string
  description = "VSI Profile"
}

variable "IMAGE" {
  type        = string
  description = "VSI OS Image"
}

variable "SSH_KEYS" {
  type        = list(string)
  description = "List of SSH Keys to access the VSI"
}

variable "sg-ssh" {
  type        = string
  description = "sg-ssh"
}


variable "sg-sch-ssh" {
  type        = string
  description = "sg-sch-ssh"
}

variable "securitygroup" {
  type        = string
  description = "securitygroup"
}

variable "VOLUMES_LIST" {
  type        = list(string)
  description = "List of volumes"
}
