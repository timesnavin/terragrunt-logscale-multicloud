resource "kubernetes_namespace" "ns" {
  metadata {
    annotations = {
      name = local.namespace
    }
    name = local.namespace
  }
}


resource "kubernetes_config_map" "otel_vars" {
  depends_on = [kubernetes_namespace.ns]
  metadata {
    name      = "otel-values"
    namespace = local.namespace
  }

  data = {
    "values.yaml" = <<-YAML
    humioservice: https://${var.logscale_fqdn_ingest}/api/v1/ingest/otlp
    humiosecretprefix: "partition-logscale"
    components:
      app: false
      cluster: false
      nodes: true
      serviceaccount: true   
YAML
  }
}

resource "kubernetes_secret" "partition-logscale-all-humio-infra-k8s-logs" {
  metadata {
    name = "partition-logscale-all-humio-infra-k8s-logs"
    namespace = local.namespace
  }

  data = {
    token = var.logscale_ingest_token
  }
  type = "Opaque"
}
resource "kubernetes_secret" "partition-logscale-all-humio-infra-k8s-metrics" {
  metadata {
    name = "partition-logscale-all-humio-infra-k8s-metrics"
    namespace = local.namespace
  }

  data = {
    token = var.logscale_ingest_token
  }
  type = "Opaque"
}
resource "kubernetes_secret" "partition-logscale-all-humio-infra-k8s-trace" {
  metadata {
    name = "partition-logscale-all-humio-infra-k8s-trace"
    namespace = local.namespace
  }

  data = {
    token = var.logscale_ingest_token
  }
  type = "Opaque"
}
