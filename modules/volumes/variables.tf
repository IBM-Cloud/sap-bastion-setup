variable "ZONE" {
  type        = string
  description = "Cloud Zone"
}

variable "HOSTNAME" {
  type        = string
  description = "VSI Hostname"
}

variable "VOL_PROFILE" {
  type        = string
  description = "Volume Profile"
  default     = "general-purpose"
}

variable "VOL1" {
  type        = string
  description = "Volume 1 Size"
  default     = "100"
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "Resource Group"
}

