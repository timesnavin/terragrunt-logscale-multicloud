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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/kubernetes-cluster/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  provider = yamldecode(file(find_in_parent_folders("provider.yaml")))
  region   = yamldecode(file(find_in_parent_folders("region.yaml")))

}

dependency "network" {
  config_path = "${get_terragrunt_dir()}/../network/"
  mock_outputs = {
    name              = "foo"
    vpc_id            = "vpc-1234568"
    subnet_ids        = []
    control_plane_ids = []
  }

}
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cluster_name    = dependency.network.outputs.name
  cluster_version = local.region.kubernetes.version

  iam_role_path     = local.provider.aws.iam_path
  vpc_id            = dependency.network.outputs.vpc_id
  subnet_ids        = dependency.network.outputs.private_subnets
  control_plane_ids = dependency.network.outputs.intra_subnets

  additional_aws_auth_roles = local.region.kubernetes.aws_auth_roles
  additional_kms_owners     = local.region.kubernetes.kms.additional_key_owners
}