# Azure CLI Commands & Architecture – Complete A to Z Guide

Production-focused Azure architecture handbook, DevOps toolkit, and zero-to-production deployment reference.

## 1) Overview

### What this repo is
`azure-architect-playbook` is a production-ready reference system that combines:
- Architecture decision guidance
- Azure CLI execution playbooks
- Deployment scripts
- Real deployment examples
- CI/CD automation patterns

### Why it exists
Most cloud guides stop at basics. This repository is designed to support real delivery teams with standardized commands, security-first defaults, and operational architecture patterns.

### Who it is for
- Cloud architects
- DevOps/SRE engineers
- Platform engineers
- Full-stack teams deploying on Azure

---

## 2) Quick Start

### Install Azure CLI

#### Windows
```powershell
winget install -e --id Microsoft.AzureCLI
```

#### macOS
```bash
brew update && brew install azure-cli
```

#### Linux (Ubuntu/Debian)
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

#### Docker
```bash
docker run -it mcr.microsoft.com/azure-cli az version
```

### Login and set subscription
```bash
az login
az account list -o table
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
```

### Create first resource group
```bash
az group create --name rg-playbook-dev --location eastus
```

---

## 3) Core Azure Structure

```text
Tenant (Microsoft Entra ID)
└── Management Groups
    └── Subscriptions
        └── Resource Groups
            └── Resources
```

### Core commands
```bash
az group create --name rg-platform-prod --location eastus
az resource list --resource-group rg-platform-prod -o table
```

---

## 4) Playbook Index

- [docs/01-cli-basics.md](docs/01-cli-basics.md)
- [docs/02-core-structure.md](docs/02-core-structure.md)
- [docs/03-networking.md](docs/03-networking.md)
- [docs/04-security-rbac.md](docs/04-security-rbac.md)
- [docs/05-compute.md](docs/05-compute.md)
- [docs/06-app-services.md](docs/06-app-services.md)
- [docs/07-storage.md](docs/07-storage.md)
- [docs/08-ai-ml.md](docs/08-ai-ml.md)
- [docs/09-integration.md](docs/09-integration.md)
- [docs/10-monitoring.md](docs/10-monitoring.md)
- [docs/11-devops.md](docs/11-devops.md)
- [docs/12-cost.md](docs/12-cost.md)
- [docs/13-architecture.md](docs/13-architecture.md)
- [docs/14-advanced.md](docs/14-advanced.md)

---

## 5) Security Baseline (Mandatory)

- Zero Trust: verify explicitly, least privilege, assume breach
- Private endpoints for data-plane services
- No public database endpoints
- Managed identity-first authentication
- Strict RBAC + PIM for elevation
- Centralized secrets in Key Vault

---

## 6) Deployment Toolkit

### Scripts
- `scripts/setup.sh` – resource group and baseline provisioning
- `scripts/auth.sh` – login and service principal setup
- `scripts/networking.sh` – VNet, subnets, NSG, NAT, firewall placeholders
- `scripts/security.sh` – RBAC, Key Vault, secret scaffolding
- `scripts/compute.sh` – VM/VMSS/AKS/ACI creation
- `scripts/deploy-app.sh` – App Service deployment flow

### Infrastructure as Code
- `infra/bicep/` – Bicep templates
- `infra/terraform/` – Terraform templates

### CI/CD
- `.github/workflows/ci.yml` – build/test/deploy workflow with dev/staging/prod, approvals, rollback strategy outline, and version tagging.

---

## 7) Zero → Production Path

1. Authenticate (`scripts/auth.sh`)
2. Create baseline (`scripts/setup.sh`)
3. Build networking (`scripts/networking.sh`)
4. Apply security (`scripts/security.sh`)
5. Provision compute (`scripts/compute.sh`)
6. Deploy app (`scripts/deploy-app.sh`)
7. Promote through environments via GitHub Actions

---

## 8) Pricing Reference

| Service Area | Entry Tier | Production Tier | Notes |
|---|---|---|---|
| App Hosting | B1 / Consumption | P1v3+ / Premium | Scale, networking, and SLA drive tier |
| Compute | Small VM / 1-node AKS | VMSS / multi-node AKS | Use reservations + autoscale |
| Data | Standard LRS | Zone/Geo redundant | Redundancy and IOPS are major cost factors |
| Integration | Developer | Standard/Premium | APIM premium for VNet/internal |
| Security | Standard KV | Premium KV/FW Premium | Private access and policy enforcement increase cost |
| Observability | Basic ingestion | Tuned retention + alerts | Optimize log volume |

Use Azure Pricing Calculator for region-specific values.
