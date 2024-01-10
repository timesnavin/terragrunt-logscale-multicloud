resource "kubernetes_namespace" "sso" {
  metadata {
    annotations = {
      name = "sso"
    }
    name = "sso"
  }
}

resource "kubectl_manifest" "ssodb" {
    yaml_body = <<YAML
kind: "postgresql"
apiVersion: "acid.zalan.do/v1"

metadata:
  name: "db"
  namespace: "${kubernetes_namespace.sso.metadata.0.name}"
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

resource "kubectl_manifest" "ssodb" {
    yaml_body = <<YAML
apiVersion: k8s.keycloak.org/v2alpha1
kind: Keycloak
metadata:
  name: example-kc
  namespace: "${kubernetes_namespace.sso.metadata.0.name}"
spec:
  instances: 1
  db:
    vendor: postgres
    host: postgres-db
    usernameSecret:
      name: secret/kk.db.credentials.postgresql.acid.zalan.do
      key: username
    passwordSecret:
      name: secret/kk.db.credentials.postgresql.acid.zalan.do
      key: password
  # http:
    # tlsSecret: austin-me-tls
  hostname:
    hostname: identity.ref.loglabs.net
YAML
}
