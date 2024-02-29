module "ebs_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.35.0"


  role_name_prefix = "ebs_csi"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "kubectl_manifest" "ebs" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter
  ]
  yaml_body = templatefile("./manifests/helm-manifests/eks-aws-csi-ebs.yaml", { iam_role_arn = module.ebs_irsa.iam_role_arn })
}


resource "kubernetes_annotations" "remove_gp2_default" {
  depends_on = [kubectl_manifest.flux2-releases]

  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
  force = true
}
