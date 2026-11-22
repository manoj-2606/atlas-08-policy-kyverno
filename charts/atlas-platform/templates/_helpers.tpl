{{/*
Atlas Platform — Template Helpers
*/}}

{{- define "atlas-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "atlas-platform.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "atlas-platform.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "atlas-platform.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $key, $val := .Values.labels }}
{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}

{{- define "atlas-platform.selectorLabels" -}}
app.kubernetes.io/name: {{ index .Values.labels "app.kubernetes.io/name" | default (include "atlas-platform.name" .) }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}