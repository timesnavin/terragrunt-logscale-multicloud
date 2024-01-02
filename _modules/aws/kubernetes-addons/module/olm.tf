resource "kubernetes_manifest" "container-test" {
  manifest = yamldecode(file("manifests/olm/crds.yaml"))
}
