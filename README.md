## App Registration Alert Module

This Module will create a PowerShell runbook which checks for App Registration Client Secrets that are expiring within 21 days.

```terraform
module "app_registration_alert" {
  source = "../"

  automation_account_name = "automation-account"
  resource_group_name     = "resource-group"
  location                = "uk south"

  azure_credentials = {
    description = "azure spn with azure ad access"
    name        = "service-principal"
    password    = azuread_application_password.password.value
    username    = azuread_appplication.app.application_id
  }

  dynatrace_credentials = {
    description = "dynatrace api token"
    name        = "dynatrace-token"
    password    = azurerm_key_vault_secret.dynatrace_token.value
    username    = "dynatrace"
  }

  runbook_parameters = {
    applicationids      = "000000, 111111"
    azuretenant         = "000000-0000000-000000"
    azurecredential     = "service-prinicpal"
    dynatracetenant     = "xyz1234"
    dynatracecredential = "dynatrace-token"
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
| [azurerm_automation_credential.credential](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_credential) | resource |
| [azurerm_automation_job_schedule.job_schedule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule) | resource |
| [azurerm_automation_runbook.get_appregistrationexpiry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_schedule.schedule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |
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
| <a name="input_runbook_parameters"></a> [runbook\_parameters](#input\_runbook\_parameters) | parameters to pass to runbook | `map(any)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | tags | `map(string)` | n/a | yes |
| <a name="input_runbook_parameters"></a> [runbook\_parameters](#input\_runbook\_parameters) | parameters to pass to runbook | <pre>object({<br>    applicationids      = string # created as a string rather than list(string) due to a bug.<br>    azuretenant         = string<br>    azurecredential     = string<br>    dynatracetenant     = string<br>    dynatracecredential = string<br>    entitytype          = string<br>    entityname          = string<br>    project          = string<br>  })</pre> | n/a | yes |

## Outputs

N/A