
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  iam_role_use_name_prefix = true

  # In v0.32.0/v1beta1, Karpenter now creates the IAM instance profile
  # so we disable the Terraform creation and add the necessary permissions for Karpenter IRSA
  enable_karpenter_instance_profile_creation = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "kubectl_manifest" "karpenter" {
  depends_on = [
    time_sleep.flux2repos
  ]
  yaml_body = templatefile(
    "./manifests/helm-manifests/eks-karpenter.yaml",
    {
      cluster_name     = module.eks.cluster_name,
      cluster_endpoint = module.eks.cluster_endpoint
      queue_name       = module.karpenter.queue_name,
      irsa_arn         = module.karpenter.irsa_arn
    }
  )
}

locals {
  karpenter_subnets = [ # outside map with "prop" key and map value
    for subnet in var.subnets :
    { id = subnet }
  ]
}
resource "time_sleep" "karpenter" {
  depends_on       = [kubectl_manifest.karpenter]
  destroy_duration = "90s"
}
resource "kubectl_manifest" "node_classes" {
  depends_on = [
    time_sleep.karpenter
  ]
  yaml_body = templatefile(
    "./manifests/helm-manifests/eks-karpenter-nodeclasses.yaml",
    {
      role_name              = module.karpenter.role_name
      subnet_selector        = local.karpenter_subnets
      node_security_group_id = module.eks.node_security_group_id,
      cluster_name           = module.eks.cluster_name
    }
  )
}
resource "time_sleep" "node_classes" {
  depends_on       = [kubectl_manifest.node_classes]
  destroy_duration = "300s"
}
resource "kubectl_manifest" "node_pools" {
  depends_on = [
    time_sleep.node_classes
  ]
  yaml_body = templatefile(
    "./manifests/helm-manifests/eks-karpenter-nodepools.yaml",
    {
    }
  )
}
