module "ing_alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix = "alb"
  role_path        = var.iam_role_path

  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}



data "kubectl_path_documents" "alb_controller_crds" {
  pattern = "./manifests/alb-controller/v2.6.1.yaml"
}

resource "kubectl_manifest" "alb_controller_crds" {
  for_each  = toset(data.kubectl_path_documents.alb_controller_crds.documents)
  yaml_body = each.value
}

resource "helm_release" "alb-controller" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    kubectl_manifest.alb_controller_crds,
    helm_release.cert-manager
  ]
  namespace = "kube-system"

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "alb-controller"
  version    = "v1.6.1"

  wait = true
  values = [
    templatefile("./eks-addon-ing-alb-values.yaml", { clusterName = var.cluster_name, irsaarn = module.ing_alb_irsa.iam_role_arn })
  ]


}
# 
