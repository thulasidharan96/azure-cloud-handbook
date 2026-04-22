#!/usr/bin/env bash
set -euo pipefail

LOCATION="${LOCATION:-eastus}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
RG_NET="rg-net-${ENVIRONMENT}"
RG_APP="rg-app-${ENVIRONMENT}"
RG_DATA="rg-data-${ENVIRONMENT}"
RG_SEC="rg-sec-${ENVIRONMENT}"

for RG in "$RG_NET" "$RG_APP" "$RG_DATA" "$RG_SEC"; do
  if [[ "$(az group exists --name "$RG")" != "true" ]]; then
    az group create --name "$RG" --location "$LOCATION" >/dev/null
  fi
done

echo "Created baseline resource groups for $ENVIRONMENT in $LOCATION"
