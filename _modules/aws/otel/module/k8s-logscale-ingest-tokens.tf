

resource "kubectl_manifest" "infra-token" {
  provider = kubectl.partition

  yaml_body = <<-YAML
    apiVersion: core.humio.com/v1alpha1
    kind: HumioIngestToken
    metadata:
      name: ${var.cluster_name}-infra-kubernetes
      namespace: ${var.namespace}
    spec:
      managedClusterName: ${var.logscaleinstance}
      name: ${var.cluster_name}-infra-kubernetes
      repositoryName: infra-kubernetes
      tokenSecretName: ${var.cluster_name}-infra-kubernetes-ingest-token  
YAML  
}

resource "kubectl_manifest" "apps-token" {
  provider = kubectl.partition

  yaml_body = <<-YAML
    apiVersion: core.humio.com/v1alpha1
    kind: HumioIngestToken
    metadata:
      name: ${var.cluster_name}-apps-kubernetes
      namespace: ${var.namespace}
    spec:
      managedClusterName: ${var.logscaleinstance}
      name: ${var.cluster_name}-apps-kubernetes
      repositoryName: apps-kubernetes
      tokenSecretName: ${var.cluster_name}-apps-kubernetes-ingest-token  
YAML  
}


resource "kubectl_manifest" "metrics-token" {
  provider = kubectl.partition

  yaml_body = <<-YAML
    apiVersion: core.humio.com/v1alpha1
    kind: HumioIngestToken
    metadata:
      name: ${var.cluster_name}-metrics-kubernetes
      namespace: ${var.namespace}
    spec:
      managedClusterName: ${var.logscaleinstance}
      name: ${var.cluster_name}-metrics-kubernetes
      repositoryName: metrics-kubernetes
      tokenSecretName: ${var.cluster_name}-metrics-kubernetes-ingest-token  
YAML  
}

resource "time_sleep" "tokencreation" {
  depends_on = [
    kubectl_manifest.infra-token,
    kubectl_manifest.apps-token,
    kubectl_manifest.metrics-token
  ]
  triggers = {
    infra = kubectl_manifest.infra-token.yaml_body
    apps  = kubectl_manifest.apps-token.yaml_body
    metrics  = kubectl_manifest.metrics-token.yaml_body
  }
  create_duration = "30s"
}

data "kubernetes_secret" "otel-infra-token" {
  provider   = kubernetes.partition
  depends_on = [time_sleep.tokencreation]
  metadata {
    name      = "${var.cluster_name}-infra-kubernetes-ingest-token"
    namespace = var.namespace
  }
}
data "kubernetes_secret" "otel-apps-token" {
  provider   = kubernetes.partition
  depends_on = [time_sleep.tokencreation]
  metadata {
    name      = "${var.cluster_name}-apps-kubernetes-ingest-token"
    namespace = var.namespace
  }
}

data "kubernetes_secret" "otel-metrics-token" {
  provider   = kubernetes.partition
  depends_on = [time_sleep.tokencreation]
  metadata {
    name      = "${var.cluster_name}-metrics-kubernetes-ingest-token"
    namespace = var.namespace
  }
}

resource "kubernetes_secret" "infra-kubernetes-ingest-token" {
  metadata {
    name      = "infra-kubernetes-ingest-token"
    namespace = "otel-system"
  }

  data = {
    token = data.kubernetes_secret.otel-infra-token.data["token"]
  }
  type = "Opaque"
}


resource "kubernetes_secret" "apps-kubernetes-ingest-token" {
  metadata {
    name      = "apps-kubernetes-ingest-token"
    namespace = "otel-system"
  }

  data = {
    token = data.kubernetes_secret.otel-apps-token.data["token"]
  }
  type = "Opaque"
}

resource "kubernetes_secret" "metrics-kubernetes-ingest-token" {
  metadata {
    name      = "metrics-kubernetes-ingest-token"
    namespace = "otel-system"
  }

  data = {
    token = data.kubernetes_secret.otel-metrics-token.data["token"]
  }
  type = "Opaque"
}
