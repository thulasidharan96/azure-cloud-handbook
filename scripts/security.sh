#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
LOCATION="${LOCATION:-eastus}"
RG_SEC="rg-sec-${ENVIRONMENT}"
KV_NAME="kv-${ENVIRONMENT}-$RANDOM"
ASSIGNEE="${ASSIGNEE:-}"

az keyvault create -g "$RG_SEC" -n "$KV_NAME" -l "$LOCATION" --enable-rbac-authorization true

if [[ -n "$ASSIGNEE" ]]; then
  SCOPE="$(az keyvault show -g "$RG_SEC" -n "$KV_NAME" --query id -o tsv)"
  az role assignment create --assignee "$ASSIGNEE" --role "Key Vault Secrets User" --scope "$SCOPE"
fi

az keyvault secret set --vault-name "$KV_NAME" --name "example-secret" --value "replace-me"

echo "Security baseline created with Key Vault: $KV_NAME"
