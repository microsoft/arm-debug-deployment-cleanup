## This script cleans up the deployments at management group level, subscription level, and resource group level with debugSettings set to 'RequestContent, ResponseContent'.
##
## Pre-requisites:
##        Windows users:
##        Install Azure Az powershell module - Follow installation instructions on https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-5.6.0
##
##        Linux users:
##        Install Powershell for Linux (PSCore) - Follow instrcutions on https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1
##        Install Azure Az powershell module - Follow installation instructions on https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-5.6.0
##
## Usage: Use Connect-AzConnect to your respective tenant/cloud first (https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-ps).
##        Then run this script via powershell.
##
##        Windows users: 
##        Open powershell and execute this script
##        PS C:\> ./Remove-DebugDeployments.ps1
##        
##        Linux users:
##        Open powershell with pwsh command on Terminal and execute the script
##        PS ./Remove-DebugDeployments.ps1
## WARNING: As this script goes through all management groups, subscriptions and resource groups level deployments, the output can potentially be huge, thus we strongly recommend to redirect the output to a file

$ErrorActionPreference='Continue' # To make sure the script continues to run after failure

## Assuming that user has already logged into the respective cloud/tenant.
$managementGroups = Get-AzManagementGroup

Write-Host "Iterating through the management groups..."

## Go through all the management groups. Look for deployments with debugSettings, and delete such deployments
foreach ($managementGroup in $managementGroups) {
    Write-Host "Fetching deployments for management group - $($managementGroup.Name)"
    
    $MGDeployments = Get-AzManagementGroupDeployment -ManagementGroupId $managementGroup.Name

    foreach ($MGDeployment in $MGDeployments) {
        if ($MGDeployment.DeploymentDebugLogLevel -eq "RequestContent, ResponseContent") {
            Write-Host "The Deployment - $($MGDeployment.DeploymentName) for the management group $($managementGroup.Name) has debugSettings enabled. Proceeding to delete this deployment..."

            Remove-AzManagementGroupDeployment -ManagementGroupId $managementGroup.Name -Name $MGDeployment.DeploymentName

            if (-not $?) {
                Write-Host "Failed to delete $($MGDeployment.DeploymentName)" -fore Red
            }
            else {
                Write-Host "Successfully deleted $($MGDeployment.DeploymentName)" -fore Green
            }
        }
    }
}

$subscriptions = Get-AzSubscription

Write-Host 'Iterating through the subscriptions...'

## Go through all the subscriptions. Look for deployments with debugSettings, and delete such deployments.
## Go through all resource groups under the subscription. Look for deployments with debugSettings, and delete such deployments.
foreach ($subscription in $subscriptions) {
    Set-AzContext -Subscription $subscription.Id
    $SubDeployments = Get-AzDeployment

    foreach ($SubDeployment in $SubDeployments) {
        if ($SubDeployment.DeploymentDebugLogLevel -eq "RequestContent, ResponseContent") {
            Write-Host "The Deployment - $($SubDeployment.DeploymentName) for the subscription $($subscription.Name) has debugSettings enabled. Proceeding to delete this deployment..."

            Remove-AzDeployment -Name $SubDeployment.DeploymentName
            
            if (-not $?) {
                Write-Host "Failed to delete $($SubDeployment.DeploymentName)" -fore Red
            }
            else {
                Write-Host "Successfully deleted $($SubDeployment.DeploymentName)" -fore Green
            }
        }
    }

    Write-Host "Iterating through the resource groups under $($subscription.Name)..."

    $resourceGroups = Get-AzResourceGroup

    foreach ($resourceGroup in $resourceGroups) {
        Write-Host "Fetching deployments for resource group - $($resourceGroup.ResourceGroupName)"

        $RGDeployments = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroup.ResourceGroupName

        foreach ($RGDeployment in $RGDeployments) {
            if ($RGDeployment.DeploymentDebugLogLevel -eq "RequestContent, ResponseContent") {
                Write-Host "The Deployment - $($RGDeployment.DeploymentName) for the resource group $($resourceGroup.ResourceGroupName) has debugSettings enabled. Proceeding to delete this deployment..."
    
                Remove-AzResourceGroupDeployment -ResourceGroupName $resourceGroup.ResourceGroupName -Name $RGDeployment.DeploymentName
                if (-not $?) {
                    Write-Host "Failed to delete $($RGDeployment.DeploymentName)" -fore Red
                }
                else {
                    Write-Host "Successfully deleted $($RGDeployment.DeploymentName)" -fore Green
                }
            }
        }
    }
}
