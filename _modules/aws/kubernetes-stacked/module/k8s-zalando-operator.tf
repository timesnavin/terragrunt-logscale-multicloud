resource "helm_release" "zalando-operator" {
    depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter
  ]

  namespace        = "postgres-operator"
  create_namespace = true

  name       = "postgres-operator"
  repository = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator"
  chart      = "postgres-operator"
  version    = "1.10.1"

  values = [templatefile("./k8s-zalando-operator.yaml",{region=var.cluster_region})]
}

resource "helm_release" "zalando-operator-ui" {
    depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    helm_release.zalando-operator
  ]

  namespace        = "postgres-operator"
  create_namespace = true

  name       = "postgres-operator-ui"
  repository = "https://opensource.zalando.com/postgres-operator/charts/postgres-operator-ui"
  chart      = "postgres-operator-ui"
  version    = "1.10.1"

  values = [templatefile("./k8s-zalando-operator.yaml",{region=var.cluster_region})]
}
