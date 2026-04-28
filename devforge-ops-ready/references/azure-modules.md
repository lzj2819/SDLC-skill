# Azure Resource Mapping

## Compute
| Architecture Module | Azure Resource | Notes |
|---------------------|----------------|-------|
| Entry-point module | Container Apps / AKS | AKS for complex microservices |
| Internal service | Container Apps (internal) | |
| Background worker | Container Instances + Service Bus | |

## Database
| StateModel Location | Azure Resource | Notes |
|---------------------|----------------|-------|
| PostgreSQL | Azure Database for PostgreSQL | Flexible Server |
| MySQL | Azure Database for MySQL | |
| Redis | Azure Cache for Redis | Enterprise tier for cluster |
| SQL Server | Azure SQL Database | |

## Storage
| Use Case | Azure Resource |
|----------|----------------|
| Static assets | Blob Storage + CDN |
| Backups | Blob Storage (Cool tier) |
| Logs | Log Analytics |

## Network
- VNet with subnets
- NSG per subnet
- Azure Firewall for egress control
- Application Gateway for ingress
