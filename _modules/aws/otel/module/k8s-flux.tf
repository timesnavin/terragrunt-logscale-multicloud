

data "kubectl_path_documents" "flux2-releases" {
  pattern = "./manifests/flux-releases/*.yaml"
  vars = {
    fqdn_ingest = var.logscale_fqdn_ingest
  }
}

resource "kubectl_manifest" "flux2-releases" {
  depends_on = [
    kubernetes_secret.apps-kubernetes-ingest-token,
    kubernetes_secret.infra-kubernetes-ingest-token,
    kubectl_manifest.sa-clusterrolebinding
  ]
  for_each  = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body = each.value
}
