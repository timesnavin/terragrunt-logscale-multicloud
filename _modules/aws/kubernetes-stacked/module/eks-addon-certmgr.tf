data "kubectl_path_documents" "cert_manager_crds" {
  pattern = "./manifests/cert-manager/v1.13.3.yaml"
}

resource "kubectl_manifest" "cert_manager_crds" {
  for_each  = toset(data.kubectl_path_documents.cert_manager_crds.documents)
  yaml_body = each.value
}

resource "helm_release" "cert-manager" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    kubectl_manifest.cert_manager_crds
  ]
  namespace        = "cert-manager"
  create_namespace = true

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.13.3"

  wait = true

  values = [
    <<-YAML
    priorityClassName: "system-cluster-critical"
    webhook:
        replicaCount: 2        
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
                  - webhook
                - key: app.kubernetes.io/instance
                  operator: In
                  values:
                  - cert-manager
              topologyKey: topology.kubernetes.io/zone        
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
            - weight: 50
              preference:
                matchExpressions:
                - key: computeClass
                  operator: In
                  values:
                  - compute
            - weight: 10
              preference:
                matchExpressions:
                - key: computeClass
                  operator: In
                  values:
                  - general
        topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              app.kubernetes.io/component: webhook
              app.kubernetes.io/instance: cert-manager
          matchLabelKeys:
            - pod-template-hash              
    cainjector:
        replicaCount: 2
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
                  - cainjector
                - key: app.kubernetes.io/instance
                  operator: In
                  values:
                  - cert-manager
              topologyKey: topology.kubernetes.io/zone        
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
            - weight: 50
              preference:
                matchExpressions:
                - key: computeClass
                  operator: In
                  values:
                  - compute
            - weight: 10
              preference:
                matchExpressions:
                - key: computeClass
                  operator: In
                  values:
                  - general
        topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              app.kubernetes.io/component: cainjector
              app.kubernetes.io/instance: cert-manager   
          matchLabelKeys:
            - pod-template-hash                   
    YAML
  ]
}
# 
