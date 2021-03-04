## This script removes deployments at management group level, subscription level, and resource group level with debugSettings that contain 'RequestContent'.  Removing a deployment does NOT affect or remove any resources that were deployed during that deployment.
##
## Pre-requisites:
##        Windows users:
##        Install the Azure Az powershell module - Follow installation instructions on https://docs.microsoft.com/en-us/powershell/azure/install-az-ps
##
##        Linux users:
##        Install Powershell for Linux (PSCore) - Follow instructions on https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux
##        Install the Azure Az powershell module - Follow installation instructions on https://docs.microsoft.com/en-us/powershell/azure/install-az-ps
##
## Usage: Use Connect-AzConnect to your respective tenant/cloud first (https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-ps).  You must connect with an account that has permissions to delete the deployments you wish to remove.
##
##        Then run this script via powershell.
##
##        Windows users: 
##        Open powershell and execute this script
##        PS C:\> ./Remove-DebugDeployments.ps1
##        
##        Linux users:
##        Open powershell with pwsh command on Terminal and execute the script
##        PS ./Remove-DebugDeployments.ps1
##

$ErrorActionPreference='Continue' # To make sure the script continues to run after an individual failure

$managementGroups = Get-AzManagementGroup

Write-Host "Iterating through the management groups..."

## Go through all the management groups. Look for deployments with debugSettings, and delete such deployments
foreach ($managementGroup in $managementGroups) {
    Write-Host "Fetching deployments for management group - $($managementGroup.Name)"
    
    $MGDeployments = Get-AzManagementGroupDeployment -ManagementGroupId $managementGroup.Name

    foreach ($MGDeployment in $MGDeployments) {
        if ($MGDeployment.DeploymentDebugLogLevel -like "*RequestContent*") {
            Write-Host "The Deployment - $($MGDeployment.DeploymentName) for the management group $($managementGroup.Name) contains RequestContent. Proceeding to delete this deployment..."

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
foreach ($subscription in $subscriptions) {
    Write-Host "Fetching deployments for subscription - $($subscription.Id)"
    Set-AzContext -Subscription $subscription.Id
    $SubDeployments = Get-AzSubscriptionDeployment

    foreach ($SubDeployment in $SubDeployments) {
        if ($SubDeployment.DeploymentDebugLogLevel -like "*RequestContent*") {
            Write-Host "The Deployment - $($SubDeployment.DeploymentName) for the subscription $($subscription.Name) contains RequestContent. Proceeding to delete this deployment..."

            Remove-AzSubscriptionDeployment -Name $SubDeployment.DeploymentName
            
            if (-not $?) {
                Write-Host "Failed to delete $($SubDeployment.DeploymentName)" -fore Red
            }
            else {
                Write-Host "Successfully deleted $($SubDeployment.DeploymentName)" -fore Green
            }
        }
    }

    ## Go through all resource groups under the subscription. Look for deployments with debugSettings, and delete such deployments.
    Write-Host "Iterating through the resource groups under $($subscription.id)..."

    $resourceGroups = Get-AzResourceGroup
    foreach ($resourceGroup in $resourceGroups) {
        Write-Host "Fetching deployments for resource group - $($resourceGroup.ResourceGroupName)"

        $RGDeployments = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroup.ResourceGroupName

        foreach ($RGDeployment in $RGDeployments) {
            if ($RGDeployment.DeploymentDebugLogLevel -like "*RequestContent*") {
                Write-Host "The Deployment - $($RGDeployment.DeploymentName) for the resource group $($resourceGroup.ResourceGroupName) contains RequestContent. Proceeding to delete this deployment..."
    
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
