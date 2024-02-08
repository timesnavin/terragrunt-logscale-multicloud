# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


locals {
  common = yamldecode(file(find_in_parent_folders("common.yaml")))
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  region = yamldecode(file(find_in_parent_folders("region.yaml")))
}


generate "provider_gcp" {
  path      = "provider_gcp.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF

    variable "provider_gcp_labels" {
      type = map(any)
    }
    variable "provider_gcp_project" {
      type = string
    }
    variable "provider_gcp_region" {
      type = string
    }
    provider "google" {        
        default_labels = var.provider_gcp_labels
        project = var.provider_gcp_project
        region = var.provider_gcp_region
    }
    provider "google-beta" {        
        //default_labels = var.provider_gcp_labels
        project = var.provider_gcp_project
        region = var.provider_gcp_region
    }
    
EOF
}



inputs = {
  provider_gcp_labels   = local.common.cloud.tags
  provider_gcp_region = local.region.name
  provider_gcp_project = local.partition.gcp.project_id
}