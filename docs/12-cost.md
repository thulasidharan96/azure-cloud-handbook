# 12 - Cost Optimization

## Explanation
Cost optimization balances reliability, performance, and governance while minimizing waste.

## Real-World Use Case
A platform team reduces monthly spend by rightsizing compute, enforcing lifecycle policies, and enabling reservations.

## Azure CLI Commands
```bash
az consumption budget create \
  --budget-name monthly-platform-budget \
  --amount 5000 \
  --category cost \
  --time-grain monthly \
  --resource-group rg-finops
```

## Best Practices
- Enforce tags for owner/environment/cost-center.
- Use autoscaling and schedule non-prod shutdown.
- Apply reserved capacity for steady workloads.

## Security Considerations
- Restrict billing API permissions.
- Use policy to block disallowed expensive SKUs.

## Pricing Tier Overview
| Service | Lower-cost Option | Higher-cost Option | Choose Higher When |
|---|---|---|---|
| App Service | Basic/Standard | Premium/Isolated | Need VNet integration, scale, stricter SLA |
| AKS | Small node pools | Multi-pool + autoscale | High throughput and resilience needs |
| Storage | LRS + Cool/Archive | ZRS/GRS + Premium | Higher availability/performance requirements |
| APIM | Developer/Basic | Premium | Internal VNet and enterprise scale |
| Key Vault | Standard | Premium | HSM-backed keys required |
