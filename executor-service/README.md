# executor-service Helm Chart

Helm chart for deploying executor-service to Kubernetes.

## Installation

```bash
helm install executor-service . -f values-stg.yaml -n web-grading
```

## Configuration

Edit `values-stg.yaml` to customize:
- Image tag version
- Resource limits
- Environment-specific settings

## Upgrade

```bash
helm upgrade executor-service . -f values-stg.yaml -n web-grading
```
