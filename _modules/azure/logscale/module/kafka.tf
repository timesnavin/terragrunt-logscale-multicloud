# resource "time_static" "kafka_prefix" {
#   triggers = {
#     # Save the time each switch of an AMI id
#     admin_increment = var.kafka_prefix_increment
#     region          = var.region
#   }
# }
resource "counters_monotonic" "kafka_prefix" {
  initial_value = 1
  triggers = {
    admin           = var.kafka_prefix_increment,
    region          = var.region
    kafka_name      = var.kafka_name
    kafka_namespace = var.kafka_namespace
  }
}

resource "kubectl_manifest" "kafka-topics" {

  yaml_body = templatefile("./manifests/helm-manifests/kafka-topics.yaml",
    {
      kafka_name         = var.kafka_name
      kafka_namespace    = var.kafka_namespace
      tenant             = var.tenant
      prefix             = "${format("g%03s", counters_monotonic.kafka_prefix.value)}"
      logscale_namespace = local.namespace
    }
  )
}
