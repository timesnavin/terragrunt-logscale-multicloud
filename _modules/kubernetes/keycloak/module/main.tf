resource "helm_release" "keycloak_operator" {
  namespace        = "keycloak-operator"
  create_namespace = true

  name       = "keycloak-operator"
  repository = "https://kbumsik.io/keycloak-kubernetes/"
  chart      = "keycloak-operator"
  version    = "0.0.4"



  values = [
    <<-EOT
replicaCount: 1    
    EOT
  ]
}

# resource "helm_release" "argocd" {
#   namespace        = "argocd"
#   create_namespace = true

#   name       = "argocd"
#   repository = "oci://ghcr.io/argoproj/argo-helm"
#   chart      = "argo-cd"
#   version    = "5.51.6"

#   wait = false

#   values = [
#     <<-EOT
# redis-ha:
#   enabled: true

# controller:
#   replicas: 1

# server:
#   extraArgs:
#   - --insecure
#   autoscaling:
#     enabled: true
#     minReplicas: 2
#   ingress:
#     enabled: true
#     hosts:
#       - argocd.${var.domain_name_region}
#     # tls:
#     #   - hosts:
#     #     - argocd.${var.domain_name_region}
#     annotations:
#       alb.ingress.kubernetes.io/scheme: internet-facing
#       link.argocd.argoproj.io/external-link: argocd.${var.domain_name_region}
#       alb.ingress.kubernetes.io/target-type: ip
#       alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
#       alb.ingress.kubernetes.io/listen-ports:  '[{"HTTP": 80}, {"HTTPS": 443}]'
#     ingressClassName: alb

# repoServer:
#   autoscaling:
#     enabled: true
#     minReplicas: 2

# applicationSet:
#   replicas: 2    
#     EOT
#   ]
# }

