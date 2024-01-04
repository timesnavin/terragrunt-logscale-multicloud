
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.12.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  #   enable_aws_load_balancer_controller    = true
  #   enable_cluster_proportional_autoscaler = true
  enable_karpenter = true
  #   enable_kube_prometheus_stack           = true
  enable_metrics_server = true
  #   enable_external_dns                    = true
  #   enable_cert_manager                    = true
  #   cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  enable_fargate_fluentbit = true
  fargate_fluentbit = {
    flb_log_cw        = true
    retention_in_days = 3
  }
}