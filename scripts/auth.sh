#!/usr/bin/env bash
set -euo pipefail

SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-}"
SP_NAME="${SP_NAME:-sp-playbook-cicd}"
SCOPE_RG="${SCOPE_RG:-rg-app-dev}"

az login

if [[ -n "$SUBSCRIPTION_ID" ]]; then
  az account set --subscription "$SUBSCRIPTION_ID"
fi

SCOPE="$(az group show --name "$SCOPE_RG" --query id -o tsv)"
az ad sp create-for-rbac --name "$SP_NAME" --role Contributor --scopes "$SCOPE"

echo "Authentication and SP setup complete"
