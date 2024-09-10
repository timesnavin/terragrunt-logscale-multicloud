# data "kubernetes_endpoints_v1" "api_endpoints" {
#   metadata {
#     name      = "kubernetes"
#     namespace = "default"
#   }
# }

locals {
  #k8shost = regex("https://(.*)", module.aks.cluster_endpoint)[0]
  #k8shost=flatten(data.kubernetes_endpoints_v1.api_endpoints.subset[*].address[*].ip)[0]
  #k8shost = regex("https://(.*)", tostring(data.azurerm_kubernetes_cluster.cluster.fqdn))
  k8shost = data.azurerm_kubernetes_cluster.cluster.fqdn
}
resource "helm_release" "cilium" {
  depends_on = [
    module.aks.aks_managed_node_groups,
    module.aks.access_entries,
    module.aks.access_policy_associations,
    module.aks.cloudwatch_log_group_arn
  ]
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  name       = "cilium"
  namespace  = "kube-system"
  version    = "1.15.7"
  values = [<<YAML
cni:
  chainingMode: aws-cni
  exclusive: false
routingMode: native
enableIPv4Masquerade: false
enableIPv6Masquerade: false
endpointRoutes:
  enabled: true
ipv6:
  enabled: true
kubeProxyReplacement: true
loadBalancer:
  # acceleration: native
  mode: dsr
k8sServicePort: 443
k8sServiceHost: ${local.k8shost}
operator:
  podDisruptionBudget:
    enabled: true
hubble:
  relay:
    enabled: true
  ui:
    enabled: true
nodeinit:

  enabled: true
  startup:
    preScript: |
      #
        ip link set dev eth0 mtu 3498
        ip link show eth0
        ethtool -l eth0
        x=$(( $(ethtool -l eth0 | grep Combined | head -1 | sed 's|Combined:\s*||g') /2))
        echo ethtool -L eth0 combined $x
        ethtool -L eth0 combined 2 || true
      #
YAML
  ]
}
