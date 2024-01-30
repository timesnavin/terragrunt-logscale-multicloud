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
  version = "19.21.0"

  cluster_name                   = var.name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  # IPV6
  cluster_ip_family = "ipv6"

  cluster_addons = {
    coredns = {
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
          "tolerations" = [
            {
              "key"      = "CriticalAddonsOnly"
              "operator" = "Exists"
            }
          ]
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
    # kube-proxy = {
    #   before_compute = true
    # }
    vpc-cni = {
      before_compute           = true
      addon_version            = "v1.16.2-eksbuild.1"
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

  manage_aws_auth_configmap = true
  aws_auth_roles = concat(
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    [{
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
      }
    ],
    var.additional_aws_auth_roles
  )

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      username = "admin-aws-root"
      groups   = ["system:masters"]
    }
  ]
  aws_auth_accounts = [
    data.aws_caller_identity.current.account_id
  ]

  eks_managed_node_groups = {
    system = {
      instance_types = ["m7g.2xlarge",
        "m6g.2xlarge"
      ]

      min_size     = 6
      max_size     = 9
      desired_size = 6

      ami_type = "AL2_ARM_64"
      platform = "linux"
      # ami_id                     = data.aws_ami.eks_default_arm.image_id
      # enable_bootstrap_user_data = true

      # pre_bootstrap_user_data = <<-EOT
      #   echo MTU="3498">>/etc/sysconfig/network-scripts/ifcfg-eth0
      #   echo request subnet-mask, broadcast-address, time-offset, routers, domain-name, domain-search, domain-name-servers, host-name, nis-domain, nis-servers, ntp-servers;>/etc/dhcp/dhclient.conf
      #   ip link set dev eth0 mtu 3498
      #   ip link show eth0
      #   x=$(( $(ethtool -l eth0 | grep Combined | tail -1 | sed 's|Combined:\s*||g') /2))
      #   echo ethtool -L eth0 combined $x
      #   ethtool -L eth0 combined 2
      # EOT

      # post_bootstrap_user_data = <<-EOT
      #   ip link show eth0
      #   ethtool -l eth0
      # EOT

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
        # {
        #   key    = "node.cilium.io/agent-not-ready"
        #   value  = "true"
        #   effect = "NO_EXECUTE"
        # }
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
