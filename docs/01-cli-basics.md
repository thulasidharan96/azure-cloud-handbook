# 01 - Azure CLI Basics

## Explanation
Azure CLI is the operational interface for provisioning, auditing, and automating Azure resources consistently across environments.

## Real-World Use Case
A platform team standardizes environment bootstrap (dev/staging/prod) with repeatable scripts executed by engineers and CI/CD pipelines.

## Azure CLI Commands
```bash
az version
az upgrade
az login
az account list -o table
az account set --subscription "<SUB_ID>"
az group create --name rg-bootstrap-dev --location eastus
az configure --defaults group=rg-bootstrap-dev location=eastus
```

## Best Practices
- Pin automation to tested CLI versions in CI images.
- Use `--output json` for machine parsing and `-o table` for human reads.
- Keep idempotent scripts (`create` guarded by `show`/`exists`).

## Security Considerations
- Prefer managed identities or OIDC over client secrets.
- Avoid storing tokens or credentials in scripts.
- Scope access by resource group where possible.

## Pricing Tier Overview
CLI has no direct cost; billed resources are created through CLI operations.
