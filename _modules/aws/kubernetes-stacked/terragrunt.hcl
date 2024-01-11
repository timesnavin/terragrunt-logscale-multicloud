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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/kubernetes-stacked/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  provider = yamldecode(file(find_in_parent_folders("provider.yaml")))
  region   = yamldecode(file(find_in_parent_folders("region.yaml")))
  platform   = yamldecode(file(find_in_parent_folders("platform.yaml")))

}
dependency "kubernetes_base" {
  config_path = "${get_terragrunt_dir()}/../kubernetes-base/"
  mock_outputs = {
    cluster_name            = "foo"
  }
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

dependency "zone_partition" {
  config_path = "${get_terragrunt_dir()}/../../../../dns"
  mock_outputs = {
    zone_id            = "Z00236603S1DPYCJOBON1"
  }
}
dependency "zone_provider" {
  config_path = "${get_terragrunt_dir()}/../../../dns"
  mock_outputs = {
    zone_id            = "Z00236603S1DPYCJOBON1"
  }
}
dependency "zone_region" {
  config_path = "${get_terragrunt_dir()}/../../dns"
  mock_outputs = {
    zone_id            = "Z00236603S1DPYCJOBON1"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cluster_name    = dependency.kubernetes_base.outputs.cluster_name
  cluster_version = local.region.kubernetes.version
  cluster_region = local.region.name

  oidc_provider_arn = dependency.kubernetes_base.outputs.oidc_provider_arn
  
  iam_role_path     = "${local.platform.aws.iam_role_path_prefix}}/${local.partition.name}/${local.region.name}/"
  iam_policy_path     = "${local.platform.aws.iam_policy_path_prefix}}/${local.partition.name}/${local.region.name}/"
  iam_policy_name_prefix = "${local.platform.aws.iam_policy_name_prefix}}_${local.partition.name}_${local.region.name}_"

  vpc_id            = dependency.network.outputs.vpc_id
  node_subnet_ids        = dependency.network.outputs.private_subnets
  
  additional_aws_auth_roles = local.region.kubernetes.aws_auth_roles
  system_node_role_arn = dependency.kubernetes_base.outputs.system_node_role_arn

  external_dns_route53_zone_arns = [
    dependency.zone_partition.outputs.zone_arn,
    dependency.zone_provider.outputs.zone_arn,
    dependency.zone_region.outputs.zone_arn
  ]
}