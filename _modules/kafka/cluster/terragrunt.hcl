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
  source = "${dirname(find_in_parent_folders())}/_modules/kafka/cluster/module/"
}

# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  is_regional = fileexists("${get_terragrunt_dir()}/../kubernetes-region-cluster/terragrunt.hcl")
  tenant      = try(yamldecode(file(find_in_parent_folders("tenant.yaml"))), {})
  namespace   = local.is_regional ? "region-kafka" : "${local.tenant.name}-kafka"
  kafka_name  = local.is_regional ? "regional" : local.tenant.name
}
dependency "kubernetes_base" {
  config_path = local.is_regional ? "${get_terragrunt_dir()}/../kubernetes-region-cluster/terragrunt.hcl" : "${get_terragrunt_dir()}/../../../${local.tenant.platform}/${local.tenant.region}/kubernetes/kubernetes-region-cluster/"
  mock_outputs = {
    cluster_name = "foo"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cluster_name = dependency.kubernetes_base.outputs.cluster_name
  namespace    = local.namespace
  kafka_name   = local.kafka_name
}
