# Install cert-manager via Helm
resource "helm_release" "cert_manager" {
    name = "cert-manager"
    namespace = "cert-manager"
    create_namespace = true
    repository = "https://charts.jetstack.io"
    chart = "cert-manager"
    version = var.cert_manager_version

    set {
      name = "installCRDs"
      value = true
    }

    set {
      name = "extraArgs[0]"
      value = "--enable-certificate-owner-ref=true"
    }
}

resource "kubectl_manifest" "cluster_issuer" {
    yaml_body  = templatefile("${path.module}/cluster-issuer.yaml", {
        email = var.email,
        ingress_class = var.ingress_class,
    })
  
  depends_on = [ helm_release.cert_manager ]
}