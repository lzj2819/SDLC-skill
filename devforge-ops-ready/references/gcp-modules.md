# GCP Resource Mapping

## Compute
| Architecture Module | GCP Resource | Notes |
|---------------------|--------------|-------|
| Entry-point module | Cloud Run / GKE | Cloud Run for simple, GKE for complex |
| Internal service | Cloud Run (internal) | VPC connector |
| Background worker | Cloud Run Jobs + Pub/Sub | |

## Database
| StateModel Location | GCP Resource | Notes |
|---------------------|--------------|-------|
| PostgreSQL | Cloud SQL PostgreSQL | High availability for prod |
| MySQL | Cloud SQL MySQL | |
| Redis | Memorystore Redis | |
| Firestore | Firestore Native | |

## Storage
| Use Case | GCP Resource |
|----------|--------------|
| Static assets | Cloud Storage + Cloud CDN |
| Backups | Cloud Storage (Nearline) |
| Logs | Cloud Logging |

## Network
- VPC with subnets
- Cloud NAT for private egress
- Cloud Armor for WAF
- Cloud Load Balancing for ingress
