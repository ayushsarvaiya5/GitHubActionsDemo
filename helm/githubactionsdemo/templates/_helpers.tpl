{{/*
Expand the name of the chart.
*/}}
{{- define "githubactionsdemo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "githubactionsdemo.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart name and version as used by the chart label.
*/}}
{{- define "githubactionsdemo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Namespace to render resources into.
*/}}
{{- define "githubactionsdemo.namespace" -}}
{{- if .Values.namespace.name }}
{{- .Values.namespace.name }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "githubactionsdemo.labels" -}}
helm.sh/chart: {{ include "githubactionsdemo.chart" . }}
{{ include "githubactionsdemo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/environment: {{ .Values.environment | default "Development" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "githubactionsdemo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "githubactionsdemo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name
*/}}
{{- define "githubactionsdemo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "githubactionsdemo.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Shared Pod template (metadata + spec), reused by the stable Deployment and
the optional blue-green and canary Deployments.

Call with a dict:
  root:        the root context (".")
  imageTag:    optional image tag override (falls back to .Values.image.tag, then Chart.AppVersion)
  resources:   optional resources override (falls back to .Values.resources)
  extraLabels: optional map of extra labels to add (e.g. slot/track labels)
*/}}
{{- define "githubactionsdemo.podTemplate" -}}
{{- $root := .root -}}
{{- $imageTag := .imageTag | default $root.Values.image.tag | default $root.Chart.AppVersion -}}
{{- $resources := .resources | default $root.Values.resources -}}
metadata:
  {{- with $root.Values.podAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "githubactionsdemo.selectorLabels" $root | nindent 4 }}
    {{- with .extraLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- with $root.Values.podLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- with $root.Values.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  serviceAccountName: {{ include "githubactionsdemo.serviceAccountName" $root }}
  securityContext:
    {{- toYaml $root.Values.podSecurityContext | nindent 4 }}
  containers:
    - name: {{ $root.Chart.Name }}
      securityContext:
        {{- toYaml $root.Values.securityContext | nindent 8 }}
      image: "{{ $root.Values.image.repository }}:{{ $imageTag }}"
      imagePullPolicy: {{ $root.Values.image.pullPolicy }}
      ports:
        - name: http
          containerPort: 8080
          protocol: TCP
      envFrom:
        - configMapRef:
            name: {{ include "githubactionsdemo.fullname" $root }}-config
        {{- if $root.Values.secret.enabled }}
        - secretRef:
            name: {{ include "githubactionsdemo.fullname" $root }}-secret
        {{- end }}
      readinessProbe:
        httpGet:
          path: {{ $root.Values.probes.readiness.path }}
          port: http
        initialDelaySeconds: {{ $root.Values.probes.readiness.initialDelaySeconds }}
        periodSeconds: {{ $root.Values.probes.readiness.periodSeconds }}
      livenessProbe:
        httpGet:
          path: {{ $root.Values.probes.liveness.path }}
          port: http
        initialDelaySeconds: {{ $root.Values.probes.liveness.initialDelaySeconds }}
        periodSeconds: {{ $root.Values.probes.liveness.periodSeconds }}
      resources:
        {{- toYaml $resources | nindent 8 }}
      {{- if $root.Values.persistence.enabled }}
      volumeMounts:
        - name: data
          mountPath: {{ $root.Values.persistence.mountPath }}
      {{- end }}
  {{- if $root.Values.persistence.enabled }}
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: {{ include "githubactionsdemo.fullname" $root }}-data
  {{- end }}
  {{- with $root.Values.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $root.Values.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $root.Values.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
