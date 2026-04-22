# Example 3: Enterprise Architecture

## Architecture
APIM + microservices (AKS/App Service) + Event Grid + Service Bus.

## Use Case
Enterprise integration platform for multiple business domains and asynchronous processing.

## CLI
```bash
az group create -n rg-ent-dev -l eastus
az apim create -g rg-ent-dev -n apim-ent-dev --publisher-name "Contoso" --publisher-email "ops@contoso.com" --sku-name Developer --location eastus
az eventgrid topic create -g rg-ent-dev -n eg-ent-dev -l eastus
az servicebus namespace create -g rg-ent-dev -n sb-ent-dev --sku Standard -l eastus
az servicebus queue create -g rg-ent-dev --namespace-name sb-ent-dev -n orders
```

## Scaling
Scale APIM tier, partition microservices, and add regional event endpoints.

## Cost
Developer SKU for nonprod; Standard/Premium for production throughput and networking controls.
