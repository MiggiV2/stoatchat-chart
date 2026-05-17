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
