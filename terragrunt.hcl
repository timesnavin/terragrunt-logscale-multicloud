# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


locals {
  backend         = yamldecode(file(find_in_parent_folders("backend.yaml")))
  provider        = yamldecode(file(find_in_parent_folders("provider.yaml")))
  metadata_common = yamldecode(file(find_in_parent_folders("metadata_common.yaml")))

}

remote_state {
  backend = "${local.backend.type}"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.backend.bucket}"
    key            = "${local.backend.keyprefix}${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.backend.region}"
    encrypt        = true
    dynamodb_table = "${local.backend.table}"
  }
}


generate "provider_aws" {
  path      = "provider_aws.tf"
  if_exists = "overwrite_terragrunt"
  disable   = local.provider.type == "aws" ? false : true
  contents  = <<-EOF

    variable "provider_aws_tags" {
      type = map
    }
    variable "provider_aws_region" {
      type = string
    }    
    provider "aws" {
        region = var.provider_aws_region
        
        default_tags {
            tags = var.provider_aws_tags
        }
    }
EOF
}

generate "provider_azure" {
  path      = "provider_azure.tf"
  if_exists = "overwrite_terragrunt"
  disable   = local.provider.type == "azure" ? false : true
  contents  = <<-EOF

  provider "azurerm" {
    features {}
 
  }    
  EOF
}

generate "provider_gcp" {
  path      = "provider_gcp.tf"
  if_exists = "overwrite_terragrunt"
  disable   = local.provider.type == "google" ? false : true
  contents  = <<-EOF

  variable "provider_google_project" {
    type = string
  }
  variable "provider_google_region" {
    type = string
  }
  variable "provider_google_credentials" {
    type = string
  }  
  provider "google" {
    credentials = var.provider_google_credentials
    project     = var.provider_google_project
    region = var.provider_google_region
  }
  provider "google-beta" {
    credentials = var.provider_google_credentials
    project     = var.provider_google_project
    region = var.provider_google_region
  }  
  EOF
}


inputs = {
  provider_aws_tags   = local.metadata_common.tags
  provider_aws_region = local.provider.type == "aws" ? local.provider.aws.region : ""

  provider_google_project     = local.provider.type == "google" ? local.provider.google.project_id : ""
  provider_google_region      = local.provider.type == "google" ? local.provider.google.region : ""
  provider_google_credentials = file(find_in_parent_folders("env0_credential_configuration.json"))
}