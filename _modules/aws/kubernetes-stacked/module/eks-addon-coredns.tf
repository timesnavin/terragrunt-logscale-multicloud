
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
          "preferredDuringSchedulingIgnoredDuringExecution" : [
            {
              "weight" : 100
              "preference" : {
                "matchExpressions" : [
                  {
                    "key" : "role"
                    "operator" : "NotIn"
                    "values" : ["system"]
                  }
                ]
              }
            },
            {
              "weight" : 100
              "preference" : {
                "matchExpressions" : [
                  {
                    "key" : "kubernetes.io/arch"
                    "operator" : "In"
                    "values" : ["arm64"]
                  }
                ]
              }
            }
          ]
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
          "whenUnsatisfiable" = "DoNotSchedule",
          "labelSelector" = {
            "matchLabels" = {
              "k8s-app" : "kube-dns"
            }
          }
        }
      ]
    }
  )
}
