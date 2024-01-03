data "kubectl_file_documents" "olm_crds" {
  content = file("manifests/olm/crds.yaml")
}
data "kubectl_file_documents" "olm" {
  content = file("manifests/olm/olm.yaml")
}


resource "kubectl_manifest" "olm_crds" {
  for_each  = data.kubectl_file_documents.olm_crds.manifests
  yaml_body = each.value
}

resource "kubernetes_namespace" "olm" {

  metadata {
    annotations = {
      name = "olm"
    }
    name = "olm"
  }
}

resource "kubernetes_namespace" "operators" {

  metadata {
    annotations = {
      name = "operators"
    }
    name = "operators"
  }
}

resource "kubectl_manifest" "olm" {
  depends_on = [kubectl_manifest.olm_crds, kubernetes_namespace.olm, kubernetes_namespace.operators]
  for_each   = data.kubectl_file_documents.olm.manifests
  yaml_body  = each.value
}

resource "time_sleep" "olm_wait_destory" {
  depends_on       = [kubectl_manifest.olm]
  destroy_duration = "60s"
}
