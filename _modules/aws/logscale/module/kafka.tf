resource "helm_release" "kafka-cluster" {
  depends_on = [
    kubernetes_namespace.logscale
  ]
  namespace        = var.namespace

  name       = "kafka"
  repository = "oci://ghcr.io/logscale-contrib/charts"
  chart      = "kafka-strimzi-cluster"
  version    = "2.1.2"

  wait   = true
  values = [
    templatefile("./kafka-cluster-values-ha.yaml",
    {
      storageClass = "gp3"
    }
  )
  ]

}