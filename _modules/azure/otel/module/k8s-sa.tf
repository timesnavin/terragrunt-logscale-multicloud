resource "kubectl_manifest" "sa-cluster" {
  depends_on = [
    kubernetes_namespace.ns
  ]
  yaml_body = <<-YAML
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: otel-collector-cluster
      namespace: otel-system
    automountServiceAccountToken: true
YAML
}
resource "kubectl_manifest" "sa-clusterrole" {
  yaml_body = <<-YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: otel-collector-cluster
    rules:
      - apiGroups:
          - ''
        resources:
          - events
          - namespaces
          - namespaces/status
          - nodes
          - nodes/spec
          - pods
          - pods/status
          - replicationcontrollers
          - replicationcontrollers/status
          - resourcequotas
          - services
        verbs:
          - get
          - list
          - watch
      - apiGroups:
          - apps
        resources:
          - daemonsets
          - deployments
          - replicasets
          - statefulsets
        verbs:
          - get
          - list
          - watch
      - apiGroups:
          - extensions
        resources:
          - daemonsets
          - deployments
          - replicasets
        verbs:
          - get
          - list
          - watch
      - apiGroups:
          - batch
        resources:
          - jobs
          - cronjobs
        verbs:
          - get
          - list
          - watch
      - apiGroups:
          - autoscaling
        resources:
          - horizontalpodautoscalers
        verbs:
          - get
          - list
          - watch
YAML
}
resource "kubectl_manifest" "sa-clusterrolebinding" {
  depends_on = [
    kubectl_manifest.sa-cluster,
    kubectl_manifest.sa-clusterrole
  ]
  yaml_body = <<-YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: otel-collector-cluster
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: otel-collector-cluster
    subjects:
      - kind: ServiceAccount
        name: otel-collector-cluster
        namespace: otel-system
  YAML
}
