# 02 - Core Azure Structure

## Explanation
Azure governance hierarchy: Management Groups → Subscriptions → Resource Groups → Resources.

## Real-World Use Case
An enterprise separates prod/nonprod subscriptions under management groups with inherited policy and RBAC controls.

## Azure CLI Commands
```bash
az account management-group list -o table
az group create --name rg-app-prod --location eastus
az resource list --resource-group rg-app-prod -o table
```

## Best Practices
- Align resource groups to lifecycle and ownership boundaries.
- Isolate production subscriptions from non-production.
- Apply policy at management group scope.

## Security Considerations
- Enforce deny policies for insecure SKUs/configurations.
- Use resource locks on critical production resources.
- Limit Owner role assignments.

## Pricing Tier Overview
Hierarchy objects are governance constructs; cost comes from deployed services in subscriptions/resource groups.
