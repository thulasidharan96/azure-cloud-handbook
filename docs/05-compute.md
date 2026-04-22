# 05 - Compute

## Virtual Machines
### Explanation
IaaS compute with full OS control.
### Real-World Use Case
Legacy app migration requiring custom agents.
### Azure CLI Commands
```bash
az vm create -g rg-compute-prod -n vm-app01 --image Ubuntu2204 \
  --admin-username azureuser --generate-ssh-keys
```
### Best Practices
Use hardened images and patch baselines.
### Security Considerations
No password auth; use NSG + JIT access.
### Pricing Tier Overview
Pay-as-you-go, Reserved Instances, Spot options.

## VM Scale Sets
### Explanation
Autoscaling fleet of identical VMs.
### Real-World Use Case
Stateless web API on VM-based architecture.
### Azure CLI Commands
```bash
az vmss create -g rg-compute-prod -n vmss-api --image Ubuntu2204 --instance-count 2
```
### Best Practices
Use autoscale rules and health probes.
### Security Considerations
Managed identity + patch orchestration.
### Pricing Tier Overview
VM pricing with fleet scale economics.

## AKS
### Explanation
Managed Kubernetes for containerized workloads.
### Real-World Use Case
Microservices with HPA and rolling upgrades.
### Azure CLI Commands
```bash
az aks create -g rg-compute-prod -n aks-prod --node-count 3 --enable-managed-identity --network-plugin azure
az aks get-credentials -g rg-compute-prod -n aks-prod
```
### Best Practices
Separate system/user node pools; enable autoscaler.
### Security Considerations
Private cluster, workload identity, network policies.
### Pricing Tier Overview
Control plane tier + worker node VM costs.

## Azure Container Instances
### Explanation
Serverless containers for burst jobs.
### Real-World Use Case
Ephemeral ETL or queue-driven workers.
### Azure CLI Commands
```bash
az container create -g rg-compute-prod -n aci-worker \
  --image mcr.microsoft.com/azuredocs/aci-helloworld --cpu 1 --memory 1.5
```
### Best Practices
Use for short-lived workloads without orchestration overhead.
### Security Considerations
Use VNet integration and managed identity.
### Pricing Tier Overview
Per-second CPU/memory billing.
