resource "kubectl_manifest" "topolvm" {
  depends_on = [
    helm_release.flux2,
    kubectl_manifest.flux2-repos,
    kubectl_manifest.karpenter,
    time_sleep.karpenter
  ]
  yaml_body = templatefile("./manifests/helm-manifests/eks-aws-csi-topolvm.yaml", {})

}
