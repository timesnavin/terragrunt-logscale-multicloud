

module "edns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"

  role_name_prefix = "external-dns"

  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns-sa"]
    }
  }
}

resource "kubectl_manifest" "external-dns" {
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
      name: external-dns
      namespace: flux-system
    spec:
      interval: 10m
      timeout: 5m
      chart:
        spec:
          chart: external-dns
          version: "1.14.2"
          sourceRef:
            kind: HelmRepository
            name: external-dns
          interval: 5m
      releaseName: external-dns
      targetNamespace: external-dns
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
      values:
        serviceAccount:
          creat: true
          name: external-dns-sa
          annotations:
            eks.amazonaws.com/role-arn: ${module.edns_irsa.iam_role_arn}

        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 1
            memory: 256Mi
        podDisruptionBudget:
          enabled: true
        affinity:
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


  YAML
}

