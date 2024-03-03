
data "kubectl_path_documents" "namespaces" {
  pattern = "./manifests/namespaces/*.yaml"
}

resource "kubectl_manifest" "namespaces" {
  depends_on = [
    module.eks.access_entries,
    module.eks.access_policy_associations,
    module.eks.cloudwatch_log_group_arn
  ]
  for_each  = data.kubectl_path_documents.namespaces.manifests
  yaml_body = each.value
}
