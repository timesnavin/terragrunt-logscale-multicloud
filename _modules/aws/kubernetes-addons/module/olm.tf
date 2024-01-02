data "kubectl_file_documents" "olm_crds" {
    content = file("manifests/olm/crds.yaml")
}
data "kubectl_file_documents" "olm" {
    content = file("manifests/olm/olm.yaml")
}

resource "kubernetes_manifest" "olm_crds" {
    for_each  = data.kubectl_file_documents.olm_crds.manifests
    manifest = yamldecode(each.value)
}

resource "kubernetes_namespace" "olm" {
  depends_on = [ time_sleep.olm_wait_destory ]

  metadata {
    annotations = {
      name = "olm"
    }

    name = "olm"
  }
}
resource "kubernetes_namespace" "operators" {
  depends_on = [ time_sleep.olm_wait_destory ]

  metadata {
    annotations = {
      name = "operators"
    }

    name = "operators"
  }
}

resource "kubernetes_manifest" "olm" {
    depends_on = [ kubernetes_manifest.olm_crds , kubernetes_namespace.olm, kubernetes_namespace.operators]
    for_each  = data.kubectl_file_documents.olm.manifests
    manifest = yamldecode(each.value)
}

resource "time_sleep" "olm_wait_destory" {
  destroy_duration = "60s"
}
