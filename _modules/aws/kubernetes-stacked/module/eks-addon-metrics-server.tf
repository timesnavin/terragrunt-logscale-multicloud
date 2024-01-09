resource "helm_release" "metrics-server" {
  depends_on = [
    time_sleep.karpenter_nodes
  ]
  namespace = "kube-system"

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.11.0"

  wait = true
  values = [
    file("./eks-addon-metrics-server.yaml")
  ]


}