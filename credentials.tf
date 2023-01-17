resource "azurerm_automation_credential" "azure_credentials" {
  count                   = var.azure_credentials != null ? 1 : 0
  name                    = var.azure_credentials.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  username                = var.azure_credentials.username
  password                = var.azure_credentials.password
  description             = var.azure_credentials.description
}

resource "azurerm_automation_credential" "dynatrace_credentials" {
  count                   = var.dynatrace_credentials != null ? 1 : 0
  name                    = var.dynatrace_credentials.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  username                = var.dynatrace_credentials.username
  password                = var.dynatrace_credentials.password
  description             = var.dynatrace_credentials.description
}