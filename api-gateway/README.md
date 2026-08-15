# api-gateway Helm Chart

Helm chart for deploying api-gateway to Kubernetes.

## Installation

```bash
helm install api-gateway . -f values-stg.yaml -n web-grading
```

## Configuration

Edit `values-stg.yaml` to customize:
- Image tag version
- Resource limits
- Environment-specific settings

## Upgrade

```bash
helm upgrade api-gateway . -f values-stg.yaml -n web-grading
```
