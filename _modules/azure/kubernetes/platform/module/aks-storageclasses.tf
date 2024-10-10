resource "kubectl_manifest" "storageclasses" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter,
    time_sleep.karpenter,
    kubectl_manifest.ebs,
    kubectl_manifest.efs
  ]
  yaml_body = templatefile("./manifests/helm-manifests/aks-storage.yaml", {})
}
