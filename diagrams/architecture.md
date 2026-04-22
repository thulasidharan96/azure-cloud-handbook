# Architecture Diagrams

## Production Reference

```text
Internet
  |
[Front Door]
  |
[Application Gateway (WAF)]
  |
[App Service Frontend]
  |
[AKS Backend] ---- [Redis]
      |              |
      +--- [Key Vault]
             |
      [Private Endpoints]
             |
         [Azure SQL]
             |
[Monitor / Log Analytics / App Insights]
```

## Network Security Pattern

```text
Public Ingress -> WAF Subnet -> App Subnet -> Data Subnet
                          |            |
                     NAT Gateway   Private Endpoints
                          \            /
                         Azure Firewall
```
