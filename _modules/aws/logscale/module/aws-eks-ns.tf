resource "kubernetes_namespace" "logscale" {
  metadata {
    annotations = {
      name = local.namespace
    }
    name = local.namespace
  }
}
