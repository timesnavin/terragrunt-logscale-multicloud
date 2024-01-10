
data "kubernetes_secret" "casdoor" {
  depends_on = [time_sleep.identitydb]
  metadata {
    name      = "casdoor.identity-db.credentials.postgresql.acid.zalan.do"
    namespace = kubernetes_namespace.identity.metadata.0.name
  }
}
resource "helm_release" "casdoor" {

  namespace = kubernetes_namespace.identity.metadata.0.name

  name       = "identity"
  repository = "oci://registry-1.docker.io/casbin"
  chart      = "casdoor-helm-charts"
  version    = "0.4.2"

  values = [
    templatefile("./k8s-casdoor.yaml",
      {
        dbpass = data.kubernetes_secret.casdoor.data.password
      }
  )]
}
