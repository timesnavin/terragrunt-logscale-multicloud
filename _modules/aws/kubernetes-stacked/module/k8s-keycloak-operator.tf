resource "helm_release" "keycloak_operator" {
  namespace        = "keycloak-operator"
  create_namespace = true

  name       = "keycloak-operator"
  repository = "https://kbumsik.io/keycloak-kubernetes/"
  chart      = "keycloak-operator"
  version    = "0.0.4"



  values = [file("./k8s-keycloak-operator.yaml")]
}
