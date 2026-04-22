# 06 - App Hosting

## App Service
### Explanation
Managed PaaS for web apps and APIs.
### Real-World Use Case
Enterprise API with deployment slots and VNet integration.
### Azure CLI Commands
```bash
az appservice plan create -g rg-app-prod -n plan-web --sku P1v3 --is-linux
az webapp create -g rg-app-prod -p plan-web -n webapp-prod-contoso --runtime "NODE:20-lts"
```
### Best Practices
Use slots, autoscale, and health checks.
### Security Considerations
Private endpoints, managed identity, HTTPS-only.
### Pricing Tier Overview
Free/Basic/Standard/Premium/Isolated.

## Function App
### Explanation
Event-driven serverless execution.
### Real-World Use Case
Process Service Bus events with elastic scale.
### Azure CLI Commands
```bash
az functionapp create -g rg-app-prod -n func-prod-contoso \
  --storage-account stprodcontoso --consumption-plan-location eastus \
  --runtime python --functions-version 4
```
### Best Practices
Use queue/event triggers and idempotent handlers.
### Security Considerations
Use managed identity and private storage access.
### Pricing Tier Overview
Consumption, Premium, Dedicated.

## Static Web Apps
### Explanation
Global edge hosting for frontend apps.
### Real-World Use Case
React SPA frontend with API integration.
### Azure CLI Commands
```bash
az staticwebapp create -g rg-app-prod -n swa-prod-contoso \
  --source https://github.com/<org>/<repo> --branch main --location eastus2
```
### Best Practices
Cache aggressively and use preview environments.
### Security Considerations
Protect APIs with Entra auth and restricted origins.
### Pricing Tier Overview
Free and Standard tiers.
