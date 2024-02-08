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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/ses/partition/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  region    = yamldecode(file(find_in_parent_folders("region.yaml")))
}

dependency "parent_zone" {
  config_path = "${get_terragrunt_dir()}/../../../dns/"
  mock_outputs = {
    zone_name = "example.com"
    zone_id   = "A123456789"
  }
}

inputs = {
  partition      = local.partition.name
  domain         = dependency.parent_zone.outputs.zone_name
  domain_zone_id = dependency.parent_zone.outputs.zone_id
  region         = local.region.name

  email_user_name_prefix = "${local.partition.name}-${local.region.name}"
}