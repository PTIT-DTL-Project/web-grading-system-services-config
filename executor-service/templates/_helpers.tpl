{{/* vim: set filetype=mustache: */}}
{{- define "executor-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63  }}
{{- end }}

{{- define "executor-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63  }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63  }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63  }}
{{- end }}
{{- end }}
{{- end }}
