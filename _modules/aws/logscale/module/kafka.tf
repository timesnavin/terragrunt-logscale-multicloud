resource "kubectl_manifest" "kafka" {
  depends_on = [
    kubernetes_namespace.logscale
  ]
  yaml_body = templatefile("./manifests/helm-manifests/kafka.yaml", {namespace=local.namespace})
}

resource "kubectl_manifest" "kafka-topics" {
  depends_on = [
    kubectl_manifest.kafka
  ]
  yaml_body = templatefile("./manifests/helm-manifests/kafka-topics.yaml", {namespace=local.namespace})
}
