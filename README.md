# ARM deployment clean up script

This script will ietrate though all ARM deployments and will clean up those deployments where debugSetting is enabled. It will scan deployments at following scopes:
- Management groups
- Subscriptions
- Resource groups

## Pre-requisites

Windows Users -
- Install Azure Az powershell module - Follow installation instructions on https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-5.6.0

Linus Users -
- Install Powershell for Linux (PSCore) - Follow instrcutions on https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1
- Install Azure Az powershell module - Follow installation instructions on https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-5.6.0

## Usage

Use `Connect-AzConnect` on powershell to connect to your respective tenant/cloud first (https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-ps). Then run this script via powershell.

Windows users: 
- Open powershell,
- Connect to azure with `Connect-AzConnect`,
- Execute this script `PS C:\> ./Remove-DebugDeployments.ps1`

Linux users: 
- Open powershell with `pwsh` command on Terminal,
- Connect to azure with `Connect-AzConnect`, 
- Execute the script `PS ./Remove-DebugDeployments.ps1`
