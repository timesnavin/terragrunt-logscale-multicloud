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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/bucket-replication/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  partition  = yamldecode(file(find_in_parent_folders("partition.yaml")))
  blue_green = yamldecode(file("${path_relative_to_include()}/blue_green.yaml"))

}

dependency "bucket-blue" {
  config_path = "${get_terragrunt_dir()}/../../${local.blue_green.blue.name}/bucket-logscale"
}
dependency "bucket-green" {
  config_path = "${get_terragrunt_dir()}/../../${local.blue_green.green.name}/bucket-logscale"
}


inputs = {
  bucket_id_blue  = dependency.bucket-blue.outputs.logscale_storage_bucket_id
  bucket_id_green = dependency.bucket-green.outputs.logscale_storage_bucket_id

  bucket_arn_blue  = dependency.bucket-blue.outputs.logscale_storage_bucket_arn
  bucket_arn_green = dependency.bucket-green.outputs.logscale_storage_bucket_arn

  replication_role_name_prefix = "${local.partition.name}-${local.blue_green.blue.name}-${local.blue_green.green.name}"
}