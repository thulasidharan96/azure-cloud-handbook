#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
LOCATION="${LOCATION:-eastus}"
RG_NET="rg-net-${ENVIRONMENT}"
VNET_NAME="vnet-${ENVIRONMENT}"

az network vnet create -g "$RG_NET" -n "$VNET_NAME" -l "$LOCATION" \
  --address-prefixes 10.40.0.0/16 --subnet-name snet-web --subnet-prefixes 10.40.1.0/24

az network vnet subnet create -g "$RG_NET" --vnet-name "$VNET_NAME" -n snet-app --address-prefixes 10.40.2.0/24
az network vnet subnet create -g "$RG_NET" --vnet-name "$VNET_NAME" -n snet-data --address-prefixes 10.40.3.0/24

az network nsg create -g "$RG_NET" -n "nsg-web-${ENVIRONMENT}"
az network nsg rule create -g "$RG_NET" --nsg-name "nsg-web-${ENVIRONMENT}" -n allow-https \
  --priority 100 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes Internet --destination-port-ranges 443

az network public-ip create -g "$RG_NET" -n "pip-nat-${ENVIRONMENT}" --sku Standard
az network nat gateway create -g "$RG_NET" -n "nat-${ENVIRONMENT}" --public-ip-addresses "pip-nat-${ENVIRONMENT}"
az network vnet subnet update -g "$RG_NET" --vnet-name "$VNET_NAME" -n snet-app --nat-gateway "nat-${ENVIRONMENT}"

echo "Networking baseline created"
