resource "random_id" "prefix" {
  byte_length = 8
}

locals {
  nodes = {
    for i in range(3) : "worker${i}" => {
      name           = substr("worker${i}${random_id.prefix.hex}", 0, 8)
      vm_size        = "Standard_D2s_v3"
      node_count     = 1
      vnet_subnet_id = var.subnet_id
    }
  }
}

module "aks" {
  source = "git::https://github.com/logscale-contrib/terraform-azurerm-aks.git?ref=future"
  # version = "7.5.0"

  resource_group_name = var.resourceGroup
  prefix              = "logscale-${var.location}"

  sku_tier = "Standard"

  rbac_aad                          = true
  rbac_aad_managed                  = true
  role_based_access_control_enabled = true

  network_plugin  = "azure"
  ebpf_data_plane = "cillium"

  net_profile_service_cidr   = "10.254.0.0/16"
  net_profile_dns_service_ip = "10.254.0.2"

  vnet_subnet_id = var.subnet_id

  node_pools      = local.nodes
  os_disk_size_gb = 60

}
