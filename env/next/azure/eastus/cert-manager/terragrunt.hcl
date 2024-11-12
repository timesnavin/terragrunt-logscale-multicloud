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
include "root" {
  path = find_in_parent_folders()
}
include "root" {
  path = "${dirname(find_in_parent_folders())}/_providers/terragrunt_az_aks_region.hcl"
}


# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "module" {
  path   = "${dirname(find_in_parent_folders())}/_modules/azure/cert-manager/terragrunt.hcl"
  expose = true
}

# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------
dependency "cluster" {
  config_path = "../kubernetes/cluster/"  # Reference the env folder where the cluster state is stored
}

inputs = {
  cluster_name        = dependency.cluster.outputs.cluster_name
  resource_group_name = dependency.cluster.outputs.resource_group_name
  location            = dependency.cluster.outputs.location  
  namespace = "cert-manager"
  cert_manager_version = "v1.8.0"
}