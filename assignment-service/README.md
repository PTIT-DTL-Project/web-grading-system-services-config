# assignment-service Helm Chart

Helm chart for deploying assignment-service to Kubernetes.

## Installation

```bash
helm install assignment-service . -f values-stg.yaml -n web-grading
```

## Configuration

Edit `values-stg.yaml` to customize:
- Image tag version
- Resource limits
- Environment-specific settings

## Upgrade

```bash
helm upgrade assignment-service . -f values-stg.yaml -n web-grading
```
