module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.2.1"

  manage_aws_auth_configmap = true
}
