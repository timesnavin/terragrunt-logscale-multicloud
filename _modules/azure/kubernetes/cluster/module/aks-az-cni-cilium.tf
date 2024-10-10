
locals {
  # Use the FQDN of the AKS cluster
  k8shost = data.azurerm_kubernetes_cluster.default.fqdn
}

# Helm Release for Cilium on AKS
resource "helm_release" "cilium" {
  depends_on = [
    module.aks
  ]
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  namespace  = "kube-system"
  version    = "1.15.7"

  values = [<<YAML
cni:
  chainingMode: azure  # Change from kubenet to azure for better AKS compatibility
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

# Kubernetes Cluster Data Source
data "azurerm_kubernetes_cluster" "default" {
  name                = module.aks.aks_name
  resource_group_name = var.resourceGroup
}