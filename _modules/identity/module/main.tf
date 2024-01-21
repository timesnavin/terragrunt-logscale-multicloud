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
}

resource "kubectl_manifest" "flux2-releases" {
  depends_on = [
    kubernetes_namespace.identity,
    kubectl_manifest.flux2-repos,
    kubernetes_secret.partition-logscale-all-humio-infra-k8s-logs

  ]
  for_each   = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body  = each.value
}
