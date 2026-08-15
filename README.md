# Web Grading System - Config Mono-Repo

Mono-repository chứa toàn bộ Helm charts và configuration values cho các microservices trong hệ thống Web Grading System.

## 🏗️ Cấu trúc

```
config-services/
├── README.md
├── submission-service/       # Helm chart cho submission service
│   ├── Chart.yaml
│   ├── values-stg.yaml      # Values cho staging
│   ├── values-prod.yaml     # Values cho production (nếu có)
│   └── templates/
│       ├── _helpers.tpl
│       ├── deployment.yaml
│       └── service.yaml
├── executor-service/
│   ├── Chart.yaml
│   ├── values-stg.yaml
│   └── templates/
├── api-gateway/
├── config-server/
├── result-service/
└── assignment-service/
```

## 📝 Quy tắc đặt tên

### Service Names
Tên service phải khớp với tên trong source repo:
- `submission-service`
- `executor-service`
- `api-gateway`
- `config-server`
- `result-service`
- `assignment-service`

### Values Files
- `values-stg.yaml`: Configuration cho staging environment
- `values-prod.yaml`: Configuration cho production environment (optional)

## 🚀 ArgoCD Integration

### Cách hoạt động

1. **Source Repo Build**: Khi code thay đổi, CI/CD build Docker image mới
2. **Auto Update**: Workflow tự động update `image.tag` trong `values-stg.yaml`
3. **ArgoCD Sync**: ArgoCD detect thay đổi và tự động deploy

### ArgoCD Application

Mỗi service có 1 ArgoCD Application trỏ đến chart tương ứng:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: grading-submission-service
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/PTIT-DTL-Project/web-grading-system-config.git
    targetRevision: main
    path: submission-service
    helm:
      valueFiles:
        - values-stg.yaml
```

## 🔧 Values Structure

### Common Values

Tất cả services share cùng cấu trúc values cơ bản:

```yaml
global:
  domain: vucongtuanduong.dpdns.org
  prefix: web-dev1

image:
  registry: docker.io
  repository: vucongtuanduong/web-grading-system-submission-service
  tag: "v1.2.0"
  pullPolicy: Always

spring:
  profilesActive: stg
  dbName: submission_db

service:
  type: ClusterIP
  port: 8082

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 200m
    memory: 256Mi
```

### Service-specific Values

Mỗi service có thể có thêm values riêng, ví dụ:

**submission-service:**
```yaml
rustfs:
  endpoint: http://rustfs:9000
  accessKey: minioadmin
  secretKey: minioadmin
  bucketName: submission-files
```

## 📦 Chart Structure

### Chart.yaml

```yaml
apiVersion: v2
name: submission-service
description: Helm chart for Submission Service
version: 1.0.0
appVersion: "1.0"
```

### Templates

#### deployment.yaml
- Kubernetes Deployment
- Container specs với environment variables
- Resource limits/requests
- Health checks (readiness/liveness probes)

#### service.yaml
- Kubernetes Service (ClusterIP)
- Port mapping

#### _helpers.tpl
- Template helpers cho naming conventions
- Reusable template functions

## 🔄 Update Flow

### Manual Update

```bash
# Clone repo
git clone https://github.com/PTIT-DTL-Project/web-grading-system-config.git
cd web-grading-system-config

# Update version
cd submission-service
# Edit values-stg.yaml, update image.tag

# Commit và push
git add .
git commit -m "Update submission-service to v1.3.0"
git push
```

### Automatic Update (CI/CD)

Được thực hiện tự động bởi source repo workflow khi merge vào `main`.

## 🎯 Services Configuration

### submission-service
- Port: 8082
- Database: submission_db
- Storage: RustFS integration

### executor-service
- Execution environment cho code submissions
- Sandbox configuration

### api-gateway
- Port: 8080
- Gateway chính
- Routing rules

### config-server
- Port: 8888
- Spring Cloud Config Server
- Git backend configuration

### result-service
- Result computation và storage
- Database: result_db

### assignment-service
- Assignment và test case management
- Database: assignment_db

## 🔗 Related Repositories

- **Source Repo**: [web-grading-system-services](https://github.com/PTIT-DTL-Project/web-grading-system-services) - Source code
- **Deploy Repo**: [web-grading-system-deploy](https://github.com/PTIT-DTL-Project/web-grading-system-deploy) - ArgoCD orchestration

## 📚 Best Practices

### Version Management
- Sử dụng semantic versioning: `v1.2.3`
- Tag format: `<service-name>-v<version>`

### Resource Limits
- Set appropriate limits dựa trên load testing
- Monitor và adjust theo actual usage

### Health Checks
- Luôn configure readiness và liveness probes
- InitialDelaySeconds phù hợp với startup time

### Secrets Management
- Không commit secrets vào repo
- Sử dụng Kubernetes Secrets
- Reference secrets qua environment variables

## 🛠️ Development

### Test Helm Chart Locally

```bash
# Validate syntax
helm lint submission-service/

# Dry-run render templates
helm template submission-service submission-service/ -f submission-service/values-stg.yaml

# Install to cluster
helm install submission-service submission-service/ -f submission-service/values-stg.yaml -n web-grading
```

### Debugging

```bash
# Check deployed values
helm get values submission-service -n web-grading

# Check rendered manifest
helm get manifest submission-service -n web-grading
```
