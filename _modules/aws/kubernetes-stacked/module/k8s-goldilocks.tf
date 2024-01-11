
resource "helm_release" "goldilocks" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    helm_release.metrics-server
  ]
  namespace = "goldilocks"
  create_namespace = true

  name       = "goldilocks"
  repository = "https://charts.fairwinds.com/stable"
  chart      = "goldilocks"
#   version    = "0.29.0"

  wait = false

  values = [file("./k8s-goldilocks-values.yaml")]
}
