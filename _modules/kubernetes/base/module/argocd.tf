resource "kubernetes_namespace" "argocd" {

  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  depends_on = [ kubernetes_namespace.argocd ]
  namespace        = "argocd"
  # create_namespace = true

  name       = "argocd"
  repository = "oci://ghcr.io/argoproj/argo-helm"
  chart      = "argo-cd"
  version    = "5.52.1"

  wait = false

  values = [
    <<-YAML
redis-ha:
  enabled: true

controller:
  replicas: 1

server:
  extraArgs:
  - --insecure
  autoscaling:
    enabled: true
    minReplicas: 2
  ingress:
    enabled: true
    hosts:
      - argocd.${var.domain_name_region}
    annotations:
      alb.ingress.kubernetes.io/scheme: internet-facing
      link.argocd.argoproj.io/external-link: argocd.${var.domain_name_region}
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
      alb.ingress.kubernetes.io/listen-ports:  '[{"HTTP": 80}, {"HTTPS": 443}]'
    ingressClassName: alb

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2

applicationSet:
  replicas: 2    
YAML
  ]
}

