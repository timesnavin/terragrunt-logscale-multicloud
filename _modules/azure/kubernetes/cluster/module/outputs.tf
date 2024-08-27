output "kube_admin_config" {
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