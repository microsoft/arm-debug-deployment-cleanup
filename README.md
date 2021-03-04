# ARM debug deployment clean up script

This script will iterate though all ARM deployments and will clean up those deployments where debugSetting is enabled. It will scan deployments at following scopes:
- Management groups
- Subscriptions
- Resource groups
