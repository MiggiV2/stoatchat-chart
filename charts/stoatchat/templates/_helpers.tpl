{{- define "stoatchat.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "stoatchat.fullname" -}}
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

{{- define "stoatchat.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "stoatchat.labels" -}}
helm.sh/chart: {{ include "stoatchat.chart" . }}
app.kubernetes.io/name: {{ include "stoatchat.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "stoatchat.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stoatchat.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "stoatchat.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "stoatchat.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "stoatchat.secretName" -}}
{{- if .Values.existingSecretsName -}}
{{- .Values.existingSecretsName -}}
{{- else -}}
{{- printf "%s-secrets" (include "stoatchat.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "stoatchat.revoltConfigMapName" -}}
{{- if .Values.config.existingRevoltTomlConfigMap -}}
{{- .Values.config.existingRevoltTomlConfigMap -}}
{{- else -}}
{{- printf "%s-revolt-config" (include "stoatchat.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "stoatchat.livekitConfigMapName" -}}
{{- if .Values.config.existingLivekitConfigMap -}}
{{- .Values.config.existingLivekitConfigMap -}}
{{- else -}}
{{- printf "%s-livekit-config" (include "stoatchat.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "stoatchat.ingressHost" -}}
{{- if .Values.ingress.host -}}
{{- .Values.ingress.host -}}
{{- else -}}
{{- .Values.global.domain -}}
{{- end -}}
{{- end -}}

{{- /*
Single source of truth for the deployable components. Consumed by
templates/deployments.yaml and templates/services.yaml via:
  {{- $components := (include "stoatchat.components" .) | fromYamlArray }}
Fields:
  id          key under .Values.components
  name        suffix used for resource names and the component label
  port        default container/service port
  mountRevolt mount Revolt.toml configmap into the pod
  mountLivekit mount livekit.yml configmap into the pod
  useWebEnv   pull env from the web-env configmap instead of the secret
*/ -}}
{{- define "stoatchat.components" -}}
- id: api
  name: api
  port: 14702
  mountRevolt: true
  mountLivekit: false
  useWebEnv: false
- id: events
  name: events
  port: 14703
  mountRevolt: true
  mountLivekit: false
  useWebEnv: false
- id: autumn
  name: autumn
  port: 14704
  mountRevolt: true
  mountLivekit: false
  useWebEnv: false
- id: january
  name: january
  port: 14705
  mountRevolt: true
  mountLivekit: false
  useWebEnv: false
- id: gifbox
  name: gifbox
  port: 14706
  mountRevolt: true
  mountLivekit: false
  useWebEnv: false
- id: crond
  name: crond
  port: 14707
  mountRevolt: true
  mountLivekit: false
  useWebEnv: false
- id: pushd
  name: pushd
  port: 14708
  mountRevolt: true
  mountLivekit: false
  useWebEnv: false
- id: voiceIngress
  name: voice-ingress
  port: 8500
  mountRevolt: true
  mountLivekit: false
  useWebEnv: false
- id: livekit
  name: livekit
  port: 7880
  mountRevolt: false
  mountLivekit: true
  useWebEnv: false
- id: web
  name: web
  port: 5000
  mountRevolt: false
  mountLivekit: false
  useWebEnv: true
{{- end -}}
