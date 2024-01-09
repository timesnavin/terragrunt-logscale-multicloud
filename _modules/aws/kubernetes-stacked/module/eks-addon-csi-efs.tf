module "efs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix = "efs_csi"
  role_path        = var.iam_role_path

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

}

resource "helm_release" "efs_csi" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter
  ]
  namespace = "kube-system"

  name       = "aws-efs-csi"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  version    = "2.5.3"

  wait = false

  values = [templatefile("./eks-addon-csi-efs.yaml", { irsaarn = module.efs_csi_irsa.iam_role_arn })]
}
