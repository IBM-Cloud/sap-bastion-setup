variable "sm_name" {
  type        = string
  description = "A unique alias for your service instance."
}

variable "REGION" {
  type        = string
  description = "The region the instance should be provisioned in."
}

variable "RESOURCE_GROUP_ID" {
  type        = string
  description = "Name for imported Secret Manager certificate."
}

variable "SM_PLAN" {
  type        = string
  default = "7713c3a8-3be8-4a9a-81bb-ee822fcaac3d"
  description = "The pricing plan that you want to use, provided as a plan ID. Use 869c191a-3c2a-4faf-98be-18d48f95ba1f for trial or 7713c3a8-3be8-4a9a-81bb-ee822fcaac3d for standard."
}

variable "IBMCLOUD_API_KEY" {
	description	= "IBM Cloud API key"
	sensitive	= true
		validation {
			condition     = length(var.IBMCLOUD_API_KEY) > 43 #&& substr(var.IBMCLOUD_API_KEY, 14, 15) == "-"
			error_message = "The IBMCLOUD_API_KEY value must be a valid IBM Cloud API key."
		}
}

