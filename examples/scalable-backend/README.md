# Example 2: Scalable Backend

## Architecture
AKS + Redis + Azure Database for PostgreSQL.

## Use Case
High-throughput API backend with caching and managed relational database.

## CLI
```bash
az group create -n rg-backend-dev -l eastus
az aks create -g rg-backend-dev -n aks-backend-dev --node-count 3 --enable-managed-identity --network-plugin azure
az redis create -g rg-backend-dev -n redis-backend-dev -l eastus --sku Standard --vm-size C1
az postgres flexible-server create -g rg-backend-dev -n pg-backend-dev -l eastus --sku-name Standard_D2s_v3
```

## Scaling
AKS HPA + Cluster Autoscaler, Redis tier upgrades, PostgreSQL compute/storage scaling.

## Cost
Use autoscaling and reserved compute for steady workloads.
