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
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {

  resource_group_name = local.resource_group.name

  # Prefix is used to compute a cluster name should a cluster require replacement.
  prefix = "${dependency.resourceGroup.outputs.resource_group_name}-${local.region.region}"


  kubernetes_version        = local.region.kubernetes.version
  automatic_channel_upgrade = local.region.kubernetes.automatic_channel_upgrade

    vnet_subnet_id = "${dependency.network.outputs.vnet_id}/kubernetes"
    pod_subnet_id= "${dependency.network.outputs.vnet_id}/pods"

  # Agents are used by the system this is where cluster privlidged pods will run
  agents_availability_zones    = [1, 2, 3]
  agents_min_count             = local.region.kubernetes.agents_min_count
  agegnts_max_count            = local.region.kubernetes.agents_max_count
  agents_size                  = local.region.kubernetes.agents_size
  only_critical_addons_enabled = local.region.kubernetes.only_critical_addons_enabled


  
  auto_scaler_profile_enabled  = local.region.kubernetes.auto_scaler_profile_enabled
  auto_scaler_profile_expander = local.region.kubernetes.auto_scaler_profile_expander

  tags = local.provider.azure.tags

}