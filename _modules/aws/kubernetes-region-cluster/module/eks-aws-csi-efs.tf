module "efs_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.35.0"


  role_name_prefix = "efs_csi"

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "kubectl_manifest" "efs" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter,
    time_sleep.karpenter
  ]
  yaml_body = templatefile("./manifests/helm-manifests/eks-aws-csi-efs.yaml", { iam_role_arn = module.efs_irsa.iam_role_arn })
}
