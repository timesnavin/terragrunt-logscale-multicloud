/*output "kube_admin_config" {
  #value = module.aks.kube_admin_config_raw
  #value = data.azurerm_kubernetes_cluster.cluster.kube_admin_config_raw
  value = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host
  sensitive = true
}

output "location" {
  value = data.azurerm_kubernetes_cluster.cluster.location
}

#########

output "cluster_name" {
  value = data.azurerm_kubernetes_cluster.cluster.name
}

output "resource_group_name" {
  value = data.azurerm_kubernetes_cluster.cluster.resource_group_name
}

output "kubeconfig_path" {
  value = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host
  sensitive = true
}*/
##########################
output "kube_admin_config" {
  #value = module.aks.kube_admin_config_raw
  #value = data.azurerm_kubernetes_cluster.cluster.kube_admin_config_raw
  value = data.azurerm_kubernetes_cluster.cluster.kube_config
  sensitive = true
}

output "location" {
  value = data.azurerm_kubernetes_cluster.cluster.location
}

#########

output "cluster_name" {
  value = data.azurerm_kubernetes_cluster.cluster.name
}

output "resource_group_name" {
  value = data.azurerm_kubernetes_cluster.cluster.resource_group_name
}

output "kubeconfig_path" {
  value = data.azurerm_kubernetes_cluster.cluster.kube_config_raw
  sensitive = true
}

output "karpenter_service_account_name" {
  value = kubernetes_service_account.karpenter.metadata[0].name
  description = "The name of the Karpenter service account in the cluster."
}

output "karpenter_namespace_name" {
  value = kubernetes_namespace.karpenter.metadata[0].name
  description = "The name of the Karpenter namespace in the cluster."
}

output "vnet_subnet_id" {
  value = var.aks_subnet_id
  description = "AKS Subnet id"
  }