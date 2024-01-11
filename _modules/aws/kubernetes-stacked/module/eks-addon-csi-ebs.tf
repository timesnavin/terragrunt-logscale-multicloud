module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix = "ebs_csi"
  role_path        = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix
  

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

}

resource "helm_release" "ebs_csi" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter
  ]
  namespace = "kube-system"

  name       = "aws-ebs-csi"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.26.1"

  wait = false

  values = [templatefile("./eks-addon-csi-ebs.yaml", { irsaarn = module.ebs_csi_irsa.iam_role_arn })]
}


resource kubectl_manifest "ebs_gp3" {
  depends_on = [
    helm_release.ebs_csi
  ]
  yaml_body  = <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
parameters:
  fsType: ext4
  type: gp3
provisioner: ebs.csi.aws.com
reclaimPolicy: Retain
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer   
YAML
  }