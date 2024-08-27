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
locals {
  region   = yamldecode(file(find_in_parent_folders("region.yaml")))
  provider = yamldecode(file(find_in_parent_folders("provider.yaml")))
}

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
/*dependency "aks" {
  config_path = "/Users/nchaudhary/Dev/terragrunt-logscale-multicloud/_modules/azure/kubernetes/cluster"
}

inputs = {
  
  cluster_name        = dependency.aks.outputs.cluster_name
  resource_group_name = dependency.aks.outputs.resource_group_name
  location            = dependency.aks.outputs.location
  azure_subscription_id = var.azure_subscription_id
  azure_tenant_id     = var.azure_tenant_id
  azure_client_id     = var.azure_client_id
  azure_client_secret = var.azure_client_secret

  name = dependency.vnet.outputs.name
  projectRoot = dirname(find_in_parent_folders())
  resourceGroup         = local.provider.az.resourceGroup
  resourceGroupLocation = local.provider.az.region

  location = local.region.name
  aks_subnet_id = dependency.vnet.outputs.aks_subnet_id
  pods_subnet_id= dependency.vnet.outputs.pods_subnet_id 
}*/