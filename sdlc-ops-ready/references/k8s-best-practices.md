# Kubernetes Best Practices

## General
- Use Kustomize for environment management
- One Deployment per microservice module
- Use ConfigMaps for non-secret config, Secrets for sensitive data
- Liveness and Readiness probes on every container
- Resource requests and limits on every container

## Security
- Run containers as non-root
- Use NetworkPolicies for inter-service traffic control
- Enable Pod Security Standards (restricted)
- Use cert-manager for TLS certificates

## Observability
- Prometheus Operator for metrics collection
- Fluentd/Fluent Bit for log aggregation
- Jaeger/Tempo for distributed tracing (if needed)

## Scaling
- HPA based on CPU (target 70%) and memory (target 80%)
- VPA for right-sizing recommendations (optional)
- Cluster Autoscaler for node scaling

## Reliability
- PodDisruptionBudget for critical services
- TopologySpreadConstraints for AZ distribution
- Anti-affinity for stateful services
