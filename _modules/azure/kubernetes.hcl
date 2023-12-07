# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.

terraform {
  source = "tfr:///Azure/aks/azurerm?version=7.5.0"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  provider = yamldecode(file(find_in_parent_folders("provider.yaml")))
  region   = yamldecode(file(find_in_parent_folders("region.yaml")))

}

dependency "resourceGroup" {
  config_path = "${get_terragrunt_dir()}/../../../resourcegroup/"
}
dependency "network" {
  config_path = "${get_terragrunt_dir()}/../network/"
  mock_outputs = {
    vnet_id = "fake-vpc-id"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {

  resource_group_name = dependency.resourceGroup.outputs.resource_group_name
  location            = local.region.region

  # Prefix is used to compute a cluster name should a cluster require replacement.
  prefix = "${dependency.resourceGroup.outputs.resource_group_name}-${local.region.region}"

  sku_tier                        = local.region.kubernetes.sku_tier
  kubernetes_version              = local.region.kubernetes.version
  automatic_channel_upgrade       = local.region.kubernetes.automatic_channel_upgrade
  log_analytics_workspace_enabled = false
  image_cleaner_enabled           = true

  role_based_access_control_enabled = true
  rbac_aad_managed                  = true
  rbac_aad                          = true
  rbac_aad_azure_rbac_enabled       = true
  local_account_disabled            = true
  workload_identity_enabled         = true
  oidc_issuer_enabled               = true

  identity_ids = null

  vnet_subnet_id             = "${dependency.network.outputs.vnet_id}/subnets/kubernetes"
  network_plugin             = "azure"
  pod_subnet_id              = "${dependency.network.outputs.vnet_id}/subnets/pods"
  net_profile_service_cidr   = "172.16.0.0/16"
  net_profile_dns_service_ip = "172.16.0.2"
  network_policy             = "azure"

  # Left for postarity this is buggy in the API instead we need a userdeffined identity and need to pre delegate
  network_contributor_role_assigned_subnet_ids = {
    pods = "${dependency.network.outputs.vnet_id}/subnets/pods"
  }

  ingress_application_gateway_enabled   = local.region.kubernetes.application_gateway.enabled
  ingress_application_gateway_subnet_id = local.region.kubernetes.application_gateway.enabled == true ? "${dependency.network.outputs.vnet_id}/subnets/gateway" : null
  ingress_application_gateway_subnet_id = local.region.kubernetes.application_gateway.enabled == true ? "${dependency.network.outputs.vnet_id}/subnets/gateway" : null

  # Agents are used by the system this is where cluster privlidged pods will run
  agents_pool_name             = "system"
  agents_availability_zones    = [1, 2, 3]
  agents_min_count             = local.region.kubernetes.agents.min_count
  agents_max_count             = local.region.kubernetes.agents.max_count
  agents_size                  = local.region.kubernetes.agents.size
  only_critical_addons_enabled = local.region.kubernetes.agents.only_critical_addons_enabled
  os_disk_type                 = "Ephemeral"
  temporary_name_for_rotation  = "tempagents"

  // node_pools = local.region.kubernetes.node_pools
  node_pools = {
    for key, value in local.region.kubernetes.node_pools :
    key => merge(value, {
      vnet_subnet_id = "${dependency.network.outputs.vnet_id}/subnets/kubernetes",
      pod_subnet_id  = "${dependency.network.outputs.vnet_id}/subnets/pods"
      tags = local.provider.azure.tags
    })
  }

  enable_auto_scaling          = true
  auto_scaler_profile_enabled  = local.region.kubernetes.auto_scaler_profile_enabled
  auto_scaler_profile_expander = local.region.kubernetes.auto_scaler_profile_expander

  tags = local.provider.azure.tags

}