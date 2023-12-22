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
  autoscaling:
    enabled: true
    minReplicas: 2
  ingress:
    enabled: true
    hosts:
      - argocd.${var.region}.${var.domain_name}
    annotations:
      alb.ingress.kubernetes.io/scheme: internet-facing
      link.argocd.argoproj.io/external-link: argocd.${var.region}.${var.domain_name}
      alb.ingress.kubernetes.io/target-type: ip
    ingressClassName: alb

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2

applicationSet:
  replicas: 2    
    EOT
  ]
}

