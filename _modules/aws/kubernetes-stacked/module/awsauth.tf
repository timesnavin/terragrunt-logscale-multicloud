locals {

  fargate_profile_pod_execution_role_arns = [
    module.coredns_fargate_profile.iam_role_arn,
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
      ]
    ))
  }
}

# resource "kubernetes_config_map" "aws_auth" {

#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = local.aws_auth_configmap_data

#   lifecycle {
#     # We are ignoring the data here since we will manage it with the resource below
#     # This is only intended to be used in scenarios where the configmap does not exist
#     ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
#   }
# }

resource "kubernetes_config_map_v1_data" "aws_auth" {

  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

 
}
