# 14 - Advanced Topics

## Blue/Green Deployment
### Explanation
Two identical environments with controlled traffic switch.
### Real-World Use Case
Release high-risk API changes with near-zero downtime.
### Azure CLI Commands
```bash
az webapp deployment slot create -g rg-app-prod -n webapp-prod-contoso --slot green
az webapp deployment slot swap -g rg-app-prod -n webapp-prod-contoso --slot green --target-slot production
```
### Best Practices
Automate pre-switch validation and rollback criteria.
### Security Considerations
Keep both slots patched and secrets synchronized.
### Pricing Tier Overview
Requires higher-tier plans supporting slots.

## Canary Releases
### Explanation
Progressive traffic rollout with health gates.
### Real-World Use Case
AKS ingress routes 5% traffic to new version.
### Azure CLI Commands
```bash
az aks command invoke -g rg-app-prod -n aks-prod --command "kubectl rollout status deploy/api"
```
### Best Practices
Use error budget and latency thresholds as promotion gates.
### Security Considerations
Apply same policy and network controls to canary workload.
### Pricing Tier Overview
Temporary double-capacity during rollout increases short-term cost.

## Multi-Region Failover
### Explanation
Active-passive or active-active architecture for resilience.
### Real-World Use Case
Primary East US and failover Central US.
### Azure CLI Commands
```bash
az network front-door create -g rg-net-prod -n fd-global-prod --backend-address webapp-frontend-prod.azurewebsites.net
```
### Best Practices
Regular DR drills and tested failover runbooks.
### Security Considerations
Replicate policies and secrets controls across regions.
### Pricing Tier Overview
Higher cost due to duplicate regional capacity.

## Bicep & Terraform
### Explanation
IaC for repeatable and governed infrastructure.
### Real-World Use Case
Multi-environment infra promotion through PR-reviewed modules.
### Azure CLI Commands
```bash
az deployment group create -g rg-app-dev --template-file infra/bicep/main.bicep --parameters environment=dev
terraform -chdir=infra/terraform init && terraform -chdir=infra/terraform plan
```
### Best Practices
Version modules, enforce policy checks, and lock state.
### Security Considerations
Store state securely and protect pipeline identities.
### Pricing Tier Overview
No direct IaC tool charge; costs come from managed infrastructure and state backends.
