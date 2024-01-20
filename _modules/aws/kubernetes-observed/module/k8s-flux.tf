
data "kubectl_path_documents" "flux2-repos" {
  pattern = "./manifests/flux-repos/*.yaml"
}

resource "kubectl_manifest" "flux2-repos" {
  # depends_on = [
  #   helm_release.flux2,
  #   kubernetes_config_map.cluster_vars
  # ]
  for_each  = data.kubectl_path_documents.flux2-repos.manifests
  yaml_body = each.value
}


data "kubectl_path_documents" "flux2-releases" {
  pattern = "./manifests/flux-releases/*.yaml"
}

resource "kubectl_manifest" "flux2-releases" {
  depends_on = [
    kubectl_manifest.flux2-repos
  ]
  for_each  = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body = each.value
}
