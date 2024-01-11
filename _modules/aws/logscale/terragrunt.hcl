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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/logscale/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  provider = yamldecode(file(find_in_parent_folders("provider.yaml")))
  region   = yamldecode(file(find_in_parent_folders("region.yaml")))
  platform   = yamldecode(file(find_in_parent_folders("platform.yaml")))
  partition   = yamldecode(file(find_in_parent_folders("partition.yaml")))
}

dependency "kubernetes_cluster" {
  config_path = "${get_terragrunt_dir()}/../../kubernetes/kubernetes-base/"
  mock_outputs = {
    cluster_name            = "foo"
  }
}
dependency "kubernetes_addons" {
  config_path = "${get_terragrunt_dir()}/../../kubernetes/kubernetes-base/"
  skip_outputs = true
}

// dependency "partition_zone" {
//    config_path = "${get_terragrunt_dir()}/../../../shared/zone/"
// }
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  //domain_name_platform = dependency.partition_zone.outputs.zone_name
  oidc_provider_arn = dependency.kubernetes_cluster.outputs.oidc_provider_arn

  iam_role_path     = "${local.platform.aws.iam_role_path_prefix}/${local.partition.name}/${local.region.name}/"
  iam_policy_path     = "${local.platform.aws.iam_policy_path_prefix}/${local.partition.name}/${local.region.name}/"
  iam_policy_name_prefix = "${local.platform.aws.iam_policy_name_prefix}_${local.partition.name}_${local.region.name}_"

  additional_kms_owners     = local.region.kubernetes.kms.additional_key_owners

  namespace = dependency.kubernetes_cluster.outputs.cluster_name


}