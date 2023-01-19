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
$azureCredentials = Get-AutomationPSCredential -Name $azureCredential -ErrorAction Stop
$azureUser        = $azureCredentials.Username 
$azurePass        = $azureCredentials.GetNetworkCredential().Password | ConvertTo-SecureString -AsPlainText -Force
$azCredential     = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $azureUser, $azurePass

Connect-AzAccount -ServicePrincipal -TenantId $azureTenant -Credential $azCredential -ErrorAction Stop

###############################################
# Check App Registration Expirys. #############
$ids = $applicationIds.Replace(' ', '') -Split ','

foreach ($id in $ids) {

  # Check App Registration Exists.
  $appName = (Get-AzADApplication -Filter "AppId eq '$id'").displayName

  if ($null -eq $appName) {
    Write-Output "`n`nApp Registration $id not found in Azure Tenant $azureTenant"
    Continue
  }
  
  # Check Client Secrets.
  Write-Output "`n`nChecking Secret Expiration for App Registration : $appName"

  $credentials      = (Get-AzADAppCredential -ApplicationId $id)
  $credentialsCount = $credentials.Count

  if ($credentialsCount -eq 0) {
    Write-Output "`tFound $credentialsCount Client Secrets, Continuing..."
    Continue
  }

  # Create Counter.
  "`tFound $credentialsCount Client Secrets, Checking Expiry Dates..."
  
  $counter = 0

  foreach ($cred in $credentials) {
    # Get Expiry Date & Notify Date.
    $expiryDate = (Get-Date $cred.endDateTime)
    $notifyDate = (Get-Date $expiryDate).AddDays(-21)
    
    # Add To Counter if Expiry Date within 3 Weeks.
    if ($dateTime -gt $notifyDate ) {
      $counter++
    }
  }

  ###########################################
  # Create Dynatrace Alert. #################
  if ($counter -gt 0) {
    Write-Output "`tFound $counter Client Secret Due to Expire Soon, Creating Dynatrace Alert..."

    $dynatraceCredentials = Get-AutomationPSCredential -Name $dynatraceCredential -ErrorAction Stop
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

    try {
      # POST Data to Dynatrace.
      Write-Output "`tCreating Alert in Dynatrace, Please Wait..."
      $response = Invoke-RestMethod "https://$dynatraceTenant.live.dynatrace.com/api/v2/events/ingest" -Method 'POST' -Headers $requestHeaders -Body $requestBody

      # Write Output if Dynatrace Alert Failed.
      if ($response.reportCount -eq 0) {
        Write-Output "`tFailed to create alert in Dyantrace, this may be due to a incorrect entity name or entity type."
        Continue
      }
      else {
        $response | ConvertTo-Json
      }
    }
    catch {
      Write-Output "`tUnable To Create Dyanatrace Alert, Exception Below:"
      Write-Output "`n`t$_"
    }
  }
  else {
    Write-Output "`tFound 0 Client Secrets That Are Due To Expire Soon."
  }
}