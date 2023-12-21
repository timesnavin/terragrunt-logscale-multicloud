module "iam_eks_role_ebs" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"

  role_name_prefix = "ebs-controller"
  role_path        = "/${var.eks_cluster_name}/"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.eks_cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

}
