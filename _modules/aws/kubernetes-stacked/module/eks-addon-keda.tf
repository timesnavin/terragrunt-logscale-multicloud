module "keda_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix = "keda-operator"
  role_path        = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix

  
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["keda-operator:keda-operator"]
    }
  }

}

resource "helm_release" "keda_irsa" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    helm_release.cert-manager
  ]
  create_namespace = true
  namespace = "keda-operator"

  name       = "keda-operator"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "keda-operator"
  version    = "2.5.3"

  wait = false

  values = [templatefile("./eks-addon-keda.yaml", { irsaarn = module.keda_irsa.iam_role_arn })]
}
