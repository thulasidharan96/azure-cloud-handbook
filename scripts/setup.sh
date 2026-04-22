#!/usr/bin/env bash
set -euo pipefail

LOCATION="${LOCATION:-eastus}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
RG_NET="rg-net-${ENVIRONMENT}"
RG_APP="rg-app-${ENVIRONMENT}"
RG_DATA="rg-data-${ENVIRONMENT}"
RG_SEC="rg-sec-${ENVIRONMENT}"

az group create --name "$RG_NET" --location "$LOCATION"
az group create --name "$RG_APP" --location "$LOCATION"
az group create --name "$RG_DATA" --location "$LOCATION"
az group create --name "$RG_SEC" --location "$LOCATION"

echo "Created baseline resource groups for $ENVIRONMENT in $LOCATION"
