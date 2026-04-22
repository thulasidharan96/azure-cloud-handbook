# 13 - Full Production Architecture

## Explanation
Reference architecture for enterprise-grade web platform with secure ingress, scalable compute, private data, and full observability.

## Real-World Use Case
Customer-facing digital product requiring high availability, secure data access, and controlled multi-environment release flow.

## ASCII Diagram
```text
Users
  |
[Azure Front Door]
  |
[Application Gateway WAF]
  |
[App Service Frontend]
  |
[AKS Backend APIs] -- [Redis Cache]
      |                 |
      +------[Key Vault]|
              |         |
      [Private Endpoints + Private DNS]
              |
         [Azure SQL]
              |
[Azure Monitor + Log Analytics + App Insights]
```

## Azure CLI Commands
```bash
# Resource groups
az group create -n rg-net-prod -l eastus
az group create -n rg-app-prod -l eastus
az group create -n rg-data-prod -l eastus

# Network
az network vnet create -g rg-net-prod -n vnet-prod --address-prefixes 10.30.0.0/16 \
  --subnet-name snet-web --subnet-prefixes 10.30.1.0/24

# App tier
az appservice plan create -g rg-app-prod -n plan-prod --sku P1v3 --is-linux
az webapp create -g rg-app-prod -p plan-prod -n webapp-frontend-prod --runtime "NODE:20-lts"
az aks create -g rg-app-prod -n aks-backend-prod --node-count 3 --enable-managed-identity --network-plugin azure

# Data tier
az sql server create -g rg-data-prod -n sql-prod-contoso --admin-user sqladmin --admin-password "<StrongPassword>"
az sql db create -g rg-data-prod -s sql-prod-contoso -n appdb --service-objective GP_S_Gen5_2
az redis create -g rg-data-prod -n redis-prod-contoso -l eastus --sku Premium --vm-size P1

# Secrets
az keyvault create -g rg-app-prod -n kv-prod-contoso -l eastus --enable-rbac-authorization true
```

## Best Practices
- Isolate environments by subscription and networking.
- Use IaC for reproducibility and drift control.
- Define SLO-based scaling and alerting.

## Security Considerations
- Private endpoints only for data services.
- No public DB endpoints.
- Strict RBAC and managed identity first.

## Pricing Tier Overview
Frontend: App Service Premium; Backend: AKS node pools; Data: SQL + Redis tiered by throughput and HA requirements.
