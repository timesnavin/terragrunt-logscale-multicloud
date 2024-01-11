resource "helm_release" "strimzi-operator" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    helm_release.cert-manager
  ]

  namespace        = "strimzi-operator"
  create_namespace = true

  name       = "strimzi-operator"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  version    = "0.39.0"

  values = [templatefile("./k8s-strimzi-operator.yaml", {})]
}

resource "helm_release" "strimzi-dc" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    helm_release.strimzi-operator
  ]

  namespace        = "strimzi-operator"
  create_namespace = true

  name       = "strimzi-dc"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-drain-cleaner"
  version    = "1.0.1"

  values = [templatefile("./k8s-strimzi-drain-cleaner.yaml", {})]
}
