variable "ATR_PROVISION" {
  type        = bool
  description = "Activity Tracker : Disable this to not provision Activity Tracker instance."
}

variable "ATR_NAME" {
  description = "Activity tracker Enter the instance name "
  type        = string
}

variable "ATR_PLAN" {
  type        = string
  description = "Activity Tracker: The type of plan the service instance should run under (lite, 7-day, 14-day, or 30-day)"
}

variable "ATR_TAGS" {
  type        = list(string)
  description = "Activity Tracker:  Tags that should be applied to the Activity Tracker instance."
}


variable "REGION" {
  type        = string
  description = "Geographic location of the Activity Tracker  (e.g. us-south, us-east)"
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "ID of the Resource group where the resource has been provisioned."
}