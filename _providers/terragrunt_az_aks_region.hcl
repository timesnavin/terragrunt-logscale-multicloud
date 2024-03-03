# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


locals {
  common = yamldecode(file(find_in_parent_folders("common.yaml")))
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  provider = yamldecode(file(find_in_parent_folders("provider.yaml")))
  region = yamldecode(file(find_in_parent_folders("region.yaml")))
}


generate "provider_az" {
  path      = "provider_az.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF

    variable "provider_az_environment" {
      type = string
    }
    variable "provider_az_subscription_id" {
      type = string
    }
    variable "provider_az_tenant_id" {
      type = string
    }

    provider "azurerm" {
      features {}

    }
EOF
}


generate "provider_az_aks_helm" {
  path      = "provider_az_aks_helm.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF

    variable "provider_az_aks_cluster_name" {
      type = string
    }

    variable "provider_az_aks_resource_group_name" {
      type = string
    }

    data "azurerm_kubernetes_cluster" "default" {
      name                = var.provider_az_aks_cluster_name
      resource_group_name = var.provider_az_aks_resource_group_name
    }

    provider "kubernetes" {

      host                   = data.azurerm_kubernetes_cluster.default.kube_admin_config.0.host
      client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_admin_config.0.client_certificate)
      client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_admin_config.0.client_key)
      cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_admin_config.0.cluster_ca_certificate)
    }

    provider "helm" {

      kubernetes {
        host                   = data.azurerm_kubernetes_cluster.default.kube_admin_config.0.host
        client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_admin_config.0.client_certificate)
        client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_admin_config.0.client_key)
        cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_admin_config.0.cluster_ca_certificate)
      }
    }

    provider "kubectl" {
      host                   = data.azurerm_kubernetes_cluster.default.kube_admin_config.0.host
      client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_admin_config.0.client_certificate)
      client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_admin_config.0.client_key)
      cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_admin_config.0.cluster_ca_certificate)
    }
EOF
}

inputs = {
  provider_az_environment     = local.provider.az.environment
  provider_az_subscription_id = local.provider.az.subscription
  provider_az_tenant_id       = local.provider.az.tenant

  provider_az_aks_cluster_name     = "${local.common.name}-${local.partition.name}-${local.provider.az.region}"
  provider_az_aks_resource_group_name =  local.provider.az.resourceGroup
}
