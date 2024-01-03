#we create the role here but use it in the add-on module
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  cluster_name                    = module.eks.cluster_name
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["kube-system:karpenter"]

  iam_role_path = "/${module.eks.cluster_name}/"

  # In v0.32.0/v1beta1, Karpenter now creates the IAM instance profile
  # so we disable the Terraform creation and add the necessary permissions for Karpenter IRSA
  enable_karpenter_instance_profile_creation = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

}


resource "random_string" "seed" {
  length  = 4
  special = false
  numeric = false
  upper   = false
  keepers = {
    karpenter_role_name = module.karpenter.role_name
    eks_cluster_name    = module.eks.cluster_name
  }

}