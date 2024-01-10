resource "kubernetes_namespace" "logscale" {
  metadata {
    annotations = {
      name = "logscale"
    }
    name = "logscale"
  }
}