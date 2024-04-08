data "aws_ami" "eks_default_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-arm64-node-${var.cluster_version}-v*"]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name                   = var.name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  # IPV6
  cluster_ip_family = "ipv6"

  cluster_addons = {
    eks-pod-identity-agent = {
      addon_version               = "v1.2.0-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      preserve                    = true
      before_compute              = true
    }
    coredns = {
      addon_version               = "v1.11.1-eksbuild.6"
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
          "tolerations" = [
            {
              "key"      = "CriticalAddonsOnly"
              "operator" = "Exists"
            }
          ]
          "topologySpreadConstraints" = [
            {
              "maxSkew"           = 2,
              "topologyKey"       = "topology.kubernetes.io/zone",
              "whenUnsatisfiable" = "DoNotSchedule",
              "minDomains"        = 2
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
    vpc-cni = {
      before_compute           = true
      addon_version            = "v1.17.1-eksbuild.1"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
        }
      })
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.subnets

  kms_key_administrators = var.kms_key_administrators


  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  cloudwatch_log_group_retention_in_days = 3

  enable_cluster_creator_admin_permissions = false
  access_entries                           = var.access_entries

  eks_managed_node_groups = {
    system = {
      instance_types = ["m7g.2xlarge",
        "m6g.2xlarge"
      ]

      min_size     = 0
      max_size     = 9
      desired_size = 6

      ami_type = "AL2_ARM_64"
      platform = "linux"


      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "optional"
        http_put_response_hop_limit = 2
      }
      taints = [
        {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "PREFER_NO_SCHEDULE"
        },
        {
          key    = "node.cilium.io/agent-not-ready"
          value  = "true"
          effect = "NO_EXECUTE"
        }
      ]
    }

  }
  node_security_group_tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.name
    "aws-alb"                = true
  }

  create_cluster_primary_security_group_tags = true

  tags = {
    "karpenter.sh/discovery" = var.name
  }
}
