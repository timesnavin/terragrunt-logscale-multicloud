# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


locals {
  backend  = yamldecode(file(find_in_parent_folders("backend.yaml")))
  provider = yamldecode(file(find_in_parent_folders("provider.yaml")))
  aws_tags = {
    Owner   = "ryan.faircloth"
    Project = "selfcloud"
  }
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
  disable = local.provider.type == "aws" ? false  : true
  contents  = <<-EOF

    variable "provider_aws_tags" {
      type = map
    }
    provider "aws" {
        region = "${local.provider.aws.region}"
        
        default_tags {
            tags = var.provider_aws_tags
        }
    }
EOF
}

generate "provider_azure" {
  path      = "provider_azure.tf"
  if_exists = "overwrite_terragrunt"
  disable = local.provider.type == "azure" ? false  : true
  contents  = <<-EOF

  provider "azurerm" {
    features {}
 
  }    
  EOF
}

generate "provider_gcp" {
  path      = "provider_gcp.tf"
  if_exists = "overwrite_terragrunt"
  disable = local.provider.type == "google" ? false  : true
  contents  = <<-EOF

  variable "provider_project" {
    type = map
  }
  variable "provider_region" {
    type = map
  }  
  provider "google" {
    project     = var.provider_project
    region = provider_region
  }
  provider "google-beta" {
    project     = var.provider_project
    region = provider_region
  }  
  EOF
}


inputs = {
  provider_aws_tags = local.aws_tags
  provider_project = local.provider.type == "google" ? local.provider.google.project_id : ""
  provider_region = local.provider.type == "google" ? local.provider.google.region : ""
}