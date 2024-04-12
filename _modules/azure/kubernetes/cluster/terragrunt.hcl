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
  source = "${dirname(find_in_parent_folders())}/_modules/azure/kubernetes/cluster/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  region   = yamldecode(file(find_in_parent_folders("region.yaml")))
  provider = yamldecode(file(find_in_parent_folders("provider.yaml")))
}


dependency "vnet" {
  config_path = "${get_terragrunt_dir()}/../../vnet/"
}
inputs = {
  name = dependency.vnet.outputs.name
  projectRoot = dirname(find_in_parent_folders())
  resourceGroup         = local.provider.az.resourceGroup
  resourceGroupLocation = local.provider.az.region

  location = local.region.name
  aks_subnet_id = dependency.vnet.outputs.aks_subnet_id
  pods_subnet_id= dependency.vnet.outputs.pods_subnet_id
}
