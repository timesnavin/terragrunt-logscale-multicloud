resource "kubernetes_labels" "topolvm" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "kube-system"
  }
  labels = {
    "topolvm.io/webhook" = "ignore"
  }
}
