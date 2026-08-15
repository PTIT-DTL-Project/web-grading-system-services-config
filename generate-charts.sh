#!/bin/bash

# Script to generate Helm chart structure for all services
# Based on submission-service template

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Service configurations
declare -A SERVICES=(
    ["api-gateway"]="8080:api_gateway_db"
    ["config-server"]="8888:config_db"
    ["executor-service"]="8083:executor_db"
    ["result-service"]="8084:result_db"
    ["assignment-service"]="8085:assignment_db"
)

DOCKER_USERNAME="vucongtuanduong"
DOMAIN="vucongtuanduong.dpdns.org"

echo -e "${GREEN}🚀 Generating Helm charts for all services${NC}"

for service in "${!SERVICES[@]}"; do
    IFS=':' read -r port dbname <<< "${SERVICES[$service]}"
    
    echo -e "\n${YELLOW}📦 Creating chart for ${service}${NC}"
    
    # Create directory structure
    mkdir -p "${service}/templates"
    
    # Create Chart.yaml
    cat > "${service}/Chart.yaml" <<EOF
apiVersion: v2
name: ${service}
description: Helm chart for ${service}
version: 1.0.0
appVersion: "1.0"
EOF
    
    # Create values-stg.yaml
    cat > "${service}/values-stg.yaml" <<EOF
global:
  domain: ${DOMAIN}
  prefix: web-dev1

image:
  registry: docker.io
  repository: ${DOCKER_USERNAME}/web-grading-system-${service}
  tag: "v1.0.0"
  pullPolicy: Always

spring:
  profilesActive: stg
  dbName: ${dbname}

service:
  type: ClusterIP
  port: ${port}

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 200m
    memory: 256Mi
EOF
    
    # Create _helpers.tpl
    cat > "${service}/templates/_helpers.tpl" <<EOF
{{/* vim: set filetype=mustache: */}}
{{- define "${service}.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63  }}
{{- end }}

{{- define "${service}.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63  }}
{{- else }}
{{- \$name := default .Chart.Name .Values.nameOverride }}
{{- if contains \$name .Release.Name }}
{{- .Release.Name | trunc 63  }}
{{- else }}
{{- printf "%s-%s" .Release.Name \$name | trunc 63  }}
{{- end }}
{{- end }}
{{- end }}
EOF
    
    # Create deployment.yaml
    cat > "${service}/templates/deployment.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "${service}.fullname" . }}
  labels:
    app: {{ include "${service}.name" . }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ include "${service}.name" . }}
  template:
    metadata:
      labels:
        app: {{ include "${service}.name" . }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.port }}
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: {{ .Values.spring.profilesActive }}
            - name: DB_HOST
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: DB_HOST
            - name: DB_PORT
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: DB_PORT
            - name: DB_NAME
              value: {{ .Values.spring.dbName }}
            - name: DB_USERNAME
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: DB_USERNAME
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: DB_PASSWORD
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          readinessProbe:
            httpGet:
              path: /actuator/health
              port: {{ .Values.service.port }}
            initialDelaySeconds: 30
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: {{ .Values.service.port }}
            initialDelaySeconds: 60
            periodSeconds: 30
EOF
    
    # Create service.yaml
    cat > "${service}/templates/service.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: {{ include "${service}.fullname" . }}
  labels:
    app: {{ include "${service}.name" . }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.port }}
      protocol: TCP
      name: http
  selector:
    app: {{ include "${service}.name" . }}
EOF
    
    # Create README
    cat > "${service}/README.md" <<EOF
# ${service} Helm Chart

Helm chart for deploying ${service} to Kubernetes.

## Installation

\`\`\`bash
helm install ${service} . -f values-stg.yaml -n web-grading
\`\`\`

## Configuration

Edit \`values-stg.yaml\` to customize:
- Image tag version
- Resource limits
- Environment-specific settings

## Upgrade

\`\`\`bash
helm upgrade ${service} . -f values-stg.yaml -n web-grading
\`\`\`
EOF
    
    echo -e "${GREEN}✅ Created chart for ${service}${NC}"
done

# Update submission-service Chart.yaml to match naming convention
echo -e "\n${YELLOW}📝 Updating submission-service chart${NC}"

# Rename submission-config to submission-service
if [ -d "submission-config" ]; then
    echo -e "${YELLOW}📝 Renaming submission-config to submission-service${NC}"
    cat > "submission-config/Chart.yaml" <<EOF
apiVersion: v2
name: submission-service
description: Helm chart for submission-service
version: 1.0.0
appVersion: "1.0"
EOF
    mv "submission-config" "submission-service"
    echo -e "${GREEN}✅ Renamed to submission-service${NC}"
fi

echo -e "\n${GREEN}🎉 All Helm charts generated successfully!${NC}"
echo -e "${YELLOW}📁 Chart structure:${NC}"
ls -la .
