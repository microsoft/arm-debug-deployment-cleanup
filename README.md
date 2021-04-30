# ARM debug deployment clean up script

This script will iterate though all ARM deployments and will clean up those deployments where debugSetting is enabled. It will scan deployments at following scopes:
- Management groups
- Subscriptions
- Resource groups

***Note: The user running the script must have permission to delete deployments at each scope.  If the user does not have permission to read deployments none will be returned or deleted.***

## Pre-requisites

Windows Users -
- Install Azure Az powershell module - Follow installation instructions on https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-5.6.0

Linux Users -
- Install Powershell for Linux (PSCore) - Follow instructions on https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1
- Install Azure Az powershell module - Follow installation instructions on https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-5.6.0

## Usage

Use `Connect-AzConnect` on powershell to connect to your respective tenant/cloud first (https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-ps). Then run this script via powershell. **Note**: The script will not delete the deployments unless `-ForceDelete` switch is passed.

Windows users: 
- Open powershell,
- Connect to azure with `Connect-AzConnect`,
- Execute this script `PS C:\> ./Remove-DebugDeployments.ps1` (deployments with debug logs will be displayed but not deleted).
- Execute with the switch `PS C:\> ./Remove-DebugDeployments.ps1 -ForceDelete` (deployments with debug logs will be deleted).

Linux users: 
- Open powershell with `pwsh` command on Terminal,
- Connect to azure with `Connect-AzConnect`, 
- Execute this script `PS ./Remove-DebugDeployments.ps1` (deployments with debug logs will be displayed but not deleted).
- Execute with the switch `PS ./Remove-DebugDeployments.ps1 -ForceDelete` (deployments with debug logs will be deleted).
