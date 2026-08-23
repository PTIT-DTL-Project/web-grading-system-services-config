# course-service Helm Chart

Helm chart for deploying course-service to Kubernetes.

## Installation

```bash
helm install course-service . -f values-stg.yaml -n web-grading
```

## Configuration

Edit `values-stg.yaml` to customize:
- Image tag version
- Resource limits
- Environment-specific settings

## Upgrade

```bash
helm upgrade course-service . -f values-stg.yaml -n web-grading
```
