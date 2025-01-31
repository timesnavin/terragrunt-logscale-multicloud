terraform {
  source = "${dirname(find_in_parent_folders())}/_modules/azure/logscale/module/"
}

locals {
  common    = yamldecode(file(find_in_parent_folders("common.yaml")))
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  tenant    = yamldecode(file(find_in_parent_folders("tenant.yaml")))
  region    = yamldecode(file(find_in_parent_folders("region.yaml")))
  provider  = yamldecode(file(find_in_parent_folders("provider.yaml")))

  # Derived values
  namespace = "${local.tenant.name}-logscale"
}

dependency "kubernetes_cluster" {
  config_path = "${get_terragrunt_dir()}/../../../${local.tenant.platform}/${local.tenant.region}/kubernetes/cluster/"
}

dependency "kafka" {
  config_path = "${get_terragrunt_dir()}/../../../${local.tenant.platform}/${local.tenant.region}/kafka/"
  skip_outputs = true
  
  mock_outputs = {
    namespace = "kafka"
    name     = "kafka"
    prefix   = "000"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan"]
}

inputs = {
  # Basic configuration
  tenant              = local.tenant.name
  resource_group_name = local.provider.az.resourceGroup
  location           = local.provider.az.region
  domain_name        = "${local.tenant.name}.${local.common.name}"  # Adjust this based on your domain structure
  
  # Provider configuration
  provider_az_environment      = local.provider.az.environment
  provider_az_subscription_id  = local.provider.az.subscription
  provider_az_tenant_id       = local.provider.az.tenant
  provider_az_aks_resource_group_name = local.provider.az.resourceGroup
  provider_az_aks_cluster_name = "${local.common.name}-${local.partition.name}-${local.provider.az.region}"
  
  # Azure specific configuration
  subscription_id    = local.provider.az.subscription
  tenant_id         = local.provider.az.tenant
  
  # Cluster configuration
  kubernetes_version = local.region.kubernetes.version
  
  # LogScale configuration
  LogScaleRoot      = local.tenant.logscale.root
  
  # Tags
  tags = merge(
    local.common.cloud.tags,
    local.provider.az.tags,
    {
      Name = local.common.name
      Environment = local.tenant.name
    }
  )

  # Kafka configuration
  kafka_namespace     = try(dependency.kafka.outputs.namespace, "kafka")
  kafka_name         = try(dependency.kafka.outputs.name, "kafka")
  kafka_prefix       = try(dependency.kafka.outputs.prefix, "000")

  # Service Account
  service_account    = "${local.tenant.name}-logscale-sa"

  # These values need to be provided via environment variables or tfvars
  logscale_license   = get_env("TF_VAR_logscale_license", "")
  saml_issuer       = get_env("TF_VAR_saml_issuer", "")
  saml_signing_certificate = get_env("TF_VAR_saml_signing_certificate", "")
  saml_url          = get_env("TF_VAR_saml_url", "")
}