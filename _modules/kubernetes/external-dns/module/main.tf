resource "helm_release" "argocd" {
  namespace        = "argocd"
  create_namespace = true

  name       = "argocd"
  repository = "oci://ghcr.io/argoproj/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  wait = false

  values = [
    <<-EOT
redis-ha:
  enabled: true

controller:
  replicas: 1

server:
  ingress:
    enabled: true
    # hosts:
    #   - host: argocd.example.com
    #     paths: ["/"]
    # tls:
    #   - hosts:
    #       - argocd.example.com
    #     secretName: argocd-tls
  autoscaling:
    enabled: true
    minReplicas: 2

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2

applicationSet:
  replicas: 2    
    EOT
  ]
}

