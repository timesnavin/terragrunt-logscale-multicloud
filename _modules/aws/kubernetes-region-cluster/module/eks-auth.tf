
resource "aws_eks_access_entry" "clustrer_access" {
  for_each          = var.additional_aws_auth_roles
  cluster_name      = module.eks.cluster_name
  principal_arn     = each.value.rolearn
  kubernetes_groups = each.value.kubernetes_groups
  type              = "STANDARD"
}
