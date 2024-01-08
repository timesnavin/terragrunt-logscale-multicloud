locals {

  fargate_profile_pod_execution_role_arns = [
    # module.coredns_fargate_profile.iam_role_arn,
    module.karpenter.role_arn
  ]

  aws_auth_configmap_data = {
    mapRoles = yamlencode(concat(
      [for role_arn in local.fargate_profile_pod_execution_role_arns : {
        rolearn  = role_arn
        username = "system:node:{{SessionName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
          "system:node-proxier",
        ]
        }
      ],
      [{
        rolearn  = module.karpenter.role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
        }
      ],
      [{
        rolearn  = var.system_node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
        }
      ],
      var.additional_aws_auth_roles
    ))
  }
}


resource "kubernetes_config_map_v1_data" "aws_auth" {

  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data


}
