resource "kubectl_manifest" "logscale-operator" {
  depends_on = [
    time_sleep.external_services
  ]
  yaml_body = templatefile("./manifests/helm-manifests/logscale-operator.yaml", {})
}

resource "kubectl_manifest" "otel-operator" {
  depends_on = [
    time_sleep.external_services
  ]
  yaml_body = templatefile("./manifests/helm-manifests/otel-operator.yaml", {})
}



resource "kubectl_manifest" "redis-operator" {
  depends_on = [
    time_sleep.external_services
  ]
  yaml_body = templatefile("./manifests/helm-manifests/redis-operator.yaml", {})
}

resource "kubectl_manifest" "strimzi-draincleaner" {
  depends_on = [
    time_sleep.external_services
  ]
  yaml_body = templatefile("./manifests/helm-manifests/strimzi-draincleaner.yaml", {})
}

resource "kubectl_manifest" "strimzi-operator" {
  depends_on = [
    time_sleep.external_services
  ]
  yaml_body = templatefile("./manifests/helm-manifests/strimzi-operator.yaml", {})
}

resource "kubectl_manifest" "zalando" {
  depends_on = [
    time_sleep.external_services
  ]
  yaml_body = templatefile("./manifests/helm-manifests/zalando.yaml", { region = var.region })
}
# resource "kubectl_manifest" "zalando-ui" {
#   depends_on = [
#     time_sleep.external_services,
#     kubectl_manifest.zalando
#   ]
#   yaml_body = templatefile("./manifests/helm-manifests/zalando-ui.yaml", {})
# }


resource "time_sleep" "operators" {
  depends_on = [
    kubectl_manifest.logscale-operator,
    kubectl_manifest.otel-operator,
    kubectl_manifest.redis-operator,
    kubectl_manifest.strimzi-operator,
    kubectl_manifest.zalando
  ]
  destroy_duration = "180s"
}
