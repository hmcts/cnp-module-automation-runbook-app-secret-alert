resource "azurerm_automation_credential" "credential" {
  for_each                = { for cred in var.automation_credentials : cred.name => cred }
  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  automation_account_name = data.azurerm_automation_account.automation_account.name
  username                = each.value.username
  password                = each.value.password
  description             = each.value.description
}