data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cluster" {
  name               = "cluster"
  path               = var.iam_role_path
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}


# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

resource "aws_cloudwatch_log_group" "cluster" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 1

  # ... potentially other configuration ...
}

resource "aws_iam_role_policy" "cluster_logging" {
  name_prefix = "${var.cluster_name}-logging"
  role        = aws_iam_role.cluster.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.cluster.arn
      },
    ]
  })
}

resource "aws_eks_cluster" "this" {

  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  vpc_config {
    subnet_ids = var.control_plane_subnet_ids
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = module.kms.key_arn
    }
  }

  depends_on = [aws_cloudwatch_log_group.cluster]
}

# ################################################################################
# # EKS Module
# ################################################################################

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "19.21.0"

#   cluster_name    = var.cluster_name
#   cluster_version = var.cluster_version

#   cluster_endpoint_public_access = true


#   vpc_id                   = var.vpc_id
#   subnet_ids               = var.subnet_ids
#   control_plane_subnet_ids = var.control_plane_subnet_ids

#   # External encryption key
#   create_kms_key = false
#   cluster_encryption_config = {
#     resources        = ["secrets"]
#     provider_key_arn = module.kms.key_arn
#   }


#   cluster_enabled_log_types = [
#     "api",
#     "audit",
#     "authenticator",
#     "controllerManager",
#     "scheduler"
#   ]
#   cloudwatch_log_group_retention_in_days = 3

#   # Fargate profiles use the cluster primary security group so these are not utilized
#   create_cluster_security_group = false
#   create_node_security_group    = false


#   enable_irsa = true
#   # create_aws_auth_configmap = true
#   manage_aws_auth_configmap = true
#   # manage_aws_auth 
#   aws_auth_roles = concat(
#     # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
#     [{
#       rolearn  = module.karpenter.role_arn
#       username = "system:node:{{EC2PrivateDNSName}}"
#       groups = [
#         "system:bootstrappers",
#         "system:nodes",
#       ]
#       }
#     ],
#     var.additional_aws_auth_roles
#   )

#   aws_auth_users = [
#     # {
#     #   userarn  = data.aws_caller_identity.current.arn
#     #   username = "admin-caller"
#     #   groups   = ["system:masters"]
#     # },
#     {
#       userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#       username = "admin-aws-root"
#       groups   = ["system:masters"]
#     }
#   ]
#   aws_auth_accounts = [
#     data.aws_caller_identity.current.account_id
#   ]

#   fargate_profile_defaults = {
#     iam_role_additional_policies = {
#       additional = module.eks_blueprints_addons.fargate_fluentbit.iam_policy
#     }
#   }

#   fargate_profiles = {

#     karpenter = {
#       selectors = [
#         { namespace = "karpenter" }
#       ]
#     }
#     kube-system = {
#       selectors = [
#         { namespace = "kube-system" }
#       ]
#     }
#   }

#   eks_managed_node_group_defaults = {
#     # We are using the IRSA created below for permissions
#     # However, we have to provision a new cluster with the policy attached FIRST
#     # before we can disable. Without this initial policy,
#     # the VPC CNI fails to assign IPs and nodes cannot join the new cluster
#     iam_role_attach_cni_policy = true
#   }

#   # eks_managed_node_groups = {

#   #   # Default node group - as provided by AWS EKS
#   #   # "system-arm64" = {
#   #   #   min_size     = 1
#   #   #   max_size     = 7
#   #   #   desired_size = 1

#   #   #   instance_types = ["m7g.large"]
#   #   #   labels = {
#   #   #     computeClass = "general"
#   #   #     storageClass = "network"
#   #   #   }

#   #   #   taints = [
#   #   #     {
#   #   #       key    = "CriticalAddonsOnly"
#   #   #       value  = "true"
#   #   #       effect = "PREFER_NO_SCHEDULE"
#   #   #     }
#   #   #   ]

#   #   #   # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
#   #   #   # so we need to disable it to use the default template provided by the AWS EKS managed node group service
#   #   #   use_custom_launch_template = false

#   #   #   ami_type = "BOTTLEROCKET_ARM_64"
#   #   #   platform = "bottlerocket"
#   #   # }

#   #   "system-x86" = {
#   #     min_size     = 0
#   #     max_size     = 7
#   #     desired_size = 0

#   #     instance_types = ["m7i.xlarge"]
#   #     labels = {
#   #       computeClass = "general"
#   #       storageClass = "network"
#   #     }

#   #     taints = [
#   #       {
#   #         key    = "CriticalAddonsOnly"
#   #         value  = "true"
#   #         effect = "PREFER_NO_SCHEDULE"
#   #       }
#   #     ]

#   #     # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
#   #     # so we need to disable it to use the default template provided by the AWS EKS managed node group service
#   #     use_custom_launch_template = false

#   #     ami_type = "BOTTLEROCKET_x86_64"
#   #     platform = "bottlerocket"
#   #   }
#   # }

#   node_security_group_tags = {
#     # NOTE - if creating multiple security groups with this module, only tag the
#     # security group that Karpenter should utilize with the following tag
#     # (i.e. - at most, only one security group should have this tag in your account)
#     "karpenter.sh/discovery" = var.cluster_name
#     "aws-alb"                = true
#   }

#   create_cluster_primary_security_group_tags = true

#   tags = merge(local.tags, {
#     "karpenter.sh/discovery" = var.cluster_name
#   })
# }
