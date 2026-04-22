#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
LOCATION="${LOCATION:-eastus}"
RG_APP="rg-app-${ENVIRONMENT}"
PLAN_NAME="plan-${ENVIRONMENT}"
SUB_HASH="$(az account show --query id -o tsv | tr -d '-' | cut -c1-8)"
WEBAPP_NAME="${WEBAPP_NAME:-webapp-${ENVIRONMENT}-${SUB_HASH}}"

if ! az appservice plan show -g "$RG_APP" -n "$PLAN_NAME" >/dev/null 2>&1; then
  az appservice plan create -g "$RG_APP" -n "$PLAN_NAME" --sku P1v3 --is-linux
fi
if ! az webapp show -g "$RG_APP" -n "$WEBAPP_NAME" >/dev/null 2>&1; then
  az webapp create -g "$RG_APP" -p "$PLAN_NAME" -n "$WEBAPP_NAME" --runtime "NODE:20-lts"
fi

echo "Web app created: $WEBAPP_NAME"

echo "If deploying zip package:"
echo "az webapp deployment source config-zip -g $RG_APP -n $WEBAPP_NAME --src app.zip"
