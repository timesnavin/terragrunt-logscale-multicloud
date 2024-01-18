resource "kubernetes_config_map" "cluster_vars" {
  depends_on = [helm_release.flux2]
  metadata {
    name      = "clustervars"
    namespace = "flux-system"
  }

  data = {
    platformType                     = "aws"
    aws_eks_cluster_name             = data.aws_eks_cluster.this.name
    aws_region                       = var.cluster_region
    aws_arn_efs                      = module.efs_csi_irsa.iam_role_arn
    aws_arn_ebs                      = module.ebs_csi_irsa.iam_role_arn
    aws_arn_alb                      = module.ing_alb_irsa.iam_role_arn
    aws_arn_keda                     = module.keda_irsa.iam_role_arn
    aws_arn_edns                     = module.edns_irsa.iam_role_arn
    aws_arn_karpenter                = module.karpenter.irsa_arn
    aws_role_name_karpenter          = module.karpenter.role_name
    aws_eks_endpoint                 = data.aws_eks_cluster.this.endpoint,
    aws_eks_sqsinterruptionQueueName = module.karpenter.queue_name,
    aws_s3_log_bucket                = var.log_s3_bucket_id,    
  }

}

module "ing_alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix   = "alb"
  role_path          = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}


module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix   = "ebs_csi"
  role_path          = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix


  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

}

module "efs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix   = "efs_csi"
  role_path          = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

}


module "keda_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix   = "keda-operator"
  role_path          = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix


  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["keda-operator:keda-operator"]
    }
  }

}

module "edns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix   = "external-dns"
  role_path          = var.iam_role_path
  policy_name_prefix = var.iam_policy_name_prefix

  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns-sa"]
    }
  }

}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  cluster_name           = var.cluster_name
  irsa_oidc_provider_arn = var.oidc_provider_arn

  iam_role_use_name_prefix = true
  irsa_path                = var.iam_role_path
  # rule_name_prefix = "ll"

  # In v0.32.0/v1beta1, Karpenter now creates the IAM instance profile
  # so we disable the Terraform creation and add the necessary permissions for Karpenter IRSA
  enable_karpenter_instance_profile_creation = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

}
