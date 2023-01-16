resource "azurerm_automation_runbook" "get_appregistrationexpiry" {
  name                    = "Get-AppRegistrationExpiry"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = data.azurerm_automation_account.automation_account.name
  log_verbose             = var.log_verbose
  log_progress            = var.log_progress
  description             = "This runbook checks for any App Registration Client Secrets due to expire, then creates a Dynatrace alert."
  runbook_type            = "PowerShell"
  content                 = file("${path.module}/Get-AppRegistrationExpiry.ps1")
  tags                    = var.tags
}