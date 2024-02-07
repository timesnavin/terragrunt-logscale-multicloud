resource "kubectl_manifest" "kafka" {
  count = var.dedicated_kafka ? 1 : 0
  depends_on = [
    kubernetes_namespace.logscale
  ]
  yaml_body = templatefile("./manifests/helm-manifests/kafka.yaml", {namespace=local.kafka_namespace})
}

locals {
  kafka_namespace = var.dedicated_kafka ? local.namespace : "region-kafka"
  kafkaCluster =var.dedicated_kafka ? "kafka" : "regional"
}

resource "kubectl_manifest" "kafka-topics" {
  depends_on = [
    kubectl_manifest.kafka
  ]
  yaml_body = templatefile("./manifests/helm-manifests/kafka-topics.yaml",
   {
    kafka_namespace=local.kafka_namespace
    tenant = var.tenant
    kafkaCluster = local.kafkaCluster
    prefix = "g000"
    }
    )
}
