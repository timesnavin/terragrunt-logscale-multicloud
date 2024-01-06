module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  # In v0.32.0/v1beta1, Karpenter now creates the IAM instance profile
  # so we disable the Terraform creation and add the necessary permissions for Karpenter IRSA
  enable_karpenter_instance_profile_creation = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

}


resource "random_string" "seed" {
  length  = 4
  special = false
  numeric = false
  upper   = false
  keepers = {
    karpenter_role_name = module.karpenter.role_name
    eks_cluster_name    = module.eks.cluster_name
  }

}

# resource "kubectl_manifest" "karpenter_node_class_bottle" {
#   yaml_body = <<-YAML
# apiVersion: karpenter.k8s.aws/v1beta1
# kind: EC2NodeClass
# metadata:
#   name: bottle-${random_string.seed.result}
# spec:
#   amiFamily: Bottlerocket
#   role: ${module.karpenter.role_name}
#   subnetSelectorTerms:
#   - tags:
#       karpenter.sh/discovery: ${module.eks.cluster_name}
#   securityGroupSelectorTerms:
#   - tags:
#       karpenter.sh/discovery: ${module.eks.cluster_name}
#   tags:
#     karpenter.sh/discovery: ${module.eks.cluster_name}
# YAML

#   depends_on = [
#     module.eks_blueprints_addons
#   ]
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "kubectl_manifest" "karpenter_node_class_al2" {
#   yaml_body = <<-YAML
# apiVersion: karpenter.k8s.aws/v1beta1
# kind: EC2NodeClass
# metadata:
#   name: al2-${random_string.seed.result}
# spec:
#   amiFamily: AL2
#   role: ${module.karpenter.role_name}
#   subnetSelectorTerms:
#   - tags:
#       karpenter.sh/discovery: ${module.eks.cluster_name}
#   securityGroupSelectorTerms:
#   - tags:
#       karpenter.sh/discovery: ${module.eks.cluster_name}
#   tags:
#     karpenter.sh/discovery: ${module.eks.cluster_name}
# YAML

#   depends_on = [
#     module.eks_blueprints_addons
#   ]
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "kubectl_manifest" "karpenter_compute_arm_node_pool" {
#   yaml_body = <<-YAML
# apiVersion: karpenter.sh/v1beta1
# kind: NodePool
# metadata:
#   name: compute-net-arm64
# spec:
#   template:
#     metadata:
#       # Labels are arbitrary key-values that are applied to all nodes
#       labels:
#         computeType: "compute"
#         storageType: "network"
#         durabilityType: "provisioned"
#     spec:
#       nodeClassRef:
#         name: bottle-${random_string.seed.result}
#       requirements:
#         - key: karpenter.sh/capacity-type
#           operator: NotIn
#           values: ["spot"]          
#         - key: "karpenter.k8s.aws/instance-category"
#           operator: In
#           values: ["c", "m", "r"]
#         - key: "karpenter.k8s.aws/instance-cpu"
#           operator: In
#           values: ["4", "8", "16", "32"]
#         - key: "karpenter.k8s.aws/instance-hypervisor"
#           operator: In
#           values: ["nitro"]
#         - key: "kubernetes.io/arch"
#           operator: In
#           values: ["arm64"]              
#         - key: "karpenter.k8s.aws/instance-generation"
#           operator: Gt
#           values: ["2"]
#   limits:
#     cpu: 1000
#   disruption:
#     consolidationPolicy: WhenUnderutilized
# YAML

#   depends_on = [
#     module.eks_blueprints_addons
#   ]
#   lifecycle {
#     replace_triggered_by = [
#       kubectl_manifest.karpenter_node_class_bottle
#     ]
#     create_before_destroy = true
#   }
# }


# resource "kubectl_manifest" "karpenter_compute_intel_node_pool" {
#   yaml_body = <<-YAML
# apiVersion: karpenter.sh/v1beta1
# kind: NodePool
# metadata:
#   name: compute-net-amd64
# spec:
#   template:
#     metadata:
#       # Labels are arbitrary key-values that are applied to all nodes
#       labels:
#         computeType: "compute"
#         storageType: "network"
#         durabilityType: "provisioned"
#     spec:
#       nodeClassRef:
#         name: bottle-${random_string.seed.result}
#       requirements:
#         - key: karpenter.sh/capacity-type
#           operator: NotIn
#           values: ["spot"]          
#         - key: "karpenter.k8s.aws/instance-category"
#           operator: In
#           values: ["c", "m", "r"]
#         - key: "karpenter.k8s.aws/instance-cpu"
#           operator: In
#           values: ["4", "8", "16", "32"]
#         - key: "karpenter.k8s.aws/instance-hypervisor"
#           operator: In
#           values: ["nitro"]
#         - key: "kubernetes.io/arch"
#           operator: In
#           values: ["amd64"]              
#         - key: "karpenter.k8s.aws/instance-generation"
#           operator: Gt
#           values: ["2"]
#   limits:
#     cpu: 1000
#   disruption:
#     consolidationPolicy: WhenUnderutilized
# YAML

#   depends_on = [
#     module.eks_blueprints_addons
#   ]
#   lifecycle {
#     replace_triggered_by = [
#       kubectl_manifest.karpenter_node_class_bottle
#     ]
#     create_before_destroy = true
#   }
# }



# resource "kubectl_manifest" "karpenter_nvme_intel_node_pool" {
#   yaml_body = <<-YAML
# apiVersion: karpenter.sh/v1beta1
# kind: NodePool
# metadata:
#   name: nvme-amd64
# spec:
#   template:
#     metadata:
#       # Labels are arbitrary key-values that are applied to all nodes
#       labels:
#         computeType: "compute"
#         storageType: "local"
#         durabilityType: "provisioned"
#     spec:
#       nodeClassRef:
#         name: al2-${random_string.seed.result}
#       requirements:
#         - key: karpenter.sh/capacity-type
#           operator: NotIn
#           values: ["spot"]          
#         - key: "karpenter.k8s.aws/instance-category"
#           operator: In
#           values: ["i"]
#         - key: "karpenter.k8s.aws/instance-family"
#           operator: In
#           values: ["i4i"]
#         - key: "karpenter.k8s.aws/instance-cpu"
#           operator: In
#           values: ["8"]
#         - key: "karpenter.k8s.aws/instance-hypervisor"
#           operator: In
#           values: ["nitro"]
#         - key: "kubernetes.io/arch"
#           operator: In
#           values: ["amd64"]              
#         - key: "karpenter.k8s.aws/instance-generation"
#           operator: Gt
#           values: ["2"]
#   limits:
#     cpu: 1000
#   disruption:
#     consolidationPolicy: WhenUnderutilized
# YAML

#   depends_on = [
#     module.eks_blueprints_addons
#   ]
#   lifecycle {
#     replace_triggered_by = [
#       kubectl_manifest.karpenter_node_class_al2
#     ]
#     create_before_destroy = true
#   }
# }
