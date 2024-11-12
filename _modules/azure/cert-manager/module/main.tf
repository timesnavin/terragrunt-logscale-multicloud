resource "helm_release" "cert-manager" {
    name = "cert-manager"
    namespace = var.namespace
    create_namespace = true
    repository = "https://charts.jetstack.io"
    chart = "cert-manager"
    version = var.cert_manager_version

    set {
      name = "installCRDs"
      value = true
    }
  
}