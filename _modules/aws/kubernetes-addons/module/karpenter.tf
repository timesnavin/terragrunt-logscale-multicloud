
################################################################################
# Karpenter
################################################################################




resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  # repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  # repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "v0.33.0"

  values = [
    <<-EOT
    settings:
      clusterName: ${var.eks_cluster_name}
      clusterEndpoint: ${var.eks_cluster_endpoint}
      interruptionQueueName: ${var.karpenter_queue_name}
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${var.karpenter_irsa_arn} 
    EOT
  ]

  # lifecycle {
  #   ignore_changes = [
  #     repository_password
  #   ]
  # }

}

resource "random_string" "seed" {
  length  = 4
  special = false
  numeric = false
  upper   = false
  keepers = {
    karpenter_role_name = var.karpenter_role_name
    eks_cluster_name    = var.eks_cluster_name
  }

}
resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default-${random_string.seed.result}
    spec:
      amiFamily: AL2
      role: ${var.karpenter_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.eks_cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.eks_cluster_name}
      tags:
        karpenter.sh/discovery: ${var.eks_cluster_name}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "kubectl_manifest" "karpenter_default_arm_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default-arm64
    spec:
      template:
        metadata:
          # Labels are arbitrary key-values that are applied to all nodes
          labels:
            computeType: "compute"
            storageType: "network"
            durabilityType: "spot"
        spec:
          nodeClassRef:
            name: default-${random_string.seed.result}
          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
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

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.karpenter_node_class
    ]
    create_before_destroy = true
  }
}


resource "kubectl_manifest" "karpenter_default_intel_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default-amd64
    spec:
      template:
        metadata:
          # Labels are arbitrary key-values that are applied to all nodes
          labels:
            computeType: "compute"
            storageType: "network"
            durabilityType: "spot"
        spec:
          nodeClassRef:
            name: default-${random_string.seed.result}
          requirements:
            - key: karpenter.sh/capacity-type
              operator: In
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

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
  lifecycle {
    replace_triggered_by = [
      kubectl_manifest.karpenter_node_class
    ]
    create_before_destroy = true
  }
}
