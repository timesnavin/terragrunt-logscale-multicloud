module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  cluster_name           = var.cluster_name
  irsa_oidc_provider_arn = var.oidc_provider_arn

  iam_role_use_name_prefix = true
  irsa_path = var.iam_role_path
  rule_name_prefix = var.iam_policy_name_prefix
  
  # In v0.32.0/v1beta1, Karpenter now creates the IAM instance profile
  # so we disable the Terraform creation and add the necessary permissions for Karpenter IRSA
  enable_karpenter_instance_profile_creation = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

}


resource "helm_release" "karpentercrds" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpentercrds"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter-crd"
  version    = "v0.33.1"

  wait = true

}



resource "helm_release" "karpenter" {
  depends_on = [
    # kubernetes_config_map_v1_data.aws_auth,
    helm_release.karpentercrds,
    aws_eks_addon.coredns,
    aws_eks_addon.kube-proxy,
    aws_eks_addon.vpc-cni
  ]
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "v0.33.1"

  wait = true

  values = [
    templatefile("./eks-addon-karpenter-values.yaml",
      { clusterName           = data.aws_eks_cluster.this.name,
        clusterEndpoint       = data.aws_eks_cluster.this.endpoint,
        interruptionQueueName = module.karpenter.queue_name,
      irsaarn = module.karpenter.irsa_arn }
    )
  ]
}

resource "random_string" "seed" {
  length  = 4
  special = false
  numeric = false
  upper   = false
  keepers = {
    karpenter_role_name = module.karpenter.role_name
    eks_cluster_name    = data.aws_eks_cluster.this.name
  }

}


resource "kubectl_manifest" "karpenter_node_class_bottle" {

  yaml_body = <<-YAML
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: bottle-${random_string.seed.result}
spec:
  amiFamily: Bottlerocket
  role: ${module.karpenter.role_name}
  subnetSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${data.aws_eks_cluster.this.name}
  securityGroupSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${data.aws_eks_cluster.this.name}
  tags:
    karpenter.sh/discovery: ${data.aws_eks_cluster.this.name}
YAML

  depends_on = [
    helm_release.karpenter
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "kubectl_manifest" "karpenter_node_class_al2" {
  yaml_body = <<-YAML
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: al2-${random_string.seed.result}
spec:
  amiFamily: AL2
  role: ${module.karpenter.role_name}
  subnetSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${data.aws_eks_cluster.this.name}
  securityGroupSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${data.aws_eks_cluster.this.name}
  tags:
    karpenter.sh/discovery: ${data.aws_eks_cluster.this.name}
YAML

  depends_on = [
    time_sleep.karpenter
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "kubectl_manifest" "karpenter_compute_arm_node_pool" {
  yaml_body = <<-YAML
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: compute-net-arm64
spec:
  template:
    metadata:
      # Labels are arbitrary key-values that are applied to all nodes
      labels:
        computeType: "compute"
        storageType: "network"
        durabilityType: "provisioned"
    spec:
      nodeClassRef:
        name: bottle-${random_string.seed.result}
      requirements:
        - key: karpenter.sh/capacity-type
          operator: NotIn
          values: ["spot"]
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["c"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["4", "8", "16", "32"]
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values: ["nitro"]
        - key: "kubernetes.io/arch"
          operator: In
          values: ["arm64"]              
        - key: "karpenter.k8s.aws/instance-generation"
          operator: Gt
          values: ["5"]
      startupTaints:
        - key: ebs.csi.aws.com/agent-not-ready
          value: "true"
          effect: NoExecute    
        - key: efs.csi.aws.com/agent-not-ready
          value: "true"
          effect: NoExecute    
  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenUnderutilized
  weight: 50
    
YAML

  depends_on = [
    time_sleep.karpenter
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.karpenter_node_class_bottle
    ]
    create_before_destroy = true
  }
}


resource "kubectl_manifest" "karpenter_compute_intel_node_pool" {
  yaml_body = <<-YAML
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: compute-net-amd64
spec:
  template:
    metadata:
      # Labels are arbitrary key-values that are applied to all nodes
      labels:
        computeType: "compute"
        storageType: "network"
        durabilityType: "provisioned"
    spec:
      nodeClassRef:
        name: bottle-${random_string.seed.result}
      requirements:
        - key: karpenter.sh/capacity-type
          operator: NotIn
          values: ["spot"]          
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["c"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["4", "8", "16", "32"]
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values: ["nitro"]
        - key: "kubernetes.io/arch"
          operator: In
          values: ["amd64"]              
        - key: "karpenter.k8s.aws/instance-generation"
          operator: Gt
          values: ["5"]
      startupTaints:
        - key: ebs.csi.aws.com/agent-not-ready
          value: "true"
          effect: NoExecute    
        - key: efs.csi.aws.com/agent-not-ready
          value: "true"
          effect: NoExecute    

  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenUnderutilized
  weight: 40
YAML

  depends_on = [
    time_sleep.karpenter
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.karpenter_node_class_bottle
    ]
    create_before_destroy = true
  }
}


resource "kubectl_manifest" "karpenter_general_arm_node_pool" {
  yaml_body = <<-YAML
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: general-net-arm64
spec:
  template:
    metadata:
      # Labels are arbitrary key-values that are applied to all nodes
      labels:
        computeType: "general"
        storageType: "network"
        durabilityType: "provisioned"
    spec:
      nodeClassRef:
        name: bottle-${random_string.seed.result}
      requirements:
        - key: karpenter.sh/capacity-type
          operator: NotIn
          values: ["spot"]          
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["m"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["4", "8", "16", "32"]
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values: ["nitro"]
        - key: "kubernetes.io/arch"
          operator: In
          values: ["arm64"]              
        - key: "karpenter.k8s.aws/instance-generation"
          operator: Gt
          values: ["5"]
      startupTaints:
        - key: ebs.csi.aws.com/agent-not-ready
          value: "true"
          effect: NoExecute    
        - key: efs.csi.aws.com/agent-not-ready
          value: "true"
          effect: NoExecute    
  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenUnderutilized
    weight: 30
YAML

  depends_on = [
    time_sleep.karpenter
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.karpenter_node_class_bottle
    ]
    create_before_destroy = true
  }
}


resource "kubectl_manifest" "karpenter_general_intel_node_pool" {
  yaml_body = <<-YAML
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: general-net-amd64
spec:
  template:
    metadata:
      # Labels are arbitrary key-values that are applied to all nodes
      labels:
        computeType: "general"
        storageType: "network"
        durabilityType: "provisioned"
    spec:
      nodeClassRef:
        name: bottle-${random_string.seed.result}
      requirements:
        - key: karpenter.sh/capacity-type
          operator: NotIn
          values: ["spot"]          
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["m"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["4", "8", "16", "32"]
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values: ["nitro"]
        - key: "kubernetes.io/arch"
          operator: In
          values: ["amd64"]              
        - key: "karpenter.k8s.aws/instance-generation"
          operator: Gt
          values: ["5"]
      startupTaints:
        - key: ebs.csi.aws.com/agent-not-ready
          value: "true"
          effect: NoExecute    
        - key: efs.csi.aws.com/agent-not-ready
          value: "true"
          effect: NoExecute    

  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenUnderutilized
  weight: 29

YAML

  depends_on = [
    time_sleep.karpenter
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.karpenter_node_class_bottle
    ]
    create_before_destroy = true
  }
}



resource "kubectl_manifest" "karpenter_nvme_intel_node_pool" {
  yaml_body = <<-YAML
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: nvme-amd64
spec:
  template:
    metadata:
      # Labels are arbitrary key-values that are applied to all nodes
      labels:
        computeType: "compute"
        storageType: "local"
        durabilityType: "provisioned"
    spec:
      nodeClassRef:
        name: al2-${random_string.seed.result}
      requirements:
        - key: karpenter.sh/capacity-type
          operator: NotIn
          values: ["spot"]          
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["i"]
        - key: "karpenter.k8s.aws/instance-family"
          operator: In
          values: ["i4i"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["8"]
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values: ["nitro"]
        - key: "kubernetes.io/arch"
          operator: In
          values: ["amd64"]              
        - key: "karpenter.k8s.aws/instance-generation"
          operator: Gt
          values: ["3"]
      startupTaints:
        - key: ebs.csi.aws.com/agent-not-ready
          value: "true"
          effect: NoExecute    
        - key: efs.csi.aws.com/agent-not-ready
          value: "true"
          effect: NoExecute    
      taints:
        - key: storageClass
          value: nvme
          effect: PreferNoSchedule
  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenUnderutilized
  weight: 1

YAML

  depends_on = [
    time_sleep.karpenter
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.karpenter_node_class_al2
    ]
    create_before_destroy = true
  }
}

resource "time_sleep" "karpenter" {
  depends_on = [
    helm_release.karpenter
  ]
  destroy_duration = "30s"
}


resource "time_sleep" "karpenter_nodes" {
  depends_on = [
    time_sleep.karpenter,
    kubectl_manifest.karpenter_general_arm_node_pool,
    kubectl_manifest.karpenter_general_intel_node_pool,
    kubectl_manifest.karpenter_compute_arm_node_pool,
    kubectl_manifest.karpenter_compute_arm_node_pool,
    kubectl_manifest.karpenter_nvme_intel_node_pool
  ]
  create_duration = "1m"
  destroy_duration = "300s"
}
