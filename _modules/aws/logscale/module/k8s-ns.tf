# resource "kubernetes_namespace" "logscale" {
#   metadata {
#     annotations = {
#       name = var.namespace
#     }
#     name = var.namespace
#   }
# }