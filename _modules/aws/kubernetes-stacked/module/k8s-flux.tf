resource "helm_release" "flux2" {
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


resource "kubernetes_config_map" "cluster_vars" {
  depends_on = [helm_release.flux2]
  metadata {
    name      = "clustervars"
    namespace = "flux-system"
  }

  data = {
    aws_region  = var.cluster_region
    aws_arn_efs = module.efs_csi_irsa.iam_role_arn
    aws_arn_ebs = module.ebs_csi_irsa.iam_role_arn
    aws_arn_alb = module.ing_alb_irsa.iam_role_arn
    aws_arn_keda = module.keda_irsa.iam_role_arn
  }

}

data "kubectl_path_documents" "flux2-repos" {
  pattern = "./manifests/flux-repos/*.yaml"
}

resource "kubectl_manifest" "flux2-repos" {
  depends_on = [
    helm_release.flux2,
    kubernetes_config_map.cluster_vars
  ]
  count     = length(data.kubectl_path_documents.flux2-repos.documents)
  yaml_body = element(data.kubectl_path_documents.flux2-repos.documents, count.index)
}



data "kubectl_path_documents" "flux2-releases" {
  pattern = "./manifests/flux-releases/*.yaml"
}

resource "kubectl_manifest" "flux2-releases" {
  depends_on = [helm_release.flux2]
  count      = length(data.kubectl_path_documents.flux2-releases.documents)
  yaml_body  = element(data.kubectl_path_documents.flux2-releases.documents, count.index)
}
