{{/* vim: set filetype=mustache: */}}
{{/*
Define resource names
*/}}

{{- define "aws-ecr-credential.secret" }}
{{- default (printf "%s-secret" .Release.Name) .Values.awsSecret -}}
{{- end }}

{{- define "aws-ecr-credential.namespace" }}
{{- if .Values.awsSecretNamespaceIsReleaseNamespace }}
{{- .Release.Namespace -}}
{{- else }}
{{- default (printf "%s-ns" .Release.Name) .Values.awsSecretNamespace -}}
{{- end }}
{{- end }}

{{- define "aws-ecr-credential.serviceAccount" }}
{{- default (printf "%s-account" .Release.Name) .Values.refreshAccount -}}
{{- end }}

{{- define "aws-ecr-credential.job" }}
{{- default (printf "%s-job" .Release.Name) .Values.jobName -}}
{{- end }}

{{- define "aws-ecr-credential.cronJob" }}
{{- default (printf "%s-cron" .Release.Name) .Values.cronName -}}
{{- end }}

{{- define "aws-ecr-credential.targetNamespace" }}
{{- .Values.targetNamespace -}}
{{- end }}

