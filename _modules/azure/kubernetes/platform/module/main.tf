
data "kubectl_path_documents" "flux2-repos" {
  pattern = "./manifests/flux-repos/*.yaml"
}

resource "kubectl_manifest" "flux2-repos" {
  for_each  = data.kubectl_path_documents.flux2-repos.manifests
  yaml_body = each.value
}

resource "time_sleep" "flux2repos" {
  depends_on       = [kubectl_manifest.flux2-repos]
  destroy_duration = "180s"
}

data "kubectl_path_documents" "flux2-releases" {
  pattern = "./manifests/flux-releases/*.yaml"
}

resource "kubectl_manifest" "flux2-releases" {
  depends_on = [
    time_sleep.flux2repos
  ]
  for_each  = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body = each.value
}
