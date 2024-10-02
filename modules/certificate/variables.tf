variable "name" {
  type        = string
  description = "Name for imported Secret Manager certificate."
}

variable "resource_group_id" {
  description = "Resource group the secret manager is in."
  type        = string
}

variable "instance_id" {
  type        = string
  description = "Name of the secret manager to import the server certificate."
}

variable "REGION" {
  type        = string
  description = "The region the instance should be provisioned in."
}

