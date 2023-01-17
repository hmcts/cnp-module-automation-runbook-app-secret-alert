########################################################################################
<#
.DESCRIPTION
    Name:           Get-AppRegistrationExpiry.ps1

    Description:    Checks Azure AD App Registration's for expiring client secrets;
                    Creates Dyanatrace alert if client secret is within 21 Days of expiring.

    Author:         James Ferrari

    Version:        1.0

    Date:           16/01/2023

    Requires:       N/A

.CHANGE LOG
    Version 1.0     16/01/2023    Initial Release
#>
########################################################################################

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $applicationIds,

    [Parameter()]
    [string]
    $azureTenant,

    [Parameter()]
    [string]
    $azureCredential,

    [Parameter()]
    [string]
    $dynatraceTenant,

    [Parameter()]
    [string]
    $dynatraceCredential,

    [Parameter()]
    [string]
    $entityName,

    [Parameter()]
    [string]
    $entityType,

    [Parameter()]
    [string]
    $project
)

###############################################
# Global. #####################################
Import-Module -Name 'Az.Accounts'
Import-Module -Name 'Az.Resources'
Import-Module -Name 'Az.Automation'

$dateTime = (Get-Date)

###############################################
# Authenticate with Azure. ####################
$azureCredentials = Get-AutomationPSCredential -Name $azureCredential
$azureUser        = $azureCredentials.Username 
$azurePass        = $azureCredentials.GetNetworkCredential().Password | ConvertTo-SecureString -AsPlainText
$azCredential     = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $azureUser, $azurePass

Connect-AzAccount -ServicePrincipal -TenantId $azureTenant -Credential $azCredential | Out-Null

###############################################
# Check App Registration Expirys. #############
$applicationIds = $applicationIds.Replace(' ', '') -Split ','

foreach ($id in $applicationIds) {
  $appName = (Get-AzADApplication -Filter "AppId eq '$id'").displayName
  Write-Output "Checking Secret Expiration for App Registration : $appName"

  # Get App Registration Client Secrets.
  $credentials      = (Get-AzADAppCredential -ApplicationId $id)
  $credentialsCount = $credentials.Count
  Write-Output "`tFound $credentialsCount Client Secrets."

  ########################################
  # Check Credentials. ###################
  $counter = 0

  foreach ($cred in $credentials) {

    $expiryDate = (Get-Date $cred.endDateTime)
    $notifyDate = (Get-Date $expiryDate).AddDays(-21)

    if ($dateTime -gt $notifyDate ) {
      $counter++
    }
  }

  ###########################################
  # Create Dynatrace Alert. #################
  if ($counter -gt 0) {
    Write-Output "`tFound $counter Client Secret Due to Expire Soon, Creating Dynatrace Alert..."

    # Get Credentials.
    $dynatraceCredentials = Get-AutomationPSCredential -Name $dynatraceCredential
    $apiToken             = $dynatraceCredentials.GetNetworkCredential().Password

    # Create Headers.
    $requestHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $requestHeaders.Add("Authorization", "API-Token $apiToken")
    $requestHeaders.Add("Content-Type", "application/json")

    # Create Body.
    $requestBody = [PSCustomObject]@{
      "eventType"      = "ERROR_EVENT"
      "title"          = "FH - $project - App Registration Client Secret Expiry $appName"
      "entitySelector" = "type($entityType),entityName.startsWith($entityName)"
      "properties"     = @{
          "Tenant ID"      = "$azureTenant"
          "Application ID" = "$id"
          "Display Name"   = "$appName"
          "Description"    = "App Registration $appName Has $counter Client Secrets Due To Expire Soon."
      }
    } | ConvertTo-Json

    # POST Data to Dynatrace.
    Write-Output "`tCreating Alert in Dynatrace, Please Wait..."
    Write-Output "`n"

    $response = Invoke-RestMethod "https://$dynatraceTenant.live.dynatrace.com/api/v2/events/ingest" -Method 'POST' -Headers $requestHeaders -Body $requestBody
    $response | ConvertTo-Json
  }
  else {
    Write-Output "`tFound 0 Client Secrets That Are Due To Expire Soon."
  }
}