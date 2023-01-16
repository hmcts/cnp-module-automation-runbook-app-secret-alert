## Dynatrace Module

This Module will create a PowerShell runbook which checks for App Registration Client Secrets that are expiring within 21 days.

```terraform
module "app_secret_expiry" {
  source = "git::https://github.com/hmcts/cnp-module-automation-runbook-app-secret-alert"

  automation_account_name = "sds-aa"
  resource_group_name     = "sds-rg
  location                = "uksouth"
  credentials             = [
                                {
                                    name        = "azure-ad-credential"
                                    description = "a credential for azure ad access"
                                    username    = "00000-000000-00000" # app registration id which has access to query azure ad.
                                    password    = data.azurerm_key_vault_secret.password.value # app registration client secret.
                                }
                            ]

  tags                    = var.common_tags
}

```

## Requirements   

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.38.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_automation_credential.credential](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_credential) | resource |
| [azurerm_automation_runbook.new_dynatrace_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_account.automation_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/automation_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automation_account_name"></a> [automation\_account\_name](#input\_automation\_account\_name) | name of automation account | `string` | n/a | yes |
| <a name="input_automation_credentials"></a> [automation\_credentials](#input\_automation\_credentials) | service principal credentials which have access to query azure ad | `list(map(string))` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | azure location | `string` | n/a | yes |
| <a name="input_log_progress"></a> [log\_progress](#input\_log\_progress) | choose whether the runbook is to log progress | `bool` | `false` | no |
| <a name="input_log_verbose"></a> [log\_verbose](#input\_log\_verbose) | choose whether the runbook is to log verbose | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | name of resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | tags | `map(string)` | n/a | yes |

## Outputs

N/A