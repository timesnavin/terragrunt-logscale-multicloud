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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/vpc/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  common = yamldecode(file(find_in_parent_folders("common.yaml")))
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  region    = yamldecode(file(find_in_parent_folders("region.yaml")))

}

dependency "azs" {
  config_path = "${get_terragrunt_dir()}/../azs/"
}
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  name = "${local.common.name}-${local.partition.name}"

  azs                          = dependency.azs.outputs.az_names
  cidr                         = dependency.azs.outputs.cidr
  private_subnets              = dependency.azs.outputs.private_subnets
  public_subnets               = dependency.azs.outputs.public_subnets
  public_subnet_ipv6_prefixes  = dependency.azs.outputs.public_subnet_ipv6_prefixes
  private_subnet_ipv6_prefixes = dependency.azs.outputs.private_subnet_ipv6_prefixes


}
