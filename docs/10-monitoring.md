# 10 - Monitoring

## Explanation
Observability stack for metrics, logs, traces, and alerting using Azure Monitor, Log Analytics, and Application Insights.

## Real-World Use Case
SRE team tracks SLOs for API latency/error rate and routes actionable alerts to on-call workflows.

## Azure CLI Commands
```bash
az monitor log-analytics workspace create -g rg-ops-prod -n law-prod-eastus -l eastus
az monitor app-insights component create -g rg-ops-prod -a appi-api-prod -l eastus \
  --workspace /subscriptions/<SUB_ID>/resourceGroups/rg-ops-prod/providers/Microsoft.OperationalInsights/workspaces/law-prod-eastus
az monitor metrics alert create -g rg-ops-prod -n cpu-high \
  --scopes <RESOURCE_ID> --condition "avg Percentage CPU > 80" \
  --window-size 5m --evaluation-frequency 1m
```

## Best Practices
- Define golden signals (latency, traffic, errors, saturation).
- Alert on symptoms users feel, not noisy internals.
- Tune retention per compliance and cost goals.

## Security Considerations
- Restrict log query/write access via RBAC.
- Mask/avoid sensitive payload logging.
- Use immutable retention where required.

## Pricing Tier Overview
Costs include ingestion volume, retention period, and alert rule execution.
