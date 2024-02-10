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
  platform = yamldecode(file(find_in_parent_folders("platform.yaml")))
  tenant   = yamldecode(file(find_in_parent_folders("tenant.yaml")))

  kafka_namespace = try(local.tenant.kafka.deployment, "regional") == "regional" ? "region-kafka" : "${local.tenant.name}-kafka"
  kafka_name      = try(local.tenant.kafka.deployment, "regional") == "regional" ? "regional" : local.tenant.name

}
dependency "bucket" {
  config_path = "${get_terragrunt_dir()}/../../../${local.tenant.platform}/${local.tenant.region}/bucket-logscale/"
}
dependency "kubernetes_cluster" {
  config_path = "${get_terragrunt_dir()}/../../../${local.tenant.platform}/${local.tenant.region}/kubernetes/kubernetes-region-cluster/"
}

dependency "dns_partition" {
  config_path = "${get_terragrunt_dir()}/../../../dns/"
}
dependency "sso" {
  config_path = "${get_terragrunt_dir()}/../logscale-sso/"
  mock_outputs = {
    url                 = "https:///example.com"
    signing_certificate = "A123456789"
    issuer              = "temp"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  region = local.tenant.region
  //domain_name_platform = dependency.partition_zone.outputs.zone_name
  oidc_provider_arn = dependency.kubernetes_cluster.outputs.oidc_provider_arn

  additional_kms_owners = local.platform.aws.kms.additional_key_owners


  logscale_storage_bucket_id = dependency.bucket.outputs.logscale_storage_bucket_id
  logscale_export_bucket_id  = dependency.bucket.outputs.logscale_export_bucket_id
  logscale_archive_bucket_id = dependency.bucket.outputs.logscale_archive_bucket_id

  domain_name = dependency.dns_partition.outputs.zone_name

  tenant                   = local.tenant.name
  saml_url                 = dependency.sso.outputs.url
  saml_signing_certificate = dependency.sso.outputs.signing_certificate
  saml_issuer              = dependency.sso.outputs.issuer

  LogScaleRoot    = try(local.tenant.logscale.root, "akaadmin")
  kafka_name      = local.kafka_name
  kafka_namespace = local.kafka_namespace
  kafka_prefix_increment = try(local.tenant.logscale.kafka.prefixIncrement,"0")
}
