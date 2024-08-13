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
  source = "${dirname(find_in_parent_folders())}/_modules/azure/kubernetes/platform/module"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
dependencies {
  paths = [
    "${get_terragrunt_dir()}/../flux2/"
    ]
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------


inputs = {
  kubeconfig_path       = dependency.aks.outputs.kubeconfig
  cluster_name          = dependency.aks.outputs.cluster_name
  instance_profile_name = ""  # Not applicable for Azure; set to empty or remove
}
