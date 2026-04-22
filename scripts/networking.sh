#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${ENVIRONMENT:-dev}"
LOCATION="${LOCATION:-eastus}"
RG_NET="rg-net-${ENVIRONMENT}"
VNET_NAME="vnet-${ENVIRONMENT}"

if ! az network vnet show -g "$RG_NET" -n "$VNET_NAME" >/dev/null 2>&1; then
  az network vnet create -g "$RG_NET" -n "$VNET_NAME" -l "$LOCATION" \
    --address-prefixes 10.40.0.0/16 --subnet-name snet-web --subnet-prefixes 10.40.1.0/24 >/dev/null
fi

if ! az network vnet subnet show -g "$RG_NET" --vnet-name "$VNET_NAME" -n snet-app >/dev/null 2>&1; then
  az network vnet subnet create -g "$RG_NET" --vnet-name "$VNET_NAME" -n snet-app --address-prefixes 10.40.2.0/24 >/dev/null
fi
if ! az network vnet subnet show -g "$RG_NET" --vnet-name "$VNET_NAME" -n snet-data >/dev/null 2>&1; then
  az network vnet subnet create -g "$RG_NET" --vnet-name "$VNET_NAME" -n snet-data --address-prefixes 10.40.3.0/24 >/dev/null
fi

if ! az network nsg show -g "$RG_NET" -n "nsg-web-${ENVIRONMENT}" >/dev/null 2>&1; then
  az network nsg create -g "$RG_NET" -n "nsg-web-${ENVIRONMENT}" >/dev/null
fi
if ! az network nsg rule show -g "$RG_NET" --nsg-name "nsg-web-${ENVIRONMENT}" -n allow-https >/dev/null 2>&1; then
  az network nsg rule create -g "$RG_NET" --nsg-name "nsg-web-${ENVIRONMENT}" -n allow-https \
    --priority 100 --direction Inbound --access Allow --protocol Tcp \
    --source-address-prefixes Internet --destination-port-ranges 443 >/dev/null
fi

if ! az network public-ip show -g "$RG_NET" -n "pip-nat-${ENVIRONMENT}" >/dev/null 2>&1; then
  az network public-ip create -g "$RG_NET" -n "pip-nat-${ENVIRONMENT}" --sku Standard >/dev/null
fi
if ! az network nat gateway show -g "$RG_NET" -n "nat-${ENVIRONMENT}" >/dev/null 2>&1; then
  az network nat gateway create -g "$RG_NET" -n "nat-${ENVIRONMENT}" --public-ip-addresses "pip-nat-${ENVIRONMENT}" >/dev/null
fi
az network vnet subnet update -g "$RG_NET" --vnet-name "$VNET_NAME" -n snet-app --nat-gateway "nat-${ENVIRONMENT}"

echo "Networking baseline created"
