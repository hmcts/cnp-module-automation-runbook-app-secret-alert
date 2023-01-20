locals {
  runbook_parameters = {
    applicationids      = join(",", var.runbook_parameters.applicationids)
    azuretenant         = var.runbook_parameters.azuretenant
    azurecredential     = var.azure_credentials == null ? var.runbook_parameters.azurecredential : azurerm_automation_credential.azure_credentials[0].name
    dynatracetenant     = var.runbook_parameters.dynatracetenant
    dynatracecredential = var.dynatrace_credentials == null ? var.runbook_parameters.dynatracecredential : azurerm_automation_credential.dynatrace_credentials[0].name
    entitytype          = var.runbook_parameters.entitytype
    entityname          = var.runbook_parameters.entityname
    project             = upper(var.runbook_parameters.project)
  }
}

resource "azurerm_automation_schedule" "schedule" {
  name                    = "WeeklySchedule"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  frequency               = "Week"
  interval                = 1
  week_days               = ["Sunday"]
  description             = "Sunday Weekly Schedule."
}

resource "azurerm_automation_job_schedule" "job_schedule" {
  automation_account_name = var.automation_account_name
  resource_group_name     = var.resource_group_name
  schedule_name           = azurerm_automation_schedule.schedule.name
  runbook_name            = azurerm_automation_runbook.get_appregistrationexpiry.name
  parameters              = local.runbook_parameters
}