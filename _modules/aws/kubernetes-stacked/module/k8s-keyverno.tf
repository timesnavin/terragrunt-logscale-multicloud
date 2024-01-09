
resource "helm_release" "keyverno" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter
  ]
  namespace = "keyverno"
  create_namespace = true
  

  name       = "keyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "keyverno"
  version    = "3.0.5"

  wait = false

  values = [file("./k8s-keyverno-values.yaml")]
}



resource "helm_release" "keyverno-policies" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    helm_release.keyverno
  ]
  namespace = "keyverno"
  

  name       = "keyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "keyverno-policies"
  version    = "3.0.4"

  wait = false

  values = [file("./k8s-keyverno-policies-values.yaml")]
}
