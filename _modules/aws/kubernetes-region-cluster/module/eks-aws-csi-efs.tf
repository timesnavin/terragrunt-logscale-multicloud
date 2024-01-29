module "efs_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix = "efs_csi"

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "kubectl_manifest" "efs" {
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
      name: aws-efs
      namespace: flux-system
    spec:
      interval: 10m
      timeout: 5m
      chart:
        spec:
          chart: "aws-efs-csi-driver"
          version: "2.5.4"
          sourceRef:
            kind: HelmRepository
            name: aws-efs
          interval: 5m
      releaseName: aws-efs
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
        mode: enabled
        ignore:
          - paths: ["/spec/replicas"]
            target:
              kind: Deployment
      dependsOn:
        - name: cilium
      values:
        controller:
          serviceAccount:
            annotations:
              eks.amazonaws.com/role-arn: ${module.efs_irsa.iam_role_arn}
          # Specifies whether Leader Election resources should be created
          # Required when running as a Deployment
          # NOTE: Leader election can't be activated if DryRun enabled
          resources:
            requests:
              cpu: 500m
              memory: 256Mi
            limits:
              cpu: 1
              memory: 512Mi
          priorityClassName: "system-cluster-critical"

          affinity:
            podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchExpressions:
                      - key: app
                        operator: In
                        values:
                          - efs-csi-controller
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
                      - key: kubernetes.io/arch
                        operator: In
                        values:
                          - arm64
                - weight: 10
                  preference:
                    matchExpressions:
                      - key: storageClass
                        operator: In
                        values:
                          - network
          topologySpreadConstraints:
            - maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
              labelSelector:
                matchLabels:
                  app: efs-csi-controller
              matchLabelKeys:
                - pod-template-hash
          tolerations:
          - key: CriticalAddonsOnly
            operator: Exists
          - key: ebs.csi.aws.com/agent-not-ready
            operator: Exists
          - key: efs.csi.aws.com/agent-not-ready
            operator: Exists
        node:
          tolerations:
          - key: CriticalAddonsOnly
            operator: Exists
          - key: ebs.csi.aws.com/agent-not-ready
            operator: Exists
          - key: efs.csi.aws.com/agent-not-ready
            operator: Exists   
  YAML
}
