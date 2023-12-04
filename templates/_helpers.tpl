{{/*
The name of the ServiceAccount used.
*/}}
{{- define "synthetic-pop.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "synthetic-pop.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ printf "default" }}
{{- end -}}
{{- end -}}

{{/* The ServiceAccount name of browser playback engine used. */}}
{{- define "synthetic-pop.browserServiceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{- printf "browser-%s" (include "synthetic-pop.serviceAccountName" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ printf "default" }}
{{- end -}}
{{- end -}}

{{/* The ServiceAccount name of PoP Controller used. */}}
{{- define "synthetic-pop.controllerServiceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{- printf "pop-controller-%s" (include "synthetic-pop.serviceAccountName" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ printf "default" }}
{{- end -}}
{{- end -}}

{{/* The ServiceAccount name of http playback engine used. */}}
{{- define "synthetic-pop.httpServiceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{- printf "http-%s" (include "synthetic-pop.serviceAccountName" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ printf "default" }}
{{- end -}}
{{- end -}}

{{/* The ServiceAccount name of ism playback engine used. */}}
{{- define "synthetic-pop.ismServiceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{- printf "ism-%s" (include "synthetic-pop.serviceAccountName" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ printf "default" }}
{{- end -}}
{{- end -}}

{{/* The ServiceAccount name of javascript playback engine used. */}}
{{- define "synthetic-pop.javascriptServiceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{- printf "javascript-%s" (include "synthetic-pop.serviceAccountName" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ printf "default" }}
{{- end -}}
{{- end -}}

{{/* The ServiceAccount name of redis used. */}}
{{- define "synthetic-pop.redisServiceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{- printf "redis-%s" (include "synthetic-pop.serviceAccountName" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ printf "default" }}
{{- end -}}
{{- end -}}

{{/*
Enable default secure computing mode
*/}}
{{- define "synthetic-pop.seccomp" -}}
{{- if .Values.seccompDefault -}}
securityContext:
  seccompProfile:
    type: RuntimeDefault
{{- end -}}
{{- end -}}

{{/*
Enable network policy for playback engines
*/}}
{{- define "playback-engine.networkPolicy.egress" -}}
{{- if .Values.playbackEngineNetworkPolicy.enabled -}}
egress: {{ toYaml .Values.playbackEngineNetworkPolicy.egress | nindent 4 }}
{{- else -}}
egress:
  - {}
{{- end -}}
{{- end -}}

{{/*
Generates the dockerconfig for the credentials to pull from containers.instana.io
*/}}
{{- define "imagePullSecretInstanaIo" }}
{{- $registry := "containers.instana.io" }}
{{- $username := "_" }}
{{- $password := .Values.downloadKey }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" $registry (printf "%s:%s" $username $password | b64enc) | b64enc }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "synthetic-pop.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Add Helm metadata to resource labels.
*/}}
{{- define "synthetic-pop.commonLabels" -}}
app.kubernetes.io/version: {{ .Chart.Version }}
{{- if not .Values.templating }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "synthetic-pop.chart" . }}
release: synthetic-pop
{{- end -}}
{{- end -}}

{{/*
Add Helm metadata to selector labels specifically for deployments/daemonsets/statefulsets.
*/}}
{{- define "synthetic-pop.selectorLabels" -}}
{{- if not .Values.templating }}
app.kubernetes.io/instance: {{ .Release.Name }}
release: synthetic-pop
{{- end -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "synthetic-pop.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "synthetic-pop.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the password secret.
*/}}
{{- define "redis.secretName" -}}
{{- printf "%s" (include "redis.fullname" .) -}}
{{- end -}}

{{/*
Return Redis password
*/}}
{{- define "redis.password" -}}
{{- if not (empty .Values.redis.password) }}
{{- .Values.redis.password -}}
{{- end -}}
{{- end -}}

{{/*
Get redis password path.
*/}}
{{- define "redis.passPath" -}}
{{- printf "/etc/pop/redispass" -}}
{{- end -}}

{{/*
Define instanaKey Secret Name.
*/}}
{{- define "instanaKey.secretName" -}}
{{- printf "%s-%s" .Release.Name "instana-key" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define proxyUserPass Secret Name.
*/}}
{{- define "proxyUserPass.secretName" -}}
{{- printf "%s-%s" .Release.Name "proxy-user-pass" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get tls certificate path.
*/}}
{{- define "tls.certPath" -}}
{{- printf "/etc/pop/certs" -}}
{{- end -}}

{{/*
Get instananKey path
*/}}
{{- define "instana.keyPath" -}}
{{- printf "/etc/pop/instanakey" -}}
{{- end -}}

{{/*
Get proxyUserPassPath path
*/}}
{{- define "proxy.userPassPath" -}}
{{- printf "/etc/pop/proxyuserpass" -}}
{{- end -}}
