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
    applicationids      = list(string)
    azuretenant         = string
    azurecredential     = optional(string)
    dynatracetenant     = string
    dynatracecredential = optional(string)
    entitytype          = string
    entityname          = string
    project             = string
  })
  description = <<EOT
    parameters to pass to runbook.
    ------------------------------------------------------------ 
    applicationids      = app ids to check for expiring secrets
    azuretenant         = azure tenant id
    azurecrdential      = automation account credential which has access to azure ad
    dynatracetenant     = dynatrace tenant name
    dynatracecredential = automation account credential which has access to dynatrace api
    entitytype          = dynatrace entity type : information can be found here https://www.dynatrace.com/support/help/dynatrace-api/environment-api/entity-v2/get-all-entity-types
    entityname          = dynatrace entity name 
    project             = name of project
  EOT

  validation {
    condition     = alltrue([for value in var.runbook_parameters.applicationids : can(regex(".......-....-....-....-............", value))])
    error_message = "input format incorrect, value must be a list of GUIDs."
  }

  validation {
    condition     = can(regex(".......-....-....-....-............", var.runbook_parameters.azuretenant))
    error_message = "input format incorrect, value must be in the format of a GUID."
  }
}