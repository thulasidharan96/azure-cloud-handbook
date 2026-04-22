# 03 - Networking

## Virtual Network (CIDR Planning)
### Explanation
Private IP boundary for workload segmentation.
### Real-World Use Case
Three-tier app with web/app/data segmentation and private data access.
### Azure CLI Commands
```bash
az network vnet create -g rg-net-prod -n vnet-prod -l eastus \
  --address-prefixes 10.20.0.0/16 --subnet-name snet-web --subnet-prefixes 10.20.1.0/24
az network vnet subnet create -g rg-net-prod --vnet-name vnet-prod -n snet-app --address-prefixes 10.20.2.0/24
az network vnet subnet create -g rg-net-prod --vnet-name vnet-prod -n snet-data --address-prefixes 10.20.3.0/24
```
### Best Practices
- Reserve CIDR growth space.
- Prevent overlap with on-prem/peer VNets.
### Security Considerations
- Default deny inbound.
- Segment east-west traffic paths.
### Pricing Tier Overview
VNet itself is free; billed features include egress, peering, firewall, NAT.

## Public vs Private Subnets
### Explanation
Public ingress should terminate at controlled edges; app/data remain private.
### Real-World Use Case
App Gateway public, backend services internal only.
### Azure CLI Commands
```bash
az network public-ip create -g rg-net-prod -n pip-agw --sku Standard
```
### Best Practices
- Keep data subnets private only.
### Security Considerations
- No direct internet exposure to app/data tiers.
### Pricing Tier Overview
Public IP and edge services billed by SKU/usage.

## NSG
### Explanation
Layer-4 access control at NIC/subnet.
### Real-World Use Case
Allow HTTPS in web tier; deny all else.
### Azure CLI Commands
```bash
az network nsg create -g rg-net-prod -n nsg-web
az network nsg rule create -g rg-net-prod --nsg-name nsg-web -n allow-443 \
  --priority 100 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes Internet --destination-port-ranges 443
```
### Best Practices
- Prioritized least-access rules.
### Security Considerations
- Enable flow logs and review.
### Pricing Tier Overview
NSG control plane free; logging/storage incurs cost.

## Azure Firewall
### Explanation
Centralized L3-L7 filtering and egress control.
### Real-World Use Case
Single controlled egress for AKS and VM subnets.
### Azure CLI Commands
```bash
az network firewall create -g rg-net-prod -n fw-prod -l eastus
```
### Best Practices
- Use policy-based management and threat intelligence mode.
### Security Considerations
- Force-tunnel outbound paths.
### Pricing Tier Overview
Basic/Standard/Premium; Premium adds TLS inspection and IDPS.

## Application Gateway
### Explanation
Layer-7 ingress, TLS termination, WAF.
### Real-World Use Case
Path-based routing for frontend and API endpoints.
### Azure CLI Commands
```bash
az network application-gateway create -g rg-net-prod -n agw-prod -l eastus \
  --sku WAF_v2 --capacity 2 --vnet-name vnet-prod --subnet snet-web --public-ip-address pip-agw
```
### Best Practices
- Use WAF_v2 with autoscaling.
### Security Considerations
- Enable WAF policies and TLS 1.2+.
### Pricing Tier Overview
Billed per gateway hour + capacity units.

## Load Balancer
### Explanation
L4 distribution for TCP/UDP workloads.
### Real-World Use Case
Distribute traffic to VMSS backend pool.
### Azure CLI Commands
```bash
az network lb create -g rg-net-prod -n lb-prod --sku Standard \
  --public-ip-address pip-lb --frontend-ip-name fe --backend-pool-name be
```
### Best Practices
- Prefer Standard SKU.
### Security Considerations
- Restrict inbound with NSGs.
### Pricing Tier Overview
Standard LB billed by rules/data processing.

## Private Endpoint
### Explanation
Private IP access to PaaS services.
### Real-World Use Case
Private SQL access from AKS only.
### Azure CLI Commands
```bash
az network private-endpoint create -g rg-net-prod -n pe-sql \
  --vnet-name vnet-prod --subnet snet-data \
  --private-connection-resource-id <SQL_RESOURCE_ID> \
  --group-id sqlServer --connection-name pe-sql-conn
```
### Best Practices
- Pair with private DNS zones.
### Security Considerations
- Disable public network access on target service.
### Pricing Tier Overview
Billed per private endpoint + data processing.

## NAT Gateway
### Explanation
Deterministic outbound public IP for private subnets.
### Real-World Use Case
Allowlisted outbound integrations for backend services.
### Azure CLI Commands
```bash
az network public-ip create -g rg-net-prod -n pip-nat --sku Standard
az network nat gateway create -g rg-net-prod -n nat-prod --public-ip-addresses pip-nat
az network vnet subnet update -g rg-net-prod --vnet-name vnet-prod -n snet-app --nat-gateway nat-prod
```
### Best Practices
- Attach NAT to private app subnets.
### Security Considerations
- Use with firewall for layered control.
### Pricing Tier Overview
Hourly NAT charge + processed data.

## DNS (Public and Private)
### Explanation
Name resolution for public and private endpoints.
### Real-World Use Case
Private DNS for `privatelink.database.windows.net`.
### Azure CLI Commands
```bash
az network dns zone create -g rg-net-prod -n contoso.com
az network private-dns zone create -g rg-net-prod -n privatelink.database.windows.net
```
### Best Practices
- Centralize private DNS and link VNets.
### Security Considerations
- Use split-horizon carefully.
### Pricing Tier Overview
Charges per hosted zone and DNS queries.

## Zero Trust Networking
- Verify identity + device + context.
- Default deny and micro-segment subnets.
- Inspect and log east-west and egress traffic.
- Prefer private connectivity by default.
