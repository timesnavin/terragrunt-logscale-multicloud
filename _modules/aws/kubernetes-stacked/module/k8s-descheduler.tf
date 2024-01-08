
resource "helm_release" "descheduler" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter
  ]
  namespace = "kube-system"

  name       = "descheduler"
  repository = "https://kubernetes-sigs.github.io/descheduler/"
  chart      = "descheduler"
  version    = "0.29.0"

  wait = false

  values = [file("./k8s-descheduler-values.yaml")]
}
