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
  platform  = yamldecode(file(find_in_parent_folders("platform.yaml")))
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  global    = yamldecode(file(find_in_parent_folders("global.yaml")))
  tenant    = yamldecode(file(find_in_parent_folders("tenant.yaml")))


}
dependency "bucket" {
  config_path = "${get_terragrunt_dir()}/../../${local.global.provider}/${local.global.region}/bucket/"
}
dependency "kubernetes_cluster" {
  config_path = "${get_terragrunt_dir()}/../../${local.global.provider}/${local.global.region}/kubernetes/kubernetes-base/"
}
dependency "kubernetes_addons" {
  config_path  = "${get_terragrunt_dir()}/../../${local.global.provider}/${local.global.region}/kubernetes/kubernetes-stacked/"
  skip_outputs = true
}

dependency "dns_partition" {
  config_path = "${get_terragrunt_dir()}/../../dns/"
}
dependency "sso" {
  config_path = "${get_terragrunt_dir()}/../logscale-sso/"
}
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  //domain_name_platform = dependency.partition_zone.outputs.zone_name
  oidc_provider_arn = dependency.kubernetes_cluster.outputs.oidc_provider_arn

  iam_role_path          = "${local.platform.aws.iam_role_path_prefix}/${local.partition.name}/${local.global.region}/"
  iam_policy_path        = "${local.platform.aws.iam_policy_path_prefix}/${local.partition.name}/${local.global.region}/"
  iam_policy_name_prefix = "${local.platform.aws.iam_policy_name_prefix}_${local.partition.name}_${local.global.region}_"

  additional_kms_owners = local.platform.aws.kms.additional_key_owners

  namespace = "tenant-${local.tenant.name}"

  logscale_storage_bucket_id = dependency.bucket.outputs.logscale_storage_bucket_id
  logscale_export_bucket_id  = dependency.bucket.outputs.logscale_export_bucket_id
  logscale_archive_bucket_id = dependency.bucket.outputs.logscale_archive_bucket_id

  domain_name = dependency.dns_partition.outputs.zone_name
  host_prefix = "partition"
  tenant      = "logscale"

  saml_url                 = dependency.sso.outputs.url
  saml_signing_certificate = dependency.sso.outputs.signing_certificate
  saml_issuer              = dependency.sso.outputs.issuer
}