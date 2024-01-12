resource "helm_release" "argocd" {
  depends_on = [

    helm_release.cert-manager
  ]
  namespace = "argo"

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.52.1"

  wait = true

  values = [file("./k8s-argocd-values.yaml")]
}
