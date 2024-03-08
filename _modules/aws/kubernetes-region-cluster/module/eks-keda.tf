
module "keda_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.37.1"


  role_name_prefix = "keda-operator"


  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["keda-operator:keda-operator"]
    }
  }
}

resource "kubectl_manifest" "keda" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter
  ]
  yaml_body = templatefile("./manifests/helm-manifests/eks-keda.yaml", { iam_role_arn = module.keda_irsa.iam_role_arn, cluster_name = module.eks.cluster_name })

}
