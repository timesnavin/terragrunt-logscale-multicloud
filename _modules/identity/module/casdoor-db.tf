
resource "kubectl_manifest" "casdoordb" {
  depends_on = [kubernetes_namespace.identity]
  yaml_body  = <<YAML
kind: "postgresql"
apiVersion: "acid.zalan.do/v1"

metadata:
  name: "identity-db"
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
    casdoor: []
  databases:
    casdoor: casdoor
  
  resources:
    requests:
      cpu: 100m
      memory: 100Mi
    limits:
      cpu: "2"
      memory: 1Gi
YAML
}

resource "time_sleep" "identitydb" {
  depends_on = [
    kubectl_manifest.casdoordb
  ]
  create_duration = "2m"
}


# # resource "helm_release" "keycloak_operator" {

# #   namespace        = kubernetes_namespace.identity.metadata.0.name

# #   name       = "keycloak-operator"
# #   repository = "https://kbumsik.io/keycloak-kubernetes/"
# #   chart      = "keycloak-operator"
# #   version    = "0.0.4"

# #   values = [file("./k8s-keycloak-operator.yaml")]
# # }

# # resource "time_sleep" "keycloak_operator" {
# #   depends_on = [
# #     helm_release.keycloak_operator
# #   ]
# #   destroy_duration = "2m"
# # }


# # resource "kubectl_manifest" "sso" {
# #     yaml_body = <<YAML
# # apiVersion: k8s.keycloak.org/v2alpha1
# # kind: Keycloak
# # metadata:
# #   name: identity
# #   namespace: "${kubernetes_namespace.identity.metadata.0.name}"
# # spec:
# #   instances: 1
# #   db:
# #     vendor: postgres
# #     host: postgres-db
# #     usernameSecret:
# #       name: kk.identity-db.credentials.postgresql.acid.zalan.do
# #       key: username
# #     passwordSecret:
# #       name: kk.identity-db.credentials.postgresql.acid.zalan.do
# #       key: password
# #   # http:
# #     # tlsSecret: austin-me-tls
# #   hostname:
# #     hostname: identity.ref.loglabs.net
# #   unsupported:  
# #     affinity:
# #       nodeAffinity:
# #         requiredDuringSchedulingIgnoredDuringExecution:
# #           nodeSelectorTerms:
# #             - matchExpressions:
# #                 - key: kubernetes.io/os
# #                   operator: In
# #                   values:
# #                     - linux
# #         preferredDuringSchedulingIgnoredDuringExecution:
# #           - weight: 50
# #             preference:
# #               matchExpressions:
# #                 - key: computeClass
# #                   operator: In
# #                   values:
# #                     - general
# #           - weight: 10
# #             preference:
# #               matchExpressions:
# #                 - key: storageClass
# #                   operator: In
# #                   values:
# #                     - network
# # YAML
# # }
