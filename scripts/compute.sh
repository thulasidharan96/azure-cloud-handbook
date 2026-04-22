#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
LOCATION="${LOCATION:-eastus}"
RG_COMPUTE="rg-app-${ENVIRONMENT}"

if ! az vm show -g "$RG_COMPUTE" -n "vm-jump-${ENVIRONMENT}" >/dev/null 2>&1; then
  az vm create -g "$RG_COMPUTE" -n "vm-jump-${ENVIRONMENT}" --image Ubuntu2204 \
    --admin-username azureuser --generate-ssh-keys >/dev/null
fi

if ! az vmss show -g "$RG_COMPUTE" -n "vmss-api-${ENVIRONMENT}" >/dev/null 2>&1; then
  az vmss create -g "$RG_COMPUTE" -n "vmss-api-${ENVIRONMENT}" --image Ubuntu2204 --instance-count 2 \
    --admin-username azureuser --generate-ssh-keys >/dev/null
fi

if ! az aks show -g "$RG_COMPUTE" -n "aks-${ENVIRONMENT}" >/dev/null 2>&1; then
  az aks create -g "$RG_COMPUTE" -n "aks-${ENVIRONMENT}" --location "$LOCATION" \
    --node-count 2 --enable-managed-identity --network-plugin azure >/dev/null
fi

if ! az container show -g "$RG_COMPUTE" -n "aci-job-${ENVIRONMENT}" >/dev/null 2>&1; then
  az container create -g "$RG_COMPUTE" -n "aci-job-${ENVIRONMENT}" \
    --image mcr.microsoft.com/azuredocs/aci-helloworld --cpu 1 --memory 1.5 >/dev/null
fi

echo "Compute resources created for $ENVIRONMENT"
