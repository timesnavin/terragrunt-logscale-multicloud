

resource "kubectl_manifest" "kafka-topics" {

  yaml_body = templatefile("./manifests/helm-manifests/kafka-topics.yaml",
   {
    kafka_name = var.kafka_name
    kafka_namespace=var.kafka_namespace
    tenant = var.tenant
    prefix = "g000"
    logscale_namespace = local.namespace
    }
    )
}
