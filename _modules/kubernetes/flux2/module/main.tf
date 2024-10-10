resource "kubernetes_namespace" "flux-system" {
  metadata {
    annotations = {
      name = "flux-system"
    }
    name = "flux-system"
  }
}

resource "kubernetes_namespace" "region-flux-releases" {
  metadata {
    annotations = {
      name = "region-flux-releases"
    }
    name = "region-flux-releases"
  }
}

resource "helm_release" "flux2" {
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "flux2"
  namespace        = kubernetes_namespace.flux-system.metadata.0.name
  create_namespace = false
  version          = "2.4.0"

  values = [<<YAML
logs:
  level: debug #Set Global log level

# Global tolerations (applied to all controllers)
tolerations:
  - key: "CriticalAddonsOnly"
    operator: "Exists"
  
controllers:
  sourceController:
    replicaCount: 2
    resources:
      limits:
        cpu: "200m"
        memory: "256Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"

helmController:
    replicaCount: 2
    resources:
      limits:
        cpu: "200m"
        memory: "256Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"

    
imageAutomationController:
    replicaCount: 2
    resources:
      limits:
        cpu: "200m"
        memory: "256Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"

imageReflectionController:
    replicaCount: 2
    resources:
      limits:
        cpu: "200m"
        memory: "256Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"

kustomizeController:
    replicaCount: 2
    resources:
      limits:
        cpu: "200m"
        memory: "256Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"

notificationController:
    replicaCount: 2
    resources:
      limits:
        cpu: "200m"
        memory: "256Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"

sourceController:
    replicaCount: 2
    resources:
      limits:
        cpu: "200m"
        memory: "256Mi"
      requests:
        cpu: "100m"
        memory: "128Mi"
  YAML
  ]
}
resource "time_sleep" "flux2" {
  depends_on       = [helm_release.flux2]
  destroy_duration = "130s"
}
####################
data "kubectl_path_documents" "flux2-repos" {
  pattern = "./manifests/flux-repos/*.yaml"
}

resource "kubectl_manifest" "flux2-repos" {
  depends_on = [
    time_sleep.flux2
  ]
  for_each  = data.kubectl_path_documents.flux2-repos.manifests
  yaml_body = each.value
}

resource "time_sleep" "flux2repos" {
  depends_on       = [kubectl_manifest.flux2-repos]
  destroy_duration = "180s"
}

data "kubectl_path_documents" "flux2-releases" {
  pattern = "./manifests/flux-releases/*.yaml"
}

resource "kubectl_manifest" "flux2-releases" {
  depends_on = [
    time_sleep.flux2repos
  ]
  for_each  = data.kubectl_path_documents.flux2-releases.manifests
  yaml_body = each.value
}
