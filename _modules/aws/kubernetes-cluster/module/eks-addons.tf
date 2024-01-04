#https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.12.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    coredns = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    vpc-cni = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    eks-pod-identity-agent = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  enable_aws_load_balancer_controller = true

  enable_aws_efs_csi_driver = true

  enable_metrics_server = true
  enable_vpa            = true

  enable_external_dns = true

  enable_cert_manager = true

  helm_releases = {
    karpentercrds = {
      description      = "A Helm chart for k8s karpenter"
      namespace        = "karpenter"
      create_namespace = true
      chart            = "karpenter-crd"
      chart_version    = "v0.33.0"
      repository       = "oci://public.ecr.aws/karpenter"
    }
    karpenter = {
      description      = "A Helm chart for k8s karpenter"
      namespace        = "karpenter"
      create_namespace = true
      chart            = "karpenter"
      chart_version    = "v0.33.0"
      repository       = "oci://public.ecr.aws/karpenter"
      skip_crds        = true
      values = [<<-YAML
        settings:
          clusterName: "${module.eks.cluster_name}"
          clusterEndpoint: ${module.eks.cluster_endpoint}
          interruptionQueueName: ${module.karpenter.queue_name}
        serviceAccount:
          annotations:
            eks.amazonaws.com/role-arn: ${module.karpenter.irsa_arn}           
        controller:
          resources:
            requests:
              cpu: 1
              memory: 256Mi
            limits:
              cpu: 1
              memory: 256Mi                
        YAML
      ]
    }
  }
}