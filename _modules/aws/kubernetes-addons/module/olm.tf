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

resource "kubernetes_manifest" "olm" {
    depends_on = [ kubernetes_manifest.olm_crds ]
    for_each  = data.kubectl_file_documents.olm.manifests
    manifest = yamldecode(each.value)
}
