module "edns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix = "external-dns"
  role_path        = var.iam_role_path

  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns-sa"]
    }
  }

}



resource "helm_release" "externaldns" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    kubectl_manifest.alb_controller_crds,
    helm_release.cert-manager
  ]
  namespace = "external-dns"

  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.13.1"

  wait = true
  values = [
    templatefile("./eks-addon-externaldns.yaml", { clusterName = var.cluster_name, irsaarn = module.edns_irsa.iam_role_arn })
  ]


}