# 08 - AI & ML

## Azure Machine Learning
### Explanation
Managed platform for model training, registry, deployment, and MLOps.
### Real-World Use Case
Fraud model training pipeline with scheduled retraining and endpoint deployment.
### Azure CLI Commands
```bash
az extension add -n ml
az ml workspace create -g rg-ai-prod -n aml-prod -l eastus
```
### Best Practices
Use separate dev/prod workspaces and model versioning.
### Security Considerations
Private endpoints, managed identity, encrypted data stores.
### Pricing Tier Overview
Compute, managed endpoints, storage, and networking costs.

## Cognitive Services
### Explanation
Managed APIs for language, speech, vision, and decision workloads.
### Real-World Use Case
Document extraction + language analytics pipeline.
### Azure CLI Commands
```bash
az cognitiveservices account create -g rg-ai-prod -n cs-prod-language \
  --kind TextAnalytics --sku S --location eastus --yes
```
### Best Practices
Batch requests and cache responses where applicable.
### Security Considerations
Restrict network access and rotate keys.
### Pricing Tier Overview
Per-transaction and tier-based SKUs.

## Azure OpenAI Service
### Explanation
Managed access to LLMs and embeddings on Azure.
### Real-World Use Case
Internal assistant with retrieval-augmented generation over enterprise docs.
### Azure CLI Commands
```bash
az cognitiveservices account create -g rg-ai-prod -n aoai-prod \
  --kind OpenAI --sku S0 --location eastus --yes
```
### Best Practices
Apply prompt/version governance and output evaluation.
### Security Considerations
Private networking, RBAC, and content filtering policies.
### Pricing Tier Overview
Token-based model usage + hosting limits.
