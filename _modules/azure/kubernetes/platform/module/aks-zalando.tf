locals {

}
resource "kubectl_manifest" "zalando" {
  yaml_body = templatefile("./manifests/helm-manifests/zalando.yaml", { region = var.location })
}
