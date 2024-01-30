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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/kubernetes-region-cluster/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {

  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  platform  = yamldecode(file(find_in_parent_folders("platform.yaml")))
  region    = yamldecode(file(find_in_parent_folders("region.yaml")))

}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../../vpc/"
}
dependency "bucket" {
  config_path = "${get_terragrunt_dir()}/../../bucket-logs/"

}
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  name    = dependency.vpc.outputs.name
  vpc_id  = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.private_subnets

  cluster_version = "1.28"

  kms_key_administrators = local.platform.aws.kms.additional_key_owners
  additional_aws_auth_roles = local.region.kubernetes.aws_auth_roles
  
  log_s3_bucket_id = dependency.bucket.outputs.log_s3_bucket_id
}