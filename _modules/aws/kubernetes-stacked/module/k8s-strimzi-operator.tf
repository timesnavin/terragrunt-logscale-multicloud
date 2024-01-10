resource "helm_release" "strimzi-operator" {
    depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter
  ]

  namespace        = "strimzi-operator"
  create_namespace = true

  name       = "strimzi-operator"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-operator"
  version    = "0.20.1"

  values = [templatefile("./k8s-strimzi-operator.yaml",{})]
}
