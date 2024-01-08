# module "coredns_fargate_profile" {
#   source  = "terraform-aws-modules/eks/aws//modules/fargate-profile"
#   version = "19.21.0"

#   name         = "coredns"
#   cluster_name = var.cluster_name


#   subnet_ids = var.node_subnet_ids
#   selectors = [{
#     namespace = "kube-system"
#     labels = {
#       k8s-app = "kube-dns"
#     }
#   }]

# }

resource "aws_eks_addon" "coredns" {
  # depends_on                  = [module.coredns_fargate_profile]
  cluster_name                = var.cluster_name
  addon_name                  = "coredns"
  addon_version               = "v1.10.1-eksbuild.6"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  preserve                    = true
  configuration_values = jsonencode(
    {
      replicaCount = 3
      resources = {
        limits = {
          cpu    = ".25"
          memory = "128Mi"
        }
        requests = {
          cpu    = ".25"
          memory = "128Mi"
        }
      }
      "podDisruptionBudget" : {
        "enabled" : true,
        "maxUnavailable" : 1
      }
      "affinity" : {
        "nodeAffinity" : {
          "requiredDuringSchedulingIgnoredDuringExecution" : {
            "nodeSelectorTerms" : [
              {
                "matchExpressions" : [
                  {
                    "key" : "kubernetes.io/os",
                    "operator" : "In",
                    "values" : [
                      "linux"
                    ]
                  }
                ]
              }
            ]
          }
        },
        "podAntiAffinity" : {
          "preferredDuringSchedulingIgnoredDuringExecution" : [
            {
              "podAffinityTerm" : {
                "labelSelector" : {
                  "matchExpressions" : [
                    {
                      "key" : "k8s-app",
                      "operator" : "In",
                      "values" : [
                        "kube-dns"
                      ]
                    }
                  ]
                },
                "topologyKey" : "kubernetes.io/hostname"
              },
              "weight" : 100
            }
          ]
        }
      }
      "topologySpreadConstraints" = [
        {
          "maxSkew"           = 1,
          "topologyKey"       = "topology.kubernetes.io/zone",
          "whenUnsatisfiable" = "ScheduleAnyway",
          "labelSelector" = {
            "matchLabels" = {
              "eks.amazonaws.com/component" : "coredns"
            }
          }
        }
      ]
    }
  )
}


resource "kubernetes_annotations" "coredns" {
  depends_on = [aws_eks_addon.coredns]

  api_version = "apps/v1"
  kind        = "Deployment"
  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }
  # These annotations will be applied to the Pods created by the Deployment
  template_annotations = {
    "eks.amazonaws.com/compute-type" = "fargate"
  }
}
