module "iam_eks_role_alb" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"

  role_name_prefix = "alb-controller"
  role_path        = "/${var.eks_cluster_name}/"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.eks_cluster_oidc_provider_arn
      namespace_service_accounts = ["awslb-controller:aws-load-balancer-controller"]
    }
  }

}



resource "helm_release" "alb" {


  namespace        = "awslb-controller"
  create_namespace = true


  name       = "alb"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.6.2"



  values = [
    <<-EOT
clusterName: ${var.eks_cluster_name}
serviceAccount:
    #create: false
    name: aws-load-balancer-controller
    annotations:
        eks.amazonaws.com/role-arn: ${module.iam_eks_role_alb.iam_role_arn}    
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
