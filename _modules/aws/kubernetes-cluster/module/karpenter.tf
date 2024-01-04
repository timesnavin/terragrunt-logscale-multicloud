
resource "random_string" "seed" {
  length  = 4
  special = false
  numeric = false
  upper   = false
  keepers = {
    karpenter_role_name =  module.eks_blueprints_addons.karpenter.iam_role_name
    eks_cluster_name    = module.eks.cluster_name
  }

}

resource "kubernetes_manifest" "karpenter_node_class" {
  manifest = yamldecode(<<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default-${random_string.seed.result}
    spec:
      amiFamily: Bottlerocket
      role: ${module.eks_blueprints_addons.karpenter.iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
  YAML
  )

  depends_on = [
    module.eks_blueprints_addons
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "kubernetes_manifest" "karpenter_default_arm_node_pool" {
  manifest = yamldecode(<<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: compute-arm64
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
            name: default-${random_string.seed.result}
          requirements:
            - key: karpenter.sh/capacity-type
              operator: NotIn
              values: ["spot"]          
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["c", "m", "r"]
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
              values: ["2"]
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenUnderutilized
  YAML
  )

  depends_on = [
    module.eks_blueprints_addons
  ]
  lifecycle {
    replace_triggered_by = [
      kubernetes_manifest.karpenter_node_class
    ]
    create_before_destroy = true
  }
}


resource "kubernetes_manifest" "karpenter_default_intel_node_pool" {
  manifest = yamldecode(<<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: compute-amd64
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
            name: default-${random_string.seed.result}
          requirements:
            - key: karpenter.sh/capacity-type
              operator: NotIn
              values: ["spot"]          
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["c", "m", "r"]
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
              values: ["2"]
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenUnderutilized
  YAML
  )
  depends_on = [
    module.eks_blueprints_addons
  ]
  lifecycle {
    replace_triggered_by = [
      kubernetes_manifest.karpenter_node_class
    ]
    create_before_destroy = true
  }
}
