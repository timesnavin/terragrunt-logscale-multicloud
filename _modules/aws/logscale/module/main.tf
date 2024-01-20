data "aws_caller_identity" "current" {}

data "kubectl_path_documents" "flux2-repos" {
  pattern = "./manifests/flux-repos/*.yaml"
}

resource "kubectl_manifest" "flux2-repos" {
  depends_on = [
    kubernetes_namespace.logscale,
    kubernetes_config_map.cluster_vars,
    kubernetes_config_map.logscale_vars
  ]
  override_namespace = local.namespace
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
  override_namespace = local.namespace
  for_each           = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body          = each.value
}


locals {
  fqdn        = "${var.host_prefix}-${var.tenant}.${var.domain_name}"
  fqdn_ingest = "${var.host_prefix}-${var.tenant}-ingest.${var.domain_name}"
  namespace   = "${var.host_prefix}-${var.tenant}"
}
