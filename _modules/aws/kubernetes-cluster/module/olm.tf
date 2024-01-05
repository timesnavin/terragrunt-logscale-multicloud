data "kubectl_file_documents" "olm_crds" {
  content = file("manifests/olm/crds.yaml")
}
data "kubectl_file_documents" "olm" {
  content = file("manifests/olm/olm.yaml")
}


resource "kubectl_manifest" "olm_crds" {
  depends_on = [module.eks]
  for_each   = data.kubectl_file_documents.olm_crds.manifests
  yaml_body  = each.value
}

resource "kubernetes_namespace" "olm" {
  depends_on = [module.eks]

  metadata {
    annotations = {
      name = "olm"
    }
    name = "olm"
  }

    lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      metadata.0.labels["olm.operatorgroup.uid/c0962045-d2f8-4421-9758-70d379dd7b26"]
    ]
  }
}

resource "kubernetes_namespace" "operators" {
  depends_on = [module.eks]

  metadata {
    annotations = {
      name = "operators"
    }
    name = "operators"
  }
}

# resource "kubectl_manifest" "olm" {
#   depends_on = [kubectl_manifest.olm_crds, kubernetes_namespace.olm, kubernetes_namespace.operators]
#   for_each   = data.kubectl_file_documents.olm.manifests
#   yaml_body  = each.value
# }

# resource "time_sleep" "olm_wait_destory" {
#   depends_on       = [kubectl_manifest.olm]
#   destroy_duration = "60s"
# }
