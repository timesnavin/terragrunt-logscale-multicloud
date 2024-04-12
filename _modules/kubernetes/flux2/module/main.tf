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
  version          = "2.12.4"
  values = [<<YAML
logLevel: debug
cli:
  replicas: 2
  tolerations:
  - key: "CriticalAddonsOnly"
    operator: "Exists"
helmController:
  replicas: 2
  tolerations:
  - key: "CriticalAddonsOnly"
    operator: "Exists"
imageAutomationController:
  replicas: 2
  tolerations:
  - key: "CriticalAddonsOnly"
    operator: "Exists"
imageReflectionController:
  replicas: 2
  tolerations:
  - key: "CriticalAddonsOnly"
    operator: "Exists"
kustomizeController:
  replicas: 2
  tolerations:
  - key: "CriticalAddonsOnly"
    operator: "Exists"
notificationController:
  replicas: 2
  tolerations:
  - key: "CriticalAddonsOnly"
    operator: "Exists"
sourceController:
  replicas: 2
  tolerations:
  - key: "CriticalAddonsOnly"
    operator: "Exists"
  YAML
  ]
}
resource "time_sleep" "flux2" {
  depends_on       = [helm_release.flux2]
  destroy_duration = "300s"
}
