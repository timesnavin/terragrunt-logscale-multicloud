resource "helm_release" "flux2" {
  depends_on       = [kubernetes_labels.topolvm]
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "flux2"
  namespace        = "flux-system"
  create_namespace = true
  version          = "2.12.2"
  values = [<<YAML
  logLevel: debug
  YAML
  ]
}

data "kubectl_path_documents" "flux2-repos" {
  pattern = "./manifests/flux-repos/*.yaml"
}

resource "kubectl_manifest" "flux2-repos" {
  depends_on = [
    helm_release.flux2,
    kubernetes_config_map.cluster_vars
  ]
  for_each  = data.kubectl_path_documents.flux2-repos.manifests
  yaml_body = each.value
}


data "kubectl_path_documents" "flux2-releases" {
  pattern = "./manifests/flux-releases/*.yaml"
}

resource "kubectl_manifest" "flux2-releases" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos
  ]
  for_each  = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body = each.value
}
