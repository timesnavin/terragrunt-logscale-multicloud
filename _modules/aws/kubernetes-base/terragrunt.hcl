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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/kubernetes-base/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  provider = yamldecode(file(find_in_parent_folders("provider.yaml")))
  region   = yamldecode(file(find_in_parent_folders("region.yaml")))
  partition   = yamldecode(file(find_in_parent_folders("partition.yaml")))
  platform   = yamldecode(file(find_in_parent_folders("platform.yaml")))

}

dependency "network" {
  config_path = "${get_terragrunt_dir()}/../../network/"
  mock_outputs = {
    name            = "foo"
    vpc_id          = "vpc-1234568"
    private_subnets = ["subnet-01e7d289a152f755e"]
    intra_subnets   = ["subnet-01e7d289a152f755e"]
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
  cluster_region = local.region.name

  iam_role_path     = "${local.platform.aws.iam_role_path_prefix}/${local.partition.name}/${local.region.name}/"
  iam_policy_path     = "${local.platform.aws.iam_policy_path_prefix}/${local.partition.name}/${local.region.name}/"
  iam_policy_name_prefix = "${local.platform.aws.iam_policy_name_prefix}_${local.partition.name}_${local.region.name}_"
  vpc_id            = dependency.network.outputs.vpc_id
  control_plane_subnet_ids = dependency.network.outputs.intra_subnets
  node_subnet_ids        = dependency.network.outputs.private_subnets
  
  additional_kms_owners     = local.region.kubernetes.kms.additional_key_owners


}