# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.

/*terraform {
  source = "../../../../../../_modules/azure/kubernetes/platform/module/aks-karpenter.tf"
}*/

/*include "root" {
  path = find_in_parent_folders()
}
include "root" {
  path = "${dirname(find_in_parent_folders())}/_providers/terragrunt_az_aks_region.hcl"
}*/

/*
# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "module" {
  path   = "${dirname(find_in_parent_folders())}/_modules/azure/kubernetes/platform/terragrunt.hcl"
  expose = true
}
*/
# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------
include "root" {
  path = find_in_parent_folders()
}
include "root" {
  path = "${dirname(find_in_parent_folders())}/_providers/terragrunt_az_aks_region.hcl"
}

/*terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/azure/kubernetes/cluster/module/"
}*/

include "module" {
  path   = "${dirname(find_in_parent_folders())}/_modules/azure/kubernetes/platform/terragrunt.hcl"
  expose = true
}
dependencies {
  paths = [
    "${get_terragrunt_dir()}/../flux2/"
    ]
}

dependency "cluster" {
  config_path = "../cluster"
}

inputs = {
  provider_az_aks_cluster_name        = dependency.cluster.outputs.cluster_name
  provider_az_aks_resource_group_name = dependency.cluster.outputs.resource_group_name
  provider_az_aks_resource_group_name = dependency.cluster.outputs.resource_group_name
  location            = dependency.cluster.outputs.location
  kubeconfig_path       = dependency.cluster.outputs.kube_admin_config
  instance_profile = ""  # Not applicable for Azure; set to empty or remove
#  azure_subscription_id = var.azure_subscription_id
#  tenant_id           = var.tenant_id  
}