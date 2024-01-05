resource "kubernetes_namespace" "argocd-operator" {

  metadata {
    annotations = {
      name = "argocd-operator"
    }
    name = "argocd-operator"
  }
}
resource "kubernetes_namespace" "argocd" {

  metadata {
    annotations = {
      name = "argocd"
    }
    name = "argocd"
  }
}

# resource "kubectl_manifest" "olm_sub_argocd" {
#     depends_on = [ kubernetes_namespace.argocd ]
#   yaml_body = <<-YAML
# apiVersion: operators.coreos.com/v1alpha1
# kind: Subscription
# metadata:
#   name: argocd-operator
#   namespace: argocd
# spec:
#   channel: alpha
#   name: argocd-operator
#   source: argocd-catalog
#   sourceNamespace: olm
# YAML

# }

# resource "kubectl_manifest" "olm_cat_argocd" {
#   yaml_body = <<-YAML
# apiVersion: operators.coreos.com/v1alpha1
# kind: CatalogSource
# metadata:
#   name: argocd-catalog
#   namespace: olm
# spec:
#   sourceType: grpc
#   image: quay.io/argoprojlabs/argocd-operator-registry@sha256:dcf6d07ed5c8b840fb4a6e9019eacd88cd0913bc3c8caa104d3414a2e9972002 # replace with your index image
#   displayName: Argo CD Operators
#   publisher: Argo CD Community
# YAML
# }

# resource "kubectl_manifest" "olm_group_argocd" {
#   depends_on = [kubernetes_namespace.argocd]
#   yaml_body  = <<-YAML
# apiVersion: operators.coreos.com/v1
# kind: OperatorGroup
# metadata:
#   name: argocd-operator
#   namespace: argocd
# spec:
#   targetNamespaces:
#   - argocd
# YAML
# }


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

