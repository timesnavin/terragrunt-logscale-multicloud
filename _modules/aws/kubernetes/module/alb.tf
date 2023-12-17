module "iam_eks_role_alb" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"

  role_name_prefix = "alb-controller"
  role_path        = var.iam_role_path

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["awslb-controller:aws-load-balancer-controller"]
    }
  }

  depends_on = [helm_release.alb]
}



resource "helm_release" "alb" {


  namespace        = "awslb-controller"
  create_namespace = true


  name       = "alb"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.6.1"

  wait = false

  values = [
    <<-EOT
clusterName: ${module.eks.cluster_name}
region: ${var.cluster_region} 
vpcId: ${var.vpc_id}
serviceAccount:
    #create: false
    name: aws-load-balancer-controller
    annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.irsa_arn}    
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi    
    EOT
  ]
}

