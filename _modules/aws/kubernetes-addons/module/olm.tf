data "kubectl_file_documents" "olm_crds" {
    content = file("manifests/olm/crds.yaml")
}

resource "kubernetes_manifest" "olm_crds" {
    for_each  = data.kubectl_file_documents.docs.manifests
    manifest = yamldecode(each.value)
}
