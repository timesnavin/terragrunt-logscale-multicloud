module "iam_eks_role_edns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"

  role_name_prefix = "external-dns"
  role_path        = "/${var.eks_cluster_name}/"

  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.eks_cluster_oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }

}



resource "helm_release" "external-dns" {
  namespace        = "external-dns"
  create_namespace = true

  name       = "external-dns"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "external-dns"
  version    = "6.28.6"

  wait = false

  values = [
    <<-EOT
    provider: aws
    replicaCount: 2
    podAntiAffinityPreset: hard
    podSecurityContext:
      fsGroup: 65534
      runAsUser: 0
    serviceAccount:
      name: external-dns
      annotations:
        eks.amazonaws.com/role-arn: ${module.iam_eks_role_edns.iam_role_arn}
    EOT
  ]
}

