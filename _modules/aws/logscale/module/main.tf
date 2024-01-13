data "aws_caller_identity" "current" {}

data "kubectl_path_documents" "flux2-repos" {
  pattern = "./manifests/flux-repos/*.yaml"
}

resource "kubectl_manifest" "flux2-repos" {
  depends_on = [
    kubernetes_namespace.logscale
  ]
  override_namespace = var.namespace
  for_each           = data.kubectl_path_documents.flux2-repos.manifests
  yaml_body          = each.value
}


data "kubectl_path_documents" "flux2-releases" {
  pattern = "./manifests/flux-releases/*.yaml"
}

resource "kubectl_manifest" "flux2-releases" {
  depends_on = [
    kubectl_manifest.flux2-repos
  ]
  override_namespace = var.namespace
  for_each           = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body          = each.value
}
