resource "kubernetes_namespace" "identity" {
  metadata {
    annotations = {
      name = "identity"
    }


    name = "identity"
  }
}