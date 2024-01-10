resource "kubernetes_namespace" "identity" {
  metadata {
    annotations = {
      name = "identity"
    }
    name = "identity"
  }
}

resource "helm_release" "keycloak_operator" {
  
  namespace        = kubernetes_namespace.identity.metadata.0.name
  
  name       = "keycloak-operator"
  repository = "https://kbumsik.io/keycloak-kubernetes/"
  chart      = "keycloak-operator"
  version    = "0.0.4"

  values = [file("./k8s-keycloak-operator.yaml")]
}

resource "time_sleep" "keycloak_operator" {
  depends_on = [
    helm_release.keycloak_operator
  ]
  create_duration = "2m"
}

resource "kubectl_manifest" "identitydb" {
  depends_on = [ time_sleep.keycloak_operator ]
    yaml_body = <<YAML
kind: "postgresql"
apiVersion: "acid.zalan.do/v1"

metadata:
  name: "identity"
  namespace: "${kubernetes_namespace.identity.metadata.0.name}"
  labels:
    team: acid

spec:
  teamId: "acid"
  postgresql:
    version: "15"
  numberOfInstances: 1
  volume:
    size: "10Gi"
  users:
    kk: []
  databases:
    keycloak: kk
  
  resources:
    requests:
      cpu: 100m
      memory: 100Mi
    limits:
      cpu: 500m
      memory: 500Mi
YAML
}

resource "kubectl_manifest" "sso" {
    yaml_body = <<YAML
apiVersion: k8s.keycloak.org/v2alpha1
kind: Keycloak
metadata:
  name: identity
  namespace: "${kubernetes_namespace.identity.metadata.0.name}"
spec:
  instances: 1
  db:
    vendor: postgres
    host: postgres-db
    usernameSecret:
      name: secret/kk.identity.credentials.postgresql.acid.zalan.do
      key: username
    passwordSecret:
      name: secret/kk.identity.credentials.postgresql.acid.zalan.do
      key: password
  # http:
    # tlsSecret: austin-me-tls
  hostname:
    hostname: identity.ref.loglabs.net
YAML
}
