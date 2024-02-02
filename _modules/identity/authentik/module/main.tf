data "kubectl_path_documents" "flux2-repos" {
  pattern = "./manifests/flux-repos/*.yaml"  
}

resource "kubectl_manifest" "flux2-repos" {
  depends_on = [
    kubernetes_namespace.identity
  ]
  for_each  = data.kubectl_path_documents.flux2-repos.manifests
  yaml_body = each.value
}

data "kubectl_path_documents" "flux2-releases" {
  pattern = "./manifests/flux-releases/*.yaml"
vars = {
    smtp_user = var.smtp_user
    smtp_password = var.smtp_password
    smtp_server = var.smtp_server
    smtp_port = var.smtp_port
    smtp_tls=  "${var.smtp_tls}"
    from_email = var.from_email
  }
}

resource "kubectl_manifest" "flux2-releases" {
  depends_on = [
    kubernetes_namespace.identity,
    kubectl_manifest.flux2-repos,
    kubernetes_secret.secretkey
  ]
  for_each   = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body  = each.value
}
