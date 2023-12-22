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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/acm/cert-partition/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  platform = yamldecode(file(find_in_parent_folders("platform.yaml")))
}

dependency "platform_zone" {
   config_path = "${get_terragrunt_dir()}/../../zone"
}


inputs = {
  parent_domain  = dependency.platform_zone.outputs.zone_name
  parent_zone_id = dependency.platform_zone.outputs.zone_id
  child_domain   = local.platform.type
}