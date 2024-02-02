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
  //source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v19.21.0"
  source = "${dirname(find_in_parent_folders())}/_modules/identity/authentik/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  global = yamldecode(file(find_in_parent_folders("global.yaml")))

}

dependency "kubernetes_cluster" {
  config_path  = "${get_terragrunt_dir()}/../../${local.global.provider}/${local.global.region}/kubernetes/kubernetes-region-cluster/"
  skip_outputs = true
}

dependency "partition_zone" {
  config_path = "${get_terragrunt_dir()}/../../dns/"
}
dependency "smtp" {
  config_path  = "${get_terragrunt_dir()}/../../${local.global.provider}/${local.global.region}/ses/"
}
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  domain_name = dependency.partition_zone.outputs.zone_name
  admin_email = "ryan.faircloth@crowdstrike.com"

  smtp_user = dependency.smtp.outputs.smtp_user
  smtp_password= dependency.smtp.outputs.smtp_password
  smtp_server= dependency.smtp.outputs.smtp_server
  from_email = "NoReplyIdentityServices@${dependency.partition_zone.outputs.zone_name}"

}