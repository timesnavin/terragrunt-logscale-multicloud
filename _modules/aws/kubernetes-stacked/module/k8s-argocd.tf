resource "helm_release" "argocd" {
  depends_on = [

    helm_release.cert-manager
  ]
  namespace = "kube-system"

  name       = "descheduler"
  repository = "https://kubernetes-sigs.github.io/descheduler/"
  chart      = "descheduler"
  version    = "0.29.0"

  wait = false

  values = [file("./k8s-argocd-values.yaml")]
}
