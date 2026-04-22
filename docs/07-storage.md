# 07 - Storage

## Explanation
Azure Storage provides Blob, File, Queue, and Table services under a single account.

## Real-World Use Case
Media files in Blob, shared files for legacy apps, queue-based async processing, and key-value table storage.

## Azure CLI Commands
```bash
az storage account create -g rg-data-prod -n stprodcontoso -l eastus \
  --sku Standard_GRS --kind StorageV2 --allow-blob-public-access false --min-tls-version TLS1_2

az storage account blob-service-properties update \
  --account-name stprodcontoso --resource-group rg-data-prod \
  --enable-delete-retention true --delete-retention-days 30
```

## Best Practices
- Select redundancy by RTO/RPO needs.
- Use lifecycle rules for tier transitions and deletion.
- Enable versioning and soft delete.

## Security Considerations
- Prefer private endpoints.
- Disable public blob access.
- Use RBAC and managed identity for access.

## Pricing Tier Overview
- Performance: Standard or Premium.
- Access tiers: Hot, Cool, Archive.
- Redundancy: LRS, ZRS, GRS, GZRS.
