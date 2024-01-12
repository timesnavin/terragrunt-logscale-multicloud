resource "kubernetes_namespace" "argocd" {
  metadata {
    annotations = {
      name = "argocd"
    }
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  depends_on = [
  ]
  namespace = kubernetes_namespace.argocd.metadata.0.name

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.52.1"

  wait = true

  values = [file("./k8s-argocd-values.yaml")]
}

resource "time_sleep" "argocd" {
  depends_on = [
    helm_release.argocd
  ]
  create_duration = "2m"
}



data "kubernetes_secret" "argocd_auth_token" {
  depends_on = [time_sleep.argocd]
  metadata {
    name      = "casdoor.identity-db.credentials.postgresql.acid.zalan.do"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }
}