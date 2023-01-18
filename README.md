## App Registration Alert Module

This Module will create a PowerShell runbook which checks for App Registration Client Secrets that are expiring within 21 days, if a secret is within 21 days of expiring, the runbook will create a Dynatrace Alert via the [Dynatrace API](https://www.dynatrace.com/support/help/dynatrace-api).

```terraform
module "app_registration_alert" {
  source = "git::https://github.com/hmcts/cnp-module-automation-runbook-app-secret-alert"

  automation_account_name = "automation-account"
  resource_group_name     = "resource-group"
  location                = "uk south"

  azure_credentials = {
    description = "azure spn with azure ad access"
    name        = "ad-credential"
    password    = azuread_application_password.password.value
    username    = azuread_appplication.app.application_id
  }

  dynatrace_credentials = {
    description = "dynatrace api token"
    name        = "dynatrace-credential"
    password    = azurerm_key_vault_secret.dynatrace_token.value
    username    = "dynatrace"
  }

  runbook_parameters = {
    applicationids      = ["7ea3fb21-3aca-4186-a6aa-c64b26743b21", "c9d9a8da-7cd7-4873-9786-64568642330f"]
    azuretenant         = "82c5bbd6-ba5b-4f7f-b70c-a576318b363b"
    azurecredential     = "ad-credential"
    dynatracetenant     = "xyz1234"
    dynatracecredential = "dynatrace-credential"
    entitytype          = "AZURE_TENANT"
    entityname          = "HMCTS-Tenant-Name"
    project             = "VH"
  }

  tags = {
    "environment" = "dev"
    "repository"  = "cnp-module-automation-runbook-app-secret-alert"
  }
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
| [azurerm_automation_credential.azure_credentials](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_credential) | resource |
| [azurerm_automation_credential.dynatrace_credentials](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_credential) | resource |
| [azurerm_automation_job_schedule.job_schedule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule) | resource |
| [azurerm_automation_runbook.get_appregistrationexpiry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_schedule.schedule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automation_account_name"></a> [automation\_account\_name](#input\_automation\_account\_name) | name of automation account | `string` | n/a | yes |
| <a name="input_azure_credentials"></a> [azure\_credentials](#input\_azure\_credentials) | service principal credentials which have access to query azure ad, these will be added to the automation account as credentials | <pre>object({<br>    name        = optional(string)<br>    description = optional(string)<br>    username    = optional(string)<br>    password    = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_dynatrace_credentials"></a> [dynatrace\_credentials](#input\_dynatrace\_credentials) | dynatrace api token credentials with access to post data to dynatrace api, these will be added to the automation account as credentials | <pre>object({<br>    name        = optional(string)<br>    description = optional(string)<br>    username    = optional(string)<br>    password    = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | azure location | `string` | n/a | yes |
| <a name="input_log_progress"></a> [log\_progress](#input\_log\_progress) | choose whether the runbook is to log progress | `bool` | `false` | no |
| <a name="input_log_verbose"></a> [log\_verbose](#input\_log\_verbose) | choose whether the runbook is to log verbose | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | name of resource group | `string` | n/a | yes |
| <a name="input_runbook_parameters"></a> [runbook\_parameters](#input\_runbook\_parameters) | parameters to pass to runbook.<br>    ------------------------------------------------------------ <br>    applicationids      = app ids to check for expiring secrets<br>    azuretenant         = azure tenant id<br>    azurecrdential      = automation account credential which has access to azure ad<br>    dynatracetenant     = dynatrace tenant name<br>    dynatracecredential = automation account credential which has access to dynatrace api<br>    entitytype          = dynatrace entity type<br>    entityname          = dynatrace entity name <br>    project             = name of project | <pre>object({<br>    applicationids      = list(string)<br>    azuretenant         = string<br>    azurecredential     = string<br>    dynatracetenant     = string<br>    dynatracecredential = string<br>    entitytype          = string<br>    entityname          = string<br>    project             = string<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | tags | `map(string)` | n/a | yes |

## Outputs

No outputs.
