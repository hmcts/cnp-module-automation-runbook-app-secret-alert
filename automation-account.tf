data "azurerm_automation_account" "automation_account" {
  name                = var.automation_account_name
  resource_group_name = var.resource_group_name
}