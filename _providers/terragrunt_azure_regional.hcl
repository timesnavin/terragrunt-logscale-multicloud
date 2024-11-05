# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


locals {
  common = yamldecode(file(find_in_parent_folders("common.yaml")))
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  provider = yamldecode(file(find_in_parent_folders("provider.yaml")))
  region = yamldecode(file(find_in_parent_folders("region.yaml")))
}

generate "provider_az" {
  path      = "provider_az.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF



EOF
}



inputs = {
  provider_az_environment     = local.provider.az.environment
  provider_az_subscription_id = local.provider.az.subscription
  provider_az_tenant_id       = local.provider.az.tenant
  provider_az_region          = local.region.name
  provider_az_aks_cluster_name     = "${local.common.name}-${local.partition.name}-${local.provider.az.region}"
  provider_az_aks_resource_group_name =  local.provider.az.resourceGroup
}