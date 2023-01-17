variable "automation_account_name" {
  type        = string
  description = "name of automation account"
}

variable "resource_group_name" {
  type        = string
  description = "name of resource group"
}

variable "location" {
  type        = string
  description = "azure location"
}

variable "tags" {
  type        = map(string)
  description = "tags"
}

variable "azure_credentials" {
  type = object({
    name        = optional(string)
    description = optional(string)
    username    = optional(string)
    password    = optional(string)
  })
  description = "service principal credentials which have access to query azure ad, these will be added to the automation account as credentials"
  default     = null
}

variable "dynatrace_credentials" {
  type = object({
    name        = optional(string)
    description = optional(string)
    username    = optional(string)
    password    = optional(string)
  })
  description = "dynatrace api token credentials with access to post data to dynatrace api, these will be added to the automation account as credentials"
  default     = null
}

variable "log_verbose" {
  type        = bool
  default     = false
  description = "choose whether the runbook is to log verbose"
}

variable "log_progress" {
  type        = bool
  default     = false
  description = "choose whether the runbook is to log progress"
}

variable "runbook_parameters" {
  type = object({
    applicationids      = string # created as a string rather than list(string) due to a bug.
    azuretenant         = string
    azurecredential     = string
    dynatracetenant     = string
    dynatracecredential = string
    entitytype          = string
    entityname          = string
    project             = string
  })
  description = "parameters to pass to runbook"
}