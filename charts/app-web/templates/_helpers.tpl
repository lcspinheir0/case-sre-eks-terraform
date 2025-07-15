{{- define "app-web.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "app-web.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}
