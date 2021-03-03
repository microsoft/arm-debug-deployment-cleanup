## This script cleans up the deployments at management group level, subscription level, and resource group level that can potentially lead to secrets exposure.
## usage: az login to your respective tenant/cloud first. Then run this script via powershell.
##        Windows machine: 
##        Open powershell and execute this script
##        PS C:\> ./cleanupDeploymentsWithSecrets.ps1
##        
##        Linux machine:
##        Install powershell for Linux (PSCore) - https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1
##        Navigate to the directory containing this script via terminal, open powershell with pwsh command and execute the script
##        PS ./cleanupDeploymentsWithSecrets.ps1
## WARNING: As this script goes through all management groups, subscriptions and resource groups level deployments, the output can potentially be huge, thus we strongly recommend to redirect the output to a file

$ErrorActionPreference='Continue' # To make sure the script continues to run after failure

## Assuming that user has already logged into the respective cloud/tenant.
$managementGroups = az account management-group list | ConvertFrom-Json

echo 'Iterating through the management groups...'

## Go through all the management groups. Look for deployments with potentially exposing secrets, and delete such deployments
foreach($managementGroup in $managementGroups) {
    Write-Host "Fetching deployments for management group - $($managementGroup.name)"

    $MGDeployments = az deployment mg list -m $managementGroup.name --query "[?properties.debugSetting.detailLevel == 'RequestContent, ResponseContent']" | ConvertFrom-Json

    foreach($MGDeployment in $MGDeployments) {
        Write-Host "The Deployment - $($MGDeployment.name) for the management group $($managementGroup.name) has debugSettings enabled and that can potentially lead to secrets exposure. Proceeding to delete this deployment..."

        az deployment mg delete -m $managementGroup.name -n $MGDeployment.name
        if (-not $?) {
            Write-Host "Failed to delete $($MGDeployment.name). $($Error[0].Exception.Message)" -fore Red
        }
        else {
            Write-Host "Deleted - $($MGDeployment.name)" -fore Green
        }
    }
}

$subscriptions = az account list | ConvertFrom-Json

Write-Host 'Iterating through the subscriptions...'

## Go through all the subscriptions. Look for deployments with potentially exposing secrets, and delete such deployments.
## Go through all resource groups under the subscription. Look for deployments with potentially exposing secrets, and delete such deployments.
foreach($subscription in $subscriptions) {
    Write-Host "Fetching deployments for subscription - $($subscription.name)"
    
    az account set --subscription $subscription.name

    $SubDeployments = az deployment sub list --query "[?properties.debugSetting.detailLevel == 'RequestContent, ResponseContent']" | ConvertFrom-Json

    foreach($SubDeployment in $SubDeployments) {
       Write-Host "The Deployment - $($SubDeployment.name) for the subscription $($subscription.name) has debugSettings enabled and that can potentially lead to secrets exposure. Proceeding to delete this deployment..."

       az deployment sub delete -n $SubDeployment.name
       if (-not $?) {
           Write-Host "Failed to delete $($SubDeployment.name). $($Error[0].Exception.Message)" -fore Red
       }
       else {
           Write-Host "Deleted - $($SubDeployment.name)" -fore Green
       }
    }

    Write-Host "Iterating through the resource groups under $($subscription.name)..."

    $resourceGroups = az group list | ConvertFrom-Json

    foreach($resourceGroup in $resourceGroups) {
       Write-Host "Fetching deployments for resource group - $($resourceGroup.name)"

       $RGDeployments = az deployment group list -g $resourceGroup.name --query "[?properties.debugSetting.detailLevel == 'RequestContent, ResponseContent']" | ConvertFrom-Json

       foreach($RGDeployment in $RGDeployments) {
          Write-Host "The Deployment - $($RGDeployment.name) for the resource group $($resourceGroup.name) has debugSettings enabled and that can potentially lead to secrets exposure. Proceeding to delete this deployment..."

          az deployment group delete -g $resourceGroup.name -n $RGDeployment.name
          if (-not $?) {
              Write-Host "Failed to delete $($RGDeployment.name). $($Error[0].Exception.Message)" -fore Red
          }
          else {
              Write-Host "Deleted - $($RGDeployment.name)" -fore Green
          }
       }
    }
}
