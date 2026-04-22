#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
LOCATION="${LOCATION:-eastus}"
RG_APP="rg-app-${ENVIRONMENT}"
PLAN_NAME="plan-${ENVIRONMENT}"
WEBAPP_NAME="webapp-${ENVIRONMENT}-$RANDOM"

az appservice plan create -g "$RG_APP" -n "$PLAN_NAME" --sku P1v3 --is-linux
az webapp create -g "$RG_APP" -p "$PLAN_NAME" -n "$WEBAPP_NAME" --runtime "NODE:20-lts"

echo "Web app created: $WEBAPP_NAME"

echo "If deploying zip package:"
echo "az webapp deployment source config-zip -g $RG_APP -n $WEBAPP_NAME --src app.zip"
