# config-server Helm Chart

Helm chart for deploying config-server to Kubernetes.

## Installation

```bash
helm install config-server . -f values-stg.yaml -n web-grading
```

## Configuration

Edit `values-stg.yaml` to customize:
- Image tag version
- Resource limits
- Environment-specific settings

## Upgrade

```bash
helm upgrade config-server . -f values-stg.yaml -n web-grading
```
