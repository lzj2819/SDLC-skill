# AWS Resource Mapping

## Compute
| Architecture Module | AWS Resource | Notes |
|---------------------|--------------|-------|
| Entry-point module | ECS Service + ALB | Or EKS Deployment + Ingress |
| Internal service | ECS Service (private) | No public ALB |
| Background worker | ECS Service + SQS | Event-driven processing |

## Database
| StateModel Location | AWS Resource | Notes |
|---------------------|--------------|-------|
| PostgreSQL | RDS PostgreSQL | Multi-AZ for prod |
| MySQL | RDS MySQL | |
| Redis | ElastiCache Redis | Cluster mode for prod |
| MongoDB | DocumentDB | |

## Storage
| Use Case | AWS Resource |
|----------|--------------|
| Static assets | S3 + CloudFront |
| Backups | S3 ( Glacier for long-term) |
| Logs | CloudWatch Logs |

## Network
- VPC with public + private subnets
- NAT Gateway for outbound from private subnets
- Security Groups per module (least privilege)
- AWS WAF for public-facing ALB
