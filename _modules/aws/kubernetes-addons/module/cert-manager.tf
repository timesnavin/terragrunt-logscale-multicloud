module "iam_eks_role_crtmgmr" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"

  role_name_prefix = "cert-manager"
  role_path        = "/${var.eks_cluster_name}/"

  attach_cert_manager_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.eks_cluster_oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }

}



resource "helm_release" "cert-manager" {
  namespace        = "cert-manager"
  create_namespace = true

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.13.3"



  values = [
    <<-EOT
    installCRDs: true
    serviceAccount:
      name: cert-manager
      annotations:
        eks.amazonaws.com/role-arn: ${module.iam_eks_role_crtmgmr.iam_role_arn}
    EOT
  ]
}

