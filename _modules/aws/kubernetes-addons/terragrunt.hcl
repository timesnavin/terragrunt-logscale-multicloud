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
  source = "${dirname(find_in_parent_folders())}/_modules/aws/kubernetes-addons/module/"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {

}

dependency "network" {
  config_path = "${get_terragrunt_dir()}/../network/"
}
dependency "kubernetes_cluster" {
  config_path = "${get_terragrunt_dir()}/../kubernetes-cluster/"
  mock_outputs = {
    cluster_name                       = "foo"
    cluster_endpoint                   = "https:/foo"
    cluster_certificate_authority_data = ""
    cluster_oidc_provider_arn          = "arn::foo"
    karpenter_irsa_arn                 = "arn://"
    karpenter_queue_name               = "sqs://q"
    karpenter_role_name                = "role"
  }
}

dependency "partition_zone" {
   config_path = "${get_terragrunt_dir()}/../../../../shared/zone/"
     mock_outputs = {
      zone_name = "example.com"
  }
}
dependency "region_zone" {
   config_path = "${get_terragrunt_dir()}/../zone/"
     mock_outputs = {
      zone_name = "example.com"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  eks_cluster_name                       = dependency.kubernetes_cluster.outputs.cluster_name
  eks_cluster_endpoint                   = dependency.kubernetes_cluster.outputs.cluster_endpoint
  eks_cluster_certificate_authority_data = dependency.kubernetes_cluster.outputs.cluster_certificate_authority_data
  eks_cluster_oidc_provider_arn          = dependency.kubernetes_cluster.outputs.cluster_oidc_provider_arn

  karpenter_irsa_arn   = dependency.kubernetes_cluster.outputs.karpenter_irsa_arn
  karpenter_queue_name = dependency.kubernetes_cluster.outputs.karpenter_queue_name
  karpenter_role_name  = dependency.kubernetes_cluster.outputs.karpenter_role_name

  domain_name_region = dependency.region_zone.outputs.zone_name

}