resource "random_id" "prefix" {
  byte_length = 8
}

locals {

}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "8.0.0"

  resource_group_name = var.resourceGroup
  cluster_name        = var.name
  prefix              = var.name
  kubernetes_version  = "1.29"
  sku_tier            = "Standard"

  log_analytics_workspace_enabled   = false
  rbac_aad                          = true
  rbac_aad_managed                  = true
  rbac_aad_azure_rbac_enabled       = true
  role_based_access_control_enabled = true

  network_plugin  = "azure"
  ebpf_data_plane = "cilium"

  net_profile_service_cidr   = "10.254.0.0/16"
  net_profile_dns_service_ip = "10.254.0.2"

  vnet_subnet_id = var.aks_subnet_id
  pod_subnet_id  = var.pods_subnet_id

  agents_availability_zones = ["1", "2", "3"]
  automatic_channel_upgrade = "patch"

  agents_count                = 1
  agents_max_count            = 3
  agents_max_pods             = 100
  agents_min_count            = 1
  agents_pool_name            = "system"
  agents_pool_max_surge       = "100%"
  temporary_name_for_rotation = "systemtmp"
  # enable_host_encryption      = true
  node_pools = {
    system = {
      name                = "system2"
      availability_zones  = ["1", "2", "3"]
      enable_auto_scaling = true
      vm_size             = "Standard_D2s_v3"
      node_count          = null
      min_count           = 0
      max_count           = 3
      max_pods            = 100
      vnet_subnet_id      = var.aks_subnet_id
      pod_subnet_id       = var.pods_subnet_id
      node_taints = [
        "CriticalAddonsOnly=true:PreferNoSchedule"
      ]
      # enable_host_encryption = true

    }
  }
  os_disk_size_gb = 60

}