# 09 - Integration

## API Management (APIM)
### Explanation
Centralized API gateway for policy, security, and lifecycle governance.
### Real-World Use Case
Expose internal microservices externally with JWT validation and throttling.
### Azure CLI Commands
```bash
az apim create -g rg-int-prod -n apim-prod-contoso \
  --publisher-name "Contoso" --publisher-email "ops@contoso.com" \
  --sku-name Developer --location eastus
```
### Best Practices
Use revisions/versions and environment-specific products.
### Security Considerations
OAuth2/JWT validation and private/internal mode in production.
### Pricing Tier Overview
Consumption, Developer, Basic, Standard, Premium.

## Event Grid
### Explanation
Event routing for reactive architectures.
### Real-World Use Case
Blob upload triggers downstream processing pipelines.
### Azure CLI Commands
```bash
az eventgrid topic create -g rg-int-prod -n eg-topic-prod -l eastus
```
### Best Practices
Use dead-lettering and idempotent handlers.
### Security Considerations
Signed webhook validation and private endpoints where supported.
### Pricing Tier Overview
Pay per operation/event delivery.

## Service Bus
### Explanation
Reliable asynchronous messaging (queues/topics).
### Real-World Use Case
Order processing decoupled from checkout API.
### Azure CLI Commands
```bash
az servicebus namespace create -g rg-int-prod -n sb-prod-contoso -l eastus --sku Standard
az servicebus queue create -g rg-int-prod --namespace-name sb-prod-contoso -n orders
```
### Best Practices
Use DLQ and retry policies.
### Security Considerations
Private endpoints and managed identity auth.
### Pricing Tier Overview
Basic, Standard, Premium tiers.

## Logic Apps
### Explanation
Managed workflow orchestration across connectors.
### Real-World Use Case
Automated incident enrichment and notifications.
### Azure CLI Commands
```bash
az logic workflow create -g rg-int-prod -n la-order-orchestrator -l eastus
```
### Best Practices
Define retries and compensating actions.
### Security Considerations
Use managed connectors with least privilege identities.
### Pricing Tier Overview
Consumption and Standard plans.
