
resource "helm_release" "kyverno" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter
  ]
  namespace        = "kyverno"
  create_namespace = true


  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  version    = "3.1.3"

  wait = false

  values = [file("./k8s-kyverno-values.yaml")]
}



resource "helm_release" "kyverno-policies" {
  depends_on = [
    time_sleep.karpenter_nodes,
    helm_release.karpenter,
    helm_release.kyverno
  ]
  namespace = "kyverno"


  name       = "kyverno-policies"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno-policies"
  version    = "3.1.3"

  wait = false

  values = [file("./k8s-kyverno-policies-values.yaml")]
}


data "kubectl_path_documents" "kyverno-policies" {
  pattern = "./manifests/kyverno-policies/*.yaml"
}

resource "kubectl_manifest" "kyverno-policies" {
  depends_on = [helm_release.kyverno]
  count      = length(data.kubectl_path_documents.kyverno-policies.documents)
  yaml_body  = element(data.kubectl_path_documents.kyverno-policies.documents, count.index)
}