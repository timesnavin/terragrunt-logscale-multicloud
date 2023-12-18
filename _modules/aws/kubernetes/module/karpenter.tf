# module "karpenter" {
#   source  = "terraform-aws-modules/eks/aws//modules/karpenter"
#   version = "19.21.0"

#   cluster_name           = module.eks.cluster_name
#   irsa_oidc_provider_arn = module.eks.oidc_provider_arn

#   # In v0.32.0/v1beta1, Karpenter now creates the IAM instance profile
#   # so we disable the Terraform creation and add the necessary permissions for Karpenter IRSA
#   enable_karpenter_instance_profile_creation = true

#   # Used to attach additional IAM policies to the Karpenter node IAM role
#   iam_role_additional_policies = {
#     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   }

#   tags = local.tags
# }
