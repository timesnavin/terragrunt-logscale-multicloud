# data "kubectl_path_documents" "cert_manager_crds" {
#   pattern = "./manifests/cert-manager/v1.13.3.yaml"
# }

# resource "kubectl_manifest" "cert_manager_crds" {
#   for_each  = toset(data.kubectl_path_documents.cert_manager_crds.documents)
#   yaml_body = each.value
# }

# resource "helm_release" "cert-manager" {
#   depends_on = [
#     time_sleep.karpenter_nodes,
#     helm_release.karpenter,
#     kubectl_manifest.cert_manager_crds
#   ]
#   namespace        = "cert-manager"
#   create_namespace = true

#   name       = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
#   version    = "v1.13.3"

#   wait   = true
#   values = [file("./eks-addon-certmgr-values.yaml")]

# }

