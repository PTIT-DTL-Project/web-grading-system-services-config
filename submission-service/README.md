# submission-service Helm Chart

Helm chart for deploying submission-service to Kubernetes.

## Installation

```bash
helm install submission-service . -f values-stg.yaml -n web-grading
```

## Configuration

Edit `values-stg.yaml` to customize:
- Image tag version
- Resource limits
- Environment-specific settings

## Upgrade

```bash
helm upgrade submission-service . -f values-stg.yaml -n web-grading
```
