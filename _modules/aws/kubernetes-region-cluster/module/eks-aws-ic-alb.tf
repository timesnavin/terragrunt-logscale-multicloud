module "alb_ing_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix = "alb_ic"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "kubectl_manifest" "alb_ic" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter,
    time_sleep.karpenter
  ]
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta2
    kind: HelmRelease
    metadata:
      name: aws-load-balancer-controller
      namespace: flux-system
    spec:
      interval: 10m
      timeout: 5m
      chart:
        spec:
          chart: aws-load-balancer-controller
          version: "v1.6.2"
          sourceRef:
            kind: HelmRepository
            name: aws-eks
          interval: 5m
      releaseName: aws-load-balancer-controller
      targetNamespace: kube-system
      install:
        crds: CreateReplace
        remediation:
          retries: 3
      upgrade:
        crds: CreateReplace
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
      
      values:
        enableCertManager: true
        replicas: 2

        defaultTargetType: ip
        ingressClass: null
        createIngressClassResource: false
        clusterName: ${module.eks.cluster_name}
        serviceAccount:
          annotations:
            eks.amazonaws.com/role-arn: ${module.alb_ing_irsa.iam_role_arn}
        controller:
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
            limits:
              cpu: 1
              memory: 256Mi
        podDisruptionBudget:
          enabled: true
          maxUnavailable: 1
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              - labelSelector:
                  matchExpressions:
                    - key: app.kubernetes.io/name
                      operator: In
                      values:
                        - aws-load-balancer-controller
                    - key: app.kubernetes.io/instance
                      operator: In
                      values:
                        - aws-load-balancer-controller
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
                app.kubernetes.io/name: aws-load-balancer-controller
                app.kubernetes.io/instance: aws-load-balancer-controller
            matchLabelKeys:
              - pod-template-hash
        priorityClassName: "system-cluster-critical"
    
  YAML
}



resource "kubectl_manifest" "alb_ic_config" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter,
    time_sleep.karpenter,
    kubectl_manifest.alb_ic
  ]
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta2
    kind: HelmRelease
    metadata:
      name: aws-load-balancer-classes
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
      releaseName: aws-load-balancer-classes
      targetNamespace: kube-system
      install:
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
        - name: aws-load-balancer-controller
      values:
        templates:
          - |
            apiVersion: networking.k8s.io/v1
            kind: IngressClass
            metadata:
              name: alb-partition
            spec:
              controller: ingress.k8s.aws/alb
              parameters:
                apiGroup: elbv2.k8s.aws
                kind: IngressClassParams
                name: alb-partition
          - |
            apiVersion: elbv2.k8s.aws/v1beta1
            kind: IngressClassParams
            metadata:
              name: alb-partition
            spec:
              scheme: internet-facing
              ipAddressType: ipv4
              group: 
                name: partition
              loadBalancerAttributes:
                - key: access_logs.s3.enabled
                  value: "true"
                - key: access_logs.s3.bucket
                  value: ${var.log_s3_bucket_id}
                - key: deletion_protection.enabled
                  value: "true"
          - |
            apiVersion: networking.k8s.io/v1
            kind: IngressClass
            metadata:
              name: alb-region
            spec:
              controller: ingress.k8s.aws/alb
              parameters:
                apiGroup: elbv2.k8s.aws
                kind: IngressClassParams
                name: alb-region
          - |
            apiVersion: elbv2.k8s.aws/v1beta1
            kind: IngressClassParams
            metadata:
              name: alb-region
            spec:
              scheme: internet-facing
              ipAddressType: ipv4
              group: 
                name: region
              loadBalancerAttributes:
                - key: access_logs.s3.enabled
                  value: "true"
                - key: access_logs.s3.bucket
                  value: ${var.log_s3_bucket_id}
                - key: deletion_protection.enabled
                  value: "true"
    
    
  YAML
}
