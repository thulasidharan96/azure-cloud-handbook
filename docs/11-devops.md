# 11 - DevOps

## Explanation
Production DevOps on Azure combines CI/CD, IaC, and policy gates to deliver safely across environments.

## Real-World Use Case
A team deploys Bicep infra and application packages through GitHub Actions with environment approvals and rollback.

## Azure CLI Commands
```bash
az deployment group create \
  --resource-group rg-app-dev \
  --template-file infra/bicep/main.bicep \
  --parameters environment=dev

az webapp deployment source config-zip \
  -g rg-app-dev -n webapp-dev-contoso --src app.zip
```

## Best Practices
- Promote immutable artifacts across dev/staging/prod.
- Require PR reviews, status checks, and security scans.
- Detect and remediate infrastructure drift.

## Security Considerations
- Use GitHub OIDC federation (no static cloud secrets).
- Store app secrets in Key Vault, not repository secrets.
- Sign build artifacts and enforce provenance.

## Pricing Tier Overview
CI/CD costs depend on GitHub runner minutes, environment scale, and deployed Azure resources.
