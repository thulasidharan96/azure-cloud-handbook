#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
LOCATION="${LOCATION:-eastus}"
RG_COMPUTE="rg-app-${ENVIRONMENT}"

az vm create -g "$RG_COMPUTE" -n "vm-jump-${ENVIRONMENT}" --image Ubuntu2204 \
  --admin-username azureuser --generate-ssh-keys

az vmss create -g "$RG_COMPUTE" -n "vmss-api-${ENVIRONMENT}" --image Ubuntu2204 --instance-count 2

az aks create -g "$RG_COMPUTE" -n "aks-${ENVIRONMENT}" --location "$LOCATION" \
  --node-count 2 --enable-managed-identity --network-plugin azure

az container create -g "$RG_COMPUTE" -n "aci-job-${ENVIRONMENT}" \
  --image mcr.microsoft.com/azuredocs/aci-helloworld --cpu 1 --memory 1.5

echo "Compute resources created for $ENVIRONMENT"
