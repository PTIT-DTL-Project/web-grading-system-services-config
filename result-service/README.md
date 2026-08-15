# result-service Helm Chart

Helm chart for deploying result-service to Kubernetes.

## Installation

```bash
helm install result-service . -f values-stg.yaml -n web-grading
```

## Configuration

Edit `values-stg.yaml` to customize:
- Image tag version
- Resource limits
- Environment-specific settings

## Upgrade

```bash
helm upgrade result-service . -f values-stg.yaml -n web-grading
```
