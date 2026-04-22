# 04 - Identity, RBAC, and Security

## Explanation
Identity and access controls protect Azure control plane and data plane operations.

## Real-World Use Case
A CI/CD pipeline uses federated identity with least-privileged contributor role at resource group scope and Key Vault for secrets.

## Azure CLI Commands
```bash
# Built-in role assignment
az role assignment create \
  --assignee <PRINCIPAL_ID_OR_UPN> \
  --role Reader \
  --scope /subscriptions/<SUB_ID>/resourceGroups/rg-app-prod

# Service principal (if required)
az ad sp create-for-rbac \
  --name sp-cicd-prod \
  --role Contributor \
  --scopes /subscriptions/<SUB_ID>/resourceGroups/rg-app-prod

# Managed identity enablement (example for web app)
az webapp identity assign -g rg-app-prod -n webapp-prod

# Key Vault
az keyvault create -g rg-sec-prod -n kv-prod-eastus -l eastus --enable-rbac-authorization true
az keyvault secret set --vault-name kv-prod-eastus --name app-secret --value "<secret>"
```

## Best Practices
- Use groups for human RBAC assignment.
- Prefer managed identities and OIDC over static credentials.
- Separate duties: platform ops vs app teams.

## Security Considerations
- Enforce least privilege and time-bound elevation (PIM).
- Enable Key Vault purge protection and soft delete.
- Rotate secrets every 30–90 days based on risk.

## Pricing Tier Overview
- Entra ID: included and premium feature tiers.
- Key Vault: Standard and Premium (HSM-backed key features in Premium).
