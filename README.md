# Azure CLI Commands & Architecture – Complete A to Z Guide

> A production-ready Azure field guide for developers, DevOps engineers, and cloud architects.

## Table of Contents
- [1) Azure CLI Installation](#1-azure-cli-installation)
- [2) Core Azure Structure](#2-core-azure-structure)
- [3) Networking (Very Detailed)](#3-networking-very-detailed)
- [4) Identity & Security](#4-identity--security)
- [5) Compute Services](#5-compute-services)
- [6) App Hosting](#6-app-hosting)
- [7) Storage](#7-storage)
- [8) AI & ML](#8-ai--ml)
- [9) Integration Services](#9-integration-services)
- [10) Monitoring](#10-monitoring)
- [11) CI/CD & DevOps](#11-cicd--devops)
- [12) Pricing & Cost Optimization](#12-pricing--cost-optimization)
- [13) Full Production Architecture](#13-full-production-architecture)
- [14) Security Best Practices](#14-security-best-practices)
- [15) Advanced Topics](#15-advanced-topics)

---

## 1) Azure CLI Installation

### Install Azure CLI

#### Windows (PowerShell)
```powershell
winget install -e --id Microsoft.AzureCLI
```

#### Windows (MSI)
- Download and install MSI: https://aka.ms/installazurecliwindows

#### macOS (Homebrew)
```bash
brew update && brew install azure-cli
```

#### Linux (APT - Ubuntu/Debian)
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

#### Linux (YUM - RHEL/CentOS)
```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
sudo dnf install -y azure-cli
```

#### Docker option
```bash
docker run -it mcr.microsoft.com/azure-cli az version
```

### Common CLI commands
```bash
az version
az upgrade
az login
az login --use-device-code
az account list -o table
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
```

### Authentication flow
- **Interactive user login** (`az login`): best for local/admin operations.
- **Device code login** (`az login --use-device-code`): useful on jump boxes/no browser.
- **Service Principal** (automation): non-human identity with scoped RBAC.
- **Managed Identity**: secretless auth from Azure-hosted resources.

### Service principal login
```bash
az ad sp create-for-rbac \
  --name "sp-azops-prod" \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>

az login --service-principal \
  --username "<APP_ID>" \
  --password "<CLIENT_SECRET>" \
  --tenant "<TENANT_ID>"
```

### Managed identity usage
```bash
# From Azure VM/ACI/AKS pod with managed identity enabled
az login --identity
az account show
```

**Best practices**
- Use managed identity over secrets whenever possible.
- Scope SP permissions to RG/resource level.
- Rotate credentials and prefer certificates over client secrets.

---

## 2) Core Azure Structure

### Hierarchy

```text
Tenant (Microsoft Entra ID)
└── Management Groups
    └── Subscriptions
        └── Resource Groups
            └── Resources (VM, AKS, VNet, KV, DB, etc.)
```

### Concepts
- **Management Groups**: governance boundaries (policy, RBAC inheritance).
- **Subscriptions**: billing and quota boundary.
- **Resource Groups**: lifecycle boundary for related resources.
- **Resources**: deployable service instances.

### CLI
```bash
az group create --name rg-platform-prod --location eastus
az resource list --resource-group rg-platform-prod -o table
az group delete --name rg-platform-prod --yes --no-wait
```

**Use case**: Separate subscriptions for `prod`, `nonprod`, and `sandbox`; per-app resource groups for blast-radius control.

**Security & governance**
- Apply Azure Policy at management group scope.
- Use resource locks for critical resources.

---

## 3) Networking (Very Detailed)

### 3.1 Virtual Network (VNet)
**Explanation**: Private network boundary in Azure.

**Real-world use case**: Multi-tier app with separate web/app/data subnets.

```bash
az network vnet create \
  --resource-group rg-net-prod \
  --name vnet-prod-eastus \
  --location eastus \
  --address-prefixes 10.10.0.0/16 \
  --subnet-name snet-web \
  --subnet-prefixes 10.10.1.0/24
```

**CIDR planning best practices**
- Reserve growth space (e.g., /16 for platform VNets).
- Avoid overlap across regions/on-prem for peering/VPN/ER.
- Keep dedicated subnets for firewall, gateways, and private endpoints.

**Pricing tier overview**: VNet itself has no hourly charge; billed components include egress, NAT Gateway, Firewall, peering traffic.

**Security considerations**
- Default deny inbound.
- Route internet-bound traffic through controlled egress (NAT/FW).

### 3.2 Public vs Private subnet
- **Public subnet**: workloads reachable from internet (usually via LB/App Gateway only).
- **Private subnet**: no public IP; access via private endpoints, bastion, or internal load balancer.

### 3.3 Subnets (delegation + service endpoints)
```bash
az network vnet subnet create \
  --resource-group rg-net-prod \
  --vnet-name vnet-prod-eastus \
  --name snet-app \
  --address-prefixes 10.10.2.0/24

az network vnet subnet update \
  --resource-group rg-net-prod \
  --vnet-name vnet-prod-eastus \
  --name snet-app \
  --delegations Microsoft.Web/serverFarms

az network vnet subnet update \
  --resource-group rg-net-prod \
  --vnet-name vnet-prod-eastus \
  --name snet-app \
  --service-endpoints Microsoft.Storage Microsoft.Sql
```

**Best practices**: Prefer **Private Endpoints** over service endpoints for higher isolation.

### 3.4 Network Security Groups (NSG)
```bash
az network nsg create -g rg-net-prod -n nsg-app

az network nsg rule create \
  -g rg-net-prod --nsg-name nsg-app \
  -n allow-https-inbound \
  --priority 100 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes Internet --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 443

az network nsg rule create \
  -g rg-net-prod --nsg-name nsg-app \
  -n deny-all-inbound \
  --priority 4096 --direction Inbound --access Deny --protocol '*' \
  --source-address-prefixes '*' --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges '*'
```

**Security**: enforce least-access by source CIDR/ASG; log NSG flow logs.

### 3.5 Azure Firewall
```bash
az network firewall create -g rg-net-prod -n fw-prod -l eastus
```

**Use case**: centralized L3-L7 egress filtering, DNAT/SNAT, threat intelligence.

**Pricing**: Standard/Premium (Premium adds TLS inspection, IDPS).

### 3.6 Application Gateway (WAF)
```bash
az network application-gateway create \
  -g rg-net-prod -n agw-prod -l eastus \
  --sku WAF_v2 --capacity 2 \
  --vnet-name vnet-prod-eastus --subnet snet-web \
  --public-ip-address pip-agw-prod
```

**Use case**: HTTPS termination, path-based routing, WAF for OWASP protection.

### 3.7 Load Balancer
```bash
az network lb create \
  -g rg-net-prod -n lb-public-prod -l eastus \
  --sku Standard --public-ip-address pip-lb-prod \
  --frontend-ip-name fe-public --backend-pool-name be-pool
```

**Use case**: L4 load balancing for VMs/VMSS.

### 3.8 Private Endpoint
```bash
az network private-endpoint create \
  -g rg-net-prod -n pe-sql-prod \
  --vnet-name vnet-prod-eastus --subnet snet-private-endpoints \
  --private-connection-resource-id <SQL_RESOURCE_ID> \
  --group-id sqlServer --connection-name pe-sql-conn
```

**Security**: disable public network access on PaaS after private endpoint setup.

### 3.9 NAT Gateway
```bash
az network public-ip create -g rg-net-prod -n pip-nat-prod --sku Standard
az network nat gateway create -g rg-net-prod -n nat-prod --public-ip-addresses pip-nat-prod
az network vnet subnet update -g rg-net-prod --vnet-name vnet-prod-eastus -n snet-app --nat-gateway nat-prod
```

**Use case**: deterministic outbound IP for private workloads.

### 3.10 DNS (Public + Private)
```bash
# Public DNS zone
az network dns zone create -g rg-net-prod -n contoso.com

# Private DNS zone
az network private-dns zone create -g rg-net-prod -n privatelink.database.windows.net
az network private-dns link vnet create \
  -g rg-net-prod -n link-prod \
  -z privatelink.database.windows.net \
  -v /subscriptions/<SUB>/resourceGroups/rg-net-prod/providers/Microsoft.Network/virtualNetworks/vnet-prod-eastus \
  -e true
```

### Secure architecture pattern (network)

```text
Internet
  |
[Application Gateway + WAF]
  |
[Web Subnet] -> [App Subnet] -> [Data Subnet]
                 |              |
             [NAT GW]       [Private Endpoints]
                 \            /
                [Azure Firewall]
```

### Zero Trust networking checklist
- Verify explicitly (identity + device + context).
- Use least-privilege network rules.
- Assume breach: segment and inspect east-west traffic.
- Prefer private connectivity and deny public exposure by default.

---

## 4) Identity & Security

### Azure RBAC
- **Owner**: full access + role assignment.
- **Contributor**: manage resources, no RBAC assignment.
- **Reader**: view-only.

```bash
az role assignment create \
  --assignee <PRINCIPAL_ID_OR_UPN> \
  --role Reader \
  --scope /subscriptions/<SUB_ID>/resourceGroups/rg-app-prod
```

### Custom role
```bash
az role definition create --role-definition @custom-role.json
```

### Entra ID objects
- Users, groups for human access.
- Service principals for automation.
- Managed identities for Azure-native workloads.

```bash
az ad sp create-for-rbac --name sp-cicd-prod --role Contributor --scopes /subscriptions/<SUB_ID>
```

### Key Vault
```bash
az keyvault create -g rg-sec-prod -n kv-prod-eastus -l eastus --enable-rbac-authorization true
az keyvault secret set --vault-name kv-prod-eastus --name db-password --value "<secret>"
```

**Secret rotation strategy**
- Rotate every 30/60/90 days based on risk.
- Use versioned secrets and staged rollout.
- Automate rotation with Functions/Automation + alerts.

**Least privilege model**
- Group-based access assignment.
- JIT/PIM for privileged roles.
- Separate control plane and data plane permissions.

**Pricing**: Key Vault Standard/Premium (Premium for HSM-backed keys).

**Security**
- Enable soft delete + purge protection.
- Restrict vault network access (private endpoint).

---

## 5) Compute Services

| Service | Use case | Key CLI | Scaling strategy | Cost considerations | Security |
|---|---|---|---|---|---|
| Virtual Machines | Legacy/custom workloads, full OS control | `az vm create` | VM resize, autoscale via VMSS patterns | Pay-as-you-go, Reserved Instances, Spot | Harden OS, disable password auth, JIT access |
| VM Scale Sets | Stateless VM fleets | `az vmss create` | Autoscale rules by CPU/queue/custom metrics | Better unit economics at scale; Spot for batch | NSG + managed identity + image patching |
| AKS | Container orchestration/microservices | `az aks create` | HPA, Cluster Autoscaler, KEDA | Node pool mix (system/user), spot pools, reserved compute | Private cluster, RBAC/Entra, network policies |
| ACI | Burst jobs, ephemeral containers | `az container create` | Horizontal fan-out by job count | Per-second billing, no cluster overhead | VNet injection + managed identity |

### Sample CLI
```bash
# VM
az vm create -g rg-compute-prod -n vm-jump-prod --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys

# VMSS
az vmss create -g rg-compute-prod -n vmss-web-prod --image Ubuntu2204 --instance-count 2 --upgrade-policy-mode automatic

# AKS
az aks create -g rg-compute-prod -n aks-prod --node-count 3 --enable-managed-identity --network-plugin azure
az aks get-credentials -g rg-compute-prod -n aks-prod

# ACI
az container create -g rg-compute-prod -n aci-job-prod --image mcr.microsoft.com/azuredocs/aci-helloworld --cpu 1 --memory 1.5
```

---

## 6) App Hosting

### App Service
- Best for web apps/APIs needing managed PaaS.
- Plans: Free, Shared, Basic, Standard, PremiumV3/V4, Isolated.

```bash
az appservice plan create -g rg-app-prod -n plan-app-prod --sku P1v3 --is-linux
az webapp create -g rg-app-prod -p plan-app-prod -n webapp-prod-contoso --runtime "DOTNET:8"
```

### Function App
- Event-driven/serverless workloads.
- Plans: Consumption, Premium, Dedicated.

```bash
az functionapp create \
  -g rg-app-prod -n func-prod-contoso \
  --storage-account stprodcontoso \
  --consumption-plan-location eastus \
  --runtime python --functions-version 4
```

### Static Web Apps
- Frontend + API integration + global edge hosting.

```bash
az staticwebapp create \
  -n swa-prod-contoso -g rg-app-prod \
  --source https://github.com/<org>/<repo> \
  --location eastus2 --branch main --app-location "/" --output-location "build"
```

**When to use what**
- **App Service**: enterprise web/API, private networking, deployment slots.
- **Functions**: asynchronous/event jobs with variable load.
- **SWA**: SPA/static frontend with low operational overhead.

---

## 7) Storage

### Storage Account (Blob, File, Queue, Table)
```bash
az storage account create \
  -g rg-data-prod -n stprodcontoso \
  -l eastus --sku Standard_GRS --kind StorageV2 \
  --min-tls-version TLS1_2 --allow-blob-public-access false
```

### Access tiers
- **Hot**: frequent access.
- **Cool**: infrequent, lower storage cost/higher access cost.
- **Archive**: long-term retention, rehydration required.

### Lifecycle policy
```bash
az storage account management-policy create \
  --account-name stprodcontoso \
  --resource-group rg-data-prod \
  --policy @lifecycle-policy.json
```

**Best practices**
- Use private endpoints.
- Enable versioning + soft delete.
- Use immutable policies for compliance workloads.

**Pricing**: Standard/Premium, redundancy (LRS/ZRS/GRS/GZRS) drives cost/resilience.

---

## 8) AI & ML

| Service | Best for | CLI setup | Pricing overview | Security considerations |
|---|---|---|---|---|
| Azure Machine Learning | ML lifecycle (train, deploy, MLOps) | `az extension add -n ml` + `az ml workspace create` | Compute + storage + endpoints | Private link workspace, managed identity, data encryption |
| Cognitive Services (AI Services) | Vision, speech, language APIs | `az cognitiveservices account create` | Per-transaction / SKU-based | Restrict network, rotate keys, use AAD auth where available |
| Azure OpenAI Service | GPT models, embeddings, copilots | `az cognitiveservices account create --kind OpenAI` | Token-based usage + model tier | Content filters, private networking, RBAC + key hygiene |

### CLI examples
```bash
az extension add -n ml
az ml workspace create -g rg-ai-prod -n aml-prod --location eastus

az cognitiveservices account create \
  -g rg-ai-prod -n cs-prod-language \
  --kind TextAnalytics --sku S --location eastus --yes

az cognitiveservices account create \
  -g rg-ai-prod -n aoai-prod \
  --kind OpenAI --sku S0 --location eastus --yes
```

---

## 9) Integration Services

### Real-world pattern
- API consumers -> APIM -> backend services (AKS/App Service)
- Events via Event Grid
- Reliable async workflows via Service Bus
- Business process orchestration via Logic Apps

```text
Clients -> APIM -> Microservices
              |        |
          Event Grid   Service Bus
              \        /
              Logic Apps
```

### CLI
```bash
# API Management
az apim create -g rg-int-prod -n apim-prod-contoso --publisher-name "Contoso" --publisher-email "ops@contoso.com" --sku-name Developer --location eastus

# Event Grid topic
az eventgrid topic create -g rg-int-prod -n eg-topic-prod -l eastus

# Service Bus namespace + queue
az servicebus namespace create -g rg-int-prod -n sb-prod-contoso -l eastus --sku Standard
az servicebus queue create -g rg-int-prod --namespace-name sb-prod-contoso -n orders

# Logic App (Consumption)
az logic workflow create -g rg-int-prod -n la-order-orchestrator -l eastus
```

**Security**
- APIM with OAuth2/JWT validation.
- Private endpoints for Service Bus/APIM internal mode.
- Use managed identity for connector authentication.

---

## 10) Monitoring

### Services
- **Azure Monitor**: metrics, alerts, diagnostics.
- **Log Analytics**: centralized logs + KQL.
- **Application Insights**: APM for apps.

### CLI examples
```bash
az monitor log-analytics workspace create -g rg-ops-prod -n law-prod-eastus -l eastus

az monitor app-insights component create \
  -g rg-ops-prod -a appi-web-prod \
  -l eastus --workspace /subscriptions/<SUB>/resourceGroups/rg-ops-prod/providers/Microsoft.OperationalInsights/workspaces/law-prod-eastus

az monitor metrics alert create \
  -g rg-ops-prod -n cpu-high-alert \
  --scopes <RESOURCE_ID> \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m --evaluation-frequency 1m
```

**Best practices**
- Centralize diagnostics in one workspace per environment/region strategy.
- Define SLI/SLO and actionable alerts only.

---

## 11) CI/CD & DevOps

### GitHub Actions + Azure (OIDC recommended)
- Use workload identity federation (no long-lived secret).
- Deploy IaC + app in separate stages.

### CLI deployment examples
```bash
# ARM/Bicep deployment
az deployment group create \
  --resource-group rg-app-prod \
  --template-file main.bicep \
  --parameters @prod.parameters.json

# Web app deployment (zip)
az webapp deployment source config-zip \
  -g rg-app-prod -n webapp-prod-contoso \
  --src app.zip
```

**Best practices**
- Mandatory PR checks, drift detection, and environment approvals.
- Signed artifacts and SBOM for supply-chain security.

---

## 12) Pricing & Cost Optimization

> Pricing varies by region, usage, redundancy, and reservation terms. Validate with Azure Pricing Calculator.

| Service | Common tiers/SKUs | Choose when | Cost-saving tips |
|---|---|---|---|
| App Service | Free/Basic/Standard/Premium/Isolated | Enterprise web/API hosting | Autoscale, right-size plan, reserved capacity for steady workloads |
| Functions | Consumption/Premium/Dedicated | Event workloads; Premium for VNet/low-latency | Optimize execution time, avoid over-provisioning |
| AKS | Control plane + node VM cost | Containerized microservices | Cluster autoscaler, spot pools, schedule non-prod shutdown |
| VM/VMSS | B-series/D/E/F etc. | Full OS control or legacy stack | Reserved Instances, Spot, Azure Hybrid Benefit |
| Storage | Standard/Premium + LRS/ZRS/GRS/GZRS | Object/file/queue/table | Lifecycle tiering, compression, delete stale data |
| SQL/DB services | DTU/vCore, serverless/provisioned | Transactional data | Use serverless for intermittent workloads |
| APIM | Consumption/Developer/Basic/Standard/Premium | API gateway governance | Use right tier per env, keep Developer in non-prod |
| Azure Firewall | Basic/Standard/Premium | Centralized network security | Consolidate egress, tune rules to reduce unnecessary traffic |
| Monitor/Logs | Ingestion + retention model | Observability at scale | Control log volume, archive old logs, set retention policy |

---

## 13) Full Production Architecture

### Reference architecture
- **Frontend**: App Service
- **Backend**: AKS
- **Database**: Azure SQL
- **Cache**: Azure Cache for Redis
- **Secrets**: Key Vault
- **Networking**: Private VNet + Private Endpoints + WAF

```text
Users
  |
[Azure Front Door/CDN]
  |
[Application Gateway (WAF)]
  |
[App Service (Frontend)]
  |
[AKS (Backend APIs)]
  |         |         |
  |       [Redis]  [Key Vault]
  |         |         |
   --------[Private Endpoints]--------
                  |
             [Azure SQL]
                  |
            [Log Analytics + App Insights]
```

### Deployment CLI (sample sequence)
```bash
# 1) Resource groups
az group create -n rg-net-prod -l eastus
az group create -n rg-app-prod -l eastus
az group create -n rg-data-prod -l eastus

# 2) Network
az network vnet create -g rg-net-prod -n vnet-prod --address-prefixes 10.20.0.0/16 --subnet-name snet-app --subnet-prefixes 10.20.1.0/24
az network vnet subnet create -g rg-net-prod --vnet-name vnet-prod -n snet-pe --address-prefixes 10.20.2.0/24

# 3) Key Vault
az keyvault create -g rg-app-prod -n kv-prod-contoso -l eastus --enable-rbac-authorization true

# 4) App Service
az appservice plan create -g rg-app-prod -n plan-prod --sku P1v3 --is-linux
az webapp create -g rg-app-prod -p plan-prod -n webapp-frontend-prod --runtime "NODE:20-lts"

# 5) AKS
az aks create -g rg-app-prod -n aks-backend-prod --node-count 3 --enable-managed-identity --network-plugin azure

# 6) SQL (logical server + db)
az sql server create -g rg-data-prod -n sql-prod-contoso --admin-user sqladminuser --admin-password "<StrongPassword>"
az sql db create -g rg-data-prod -s sql-prod-contoso -n appdb --service-objective GP_S_Gen5_2

# 7) Redis
az redis create -g rg-data-prod -n redis-prod-contoso -l eastus --sku Premium --vm-size P1
```

**Production notes**
- Enforce private access for SQL/Redis/Key Vault.
- Add backup/DR and multi-region strategy.
- Use IaC (Bicep/Terraform) for repeatability.

---

## 14) Security Best Practices

- Adopt **Zero Trust** (never trust, always verify).
- Use **private endpoints everywhere feasible**.
- Disable public DB endpoints; enforce private DNS resolution.
- Strict RBAC with least privilege and PIM.
- Centralized secrets in Key Vault; no plaintext secrets in repos.
- Enforce policy-as-code (Azure Policy) for guardrails.
- Enable Defender for Cloud and remediate high-severity findings.
- Encrypt at rest and in transit; TLS1.2+ minimum.
- Continuous patching and vulnerability scanning.
- Full audit logging to immutable storage where required.

---

## 15) Advanced Topics

### Blue/Green deployment
- Two identical environments (`blue`, `green`), switch traffic after validation.
- App Service: deployment slots; AKS: ingress-based switch.

### Canary releases
- Roll out to small traffic subset first (5% -> 25% -> 100%).
- Use metrics/error budget gates for progression.

### Multi-region failover
- Active-passive or active-active.
- Use Front Door/Traffic Manager + geo-redundant data services.

### Infrastructure as Code
- **Bicep**: native Azure, concise ARM abstraction.
- **Terraform**: multi-cloud and strong ecosystem.
- Keep modules reusable, versioned, and policy-validated in CI.

---

## Operational Checklist (Go-Live)

- [ ] Landing zone and management group governance implemented
- [ ] RBAC least privilege + PIM configured
- [ ] Private networking and DNS patterns validated
- [ ] Backup, DR, and failover tested
- [ ] Monitoring, alerting, and SLOs established
- [ ] CI/CD with gated approvals and security scans enabled
- [ ] Cost budgets + alerts configured
- [ ] Runbook and incident response ownership defined

