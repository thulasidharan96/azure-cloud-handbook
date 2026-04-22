# Example 1: Simple Web App

## Architecture
App Service + Azure SQL + Key Vault.

## Use Case
Business web app with managed hosting and relational data.

## CLI
```bash
az group create -n rg-simple-dev -l eastus
az appservice plan create -g rg-simple-dev -n plan-simple --sku P1v3 --is-linux
az webapp create -g rg-simple-dev -p plan-simple -n webapp-simple-dev --runtime "NODE:20-lts"
az sql server create -g rg-simple-dev -n sql-simple-dev --admin-user sqladmin --admin-password "<StrongPassword>"
az sql db create -g rg-simple-dev -s sql-simple-dev -n appdb --service-objective GP_S_Gen5_1
az keyvault create -g rg-simple-dev -n kv-simple-dev -l eastus --enable-rbac-authorization true
```

## Scaling
Scale App Service plan vertically/horizontally as traffic grows.

## Cost
Use Standard/Premium app tier, serverless SQL for variable load.
