
module "keda_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"


  role_name_prefix = "keda-operator"


  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["keda-operator:keda-operator"]
    }
  }
}

resource "kubectl_manifest" "keda" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter
  ]
  yaml_body = <<-YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta2
kind: HelmRelease
metadata:
  name: keda
  namespace: flux-system
spec:
  interval: 10m
  timeout: 5m
  chart:
    spec:
      chart: keda
      version: "2.13.1"
      sourceRef:
        kind: HelmRepository
        name: kedacore
      interval: 5m
  releaseName: keda-operator
  targetNamespace: keda-operator
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
    - name: metrics-server
    - name: cert-manager
  valuesFrom:
    - kind: ConfigMap
      name: clustervars
      valuesKey: aws_arn_keda
      targetPath: podIdentity.aws.irsa.roleArn
  values:
    podIdentity:
      aws:
        irsa:
          roleArn: ${module.keda_irsa.iam_role_arn}
          enabled: true
    logging:
      operator:
        format: json
      webhooks:
        format: json
    certificates:
      certManager:
        enabled: true
    operator:
      replicaCount: 2
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - keda-operator
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


    metricServer:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - keda-operator-metrics-apiserver
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


    webhooks:
      replicaCount: 2
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - keda-admission-webhooks
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
              app: keda-admission-webhooks
          matchLabelKeys:
            - pod-template-hash
      priorityClassName: "system-cluster-critical"

  YAML
}

