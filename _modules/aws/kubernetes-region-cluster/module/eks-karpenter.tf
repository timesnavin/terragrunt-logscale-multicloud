
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  iam_role_use_name_prefix = true

  # In v0.32.0/v1beta1, Karpenter now creates the IAM instance profile
  # so we disable the Terraform creation and add the necessary permissions for Karpenter IRSA
  enable_karpenter_instance_profile_creation = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "kubectl_manifest" "karpenter" {
  depends_on = [
    time_sleep.flux2repos
  ]
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta2
    kind: HelmRelease
    metadata:
      name: karpenter
      namespace: flux-system
    spec:
      interval: 10m
      timeout: 5m
      chart:
        spec:
          chart: karpenter
          version: "v0.33.1"
          sourceRef:
            kind: HelmRepository
            name: karpenter
          interval: 5m
      releaseName: karpenter
      targetNamespace: karpenter
      install:
        createNamespace: true
        remediation:
          retries: 3
      upgrade:
        remediation:
          retries: 3
      test:
        enable: false
      driftDetection:
        mode: enabled
        ignore:
          - paths: ["/spec/replicas"]
            target:
              kind: Deployment
      dependsOn:
        - name: cilium
      values:
        replicas: 2
        settings:
            clusterName: ${module.eks.cluster_name}
            clusterEndpoint: ${module.eks.cluster_endpoint}
            interruptionQueueName: ${module.karpenter.queue_name}
        serviceAccount:
            annotations:
                eks.amazonaws.com/role-arn: ${module.karpenter.irsa_arn}
        controller:
          resources:
            requests:
              cpu: 1
              memory: 256Mi
            limits:
              cpu: 1
              memory: 256Mi
        podDisruptionBudget:
          enabled: true
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              - labelSelector:
                  matchExpressions:
                    - key: app.kubernetes.io/component
                      operator: In
                      values:
                        - karpenter
                    - key: app.kubernetes.io/instance
                      operator: In
                      values:
                        - karpenter
                topologyKey: kubernetes.io/hostname
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                    - key: kubernetes.io/os
                      operator: In
                      values:
                        - linux
            preferredDuringSchedulingIgnoredDuringExecution:
              - weight: 100
                preference:
                  matchExpressions:
                    - key: role
                      operator: NotIn
                      values:
                        - system
              - weight: 100
                preference:
                  matchExpressions:
                    - key: kubernetes.io/arch
                      operator: In
                      values:
                        - arm64

        topologySpreadConstraints:
          - maxSkew: 1
            topologyKey: topology.kubernetes.io/zone
            whenUnsatisfiable: DoNotSchedule
            labelSelector:
              matchLabels:
                app.kubernetes.io/component: karpenter
                app.kubernetes.io/instance: karpenter
            matchLabelKeys:
              - pod-template-hash
        priorityClassName: "system-cluster-critical"
  YAML
}

locals {
  karpenter_subnets = [ # outside map with "prop" key and map value
    for subnet in var.subnets :
    { id = subnet }
  ]
}
resource "time_sleep" "karpenter" {
  depends_on       = [kubectl_manifest.karpenter]
  destroy_duration = "90s"
}
resource "kubectl_manifest" "node_classes" {
  depends_on = [
    time_sleep.karpenter
  ]
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta2
    kind: HelmRelease
    metadata:
      name: karpenter-node-classes
      namespace: flux-system
    spec:
      interval: 10m
      timeout: 5m
      chart:
        spec:
          chart: raw
          version: "2.0.0"
          sourceRef:
            kind: HelmRepository
            name: bedag
          interval: 5m
      releaseName: karpenter-node-classes
      targetNamespace: karpenter
      install:
        createNamespace: true
        remediation:
          retries: 3
      upgrade:
        remediation:
          retries: 3
      test:
        enable: false  
      dependsOn:
        - name: karpenter
      values:
        templates:
          - |
            apiVersion: karpenter.k8s.aws/v1beta1
            kind: EC2NodeClass
            metadata:
              name: bottle
            spec:
              amiFamily: Bottlerocket
              role: ${module.karpenter.role_name}
              subnetSelectorTerms: ${jsonencode(local.karpenter_subnets)}
              securityGroupSelectorTerms:
              - id: ${module.eks.node_security_group_id}
              tags:
                karpenter.sh/discovery: ${module.eks.cluster_name}
          - |
            apiVersion: karpenter.k8s.aws/v1beta1
            kind: EC2NodeClass
            metadata:
              name: al2
            spec:
              amiFamily: AL2
              role: ${module.karpenter.role_name}
              subnetSelectorTerms: ${jsonencode(local.karpenter_subnets)}
              securityGroupSelectorTerms:
              - id: ${module.eks.node_security_group_id}
              tags:
                karpenter.sh/discovery: ${module.eks.cluster_name}
          - |
            apiVersion: karpenter.k8s.aws/v1beta1
            kind: EC2NodeClass
            metadata:
              name: ubuntu
            spec:
              amiFamily: Ubuntu
              role: ${module.karpenter.role_name}
              subnetSelectorTerms: ${jsonencode(local.karpenter_subnets)}
              securityGroupSelectorTerms:
              - id: ${module.eks.node_security_group_id}
              tags:
                karpenter.sh/discovery: ${module.eks.cluster_name}
  YAML
}
resource "time_sleep" "node_classes" {
  depends_on       = [kubectl_manifest.node_classes]
  destroy_duration = "300s"
}
resource "kubectl_manifest" "node_pools" {
  depends_on = [
    time_sleep.node_classes
  ]
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta2
    kind: HelmRelease
    metadata:
      name: karpenter-node-pools
      namespace: flux-system
    spec:
      interval: 10m
      timeout: 5m
      chart:
        spec:
          chart: raw
          version: "2.0.0"
          sourceRef:
            kind: HelmRepository
            name: bedag
          interval: 5m
      releaseName: karpenter-node-pools
      targetNamespace: karpenter
      install:
        createNamespace: true
        remediation:
          retries: 3
      upgrade:
        remediation:
          retries: 3
      test:
        enable: false
      driftDetection:
        mode: warn
        ignore:
          - paths: ["/spec/replicas"]
            target:
              kind: Deployment
      dependsOn:
        - name: karpenter-node-classes      
      values:
        templates:
          - |
            apiVersion: karpenter.sh/v1beta1
            kind: NodePool
            metadata:
              name: general
            spec:
              template:
                metadata:
                  # Labels are arbitrary key-values that are applied to all nodes
                  labels:
                    storageClass: "network"
                spec:
                  nodeClassRef:
                    name: bottle
                  requirements:
                    - key: "kubernetes.io/os"
                      operator: In
                      values: ["linux"]              
                    - key: "karpenter.k8s.aws/instance-encryption-in-transit-supported"
                      operator: In
                      values: ["true"]
                    - key: "karpenter.k8s.aws/instance-hypervisor"
                      operator: In
                      values: ["nitro"]
                    - key: "karpenter.k8s.aws/instance-local-nvme"
                      operator: DoesNotExist
                    - key: "karpenter.k8s.aws/instance-category"
                      operator: In
                      values: ["c", "m", "r"]                                  
                  startupTaints:
                    - key: node.cilium.io/agent-not-ready
                      value: "true"
                      effect: NoExecute    
                    - key: ebs.csi.aws.com/agent-not-ready
                      value: "true"
                      effect: NoExecute    
                    - key: efs.csi.aws.com/agent-not-ready
                      value: "true"
                      effect: NoExecute    
                  kubelet:
                    podsPerCore: 4
              limits:
                cpu: 1000
              disruption:
                consolidationPolicy: WhenUnderutilized
              weight: 100
          - |
            apiVersion: karpenter.sh/v1beta1
            kind: NodePool
            metadata:
              name: storage
            spec:
              template:
                metadata:
                  # Labels are arbitrary key-values that are applied to all nodes
                  labels:
                    storageClass: "nvme"
                spec:
                  nodeClassRef:
                    name: ubuntu
                  requirements:
                    - key: "kubernetes.io/arch"
                      operator: In
                      values: ["amd64"]              
                    - key: "kubernetes.io/os"
                      operator: In
                      values: ["linux"]              
                    - key: "karpenter.k8s.aws/instance-encryption-in-transit-supported"
                      operator: In
                      values: ["true"]
                    - key: "karpenter.k8s.aws/instance-generation"
                      operator: Gt
                      values: ["3"]
                    - key: "karpenter.k8s.aws/instance-hypervisor"
                      operator: In
                      values: ["nitro"]
                    - key: "karpenter.k8s.aws/instance-category"
                      operator: In
                      values: ["i"]
                    - key: "karpenter.k8s.aws/instance-cpu"
                      operator: Gt
                      values: ["4"]
                  startupTaints:
                    - key: node.cilium.io/agent-not-ready
                      value: "true"
                      effect: NoExecute    
                    - key: ebs.csi.aws.com/agent-not-ready
                      value: "true"
                      effect: NoExecute    
                    - key: efs.csi.aws.com/agent-not-ready
                      value: "true"
                      effect: NoExecute   
                  # taints:
                  #   - key: topolvm.io/local
                  #     value: "true"
                  #     effect: PreferNoSchedule   
                  kubelet:
                    podsPerCore: 4
              limits:
                cpu: 1000
              disruption:
                consolidationPolicy: WhenUnderutilized
              weight: 20
YAML
}
