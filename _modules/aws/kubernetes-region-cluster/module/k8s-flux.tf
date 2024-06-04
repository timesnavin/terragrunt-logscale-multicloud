resource "helm_release" "flux2" {
  depends_on = [
    helm_release.cilium

  ]
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "flux2"
  namespace        = "flux-system"
  create_namespace = false
  version          = "2.13.0"
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
