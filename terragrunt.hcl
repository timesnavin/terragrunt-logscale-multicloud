# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


locals {
  backend         = yamldecode(file(find_in_parent_folders("backend.yaml")))
  common        = yamldecode(file(find_in_parent_folders("common.yaml")))
  provider        = yamldecode(file(find_in_parent_folders("provider.yaml")))
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
  disable   = local.provider.type == "aws" || local.provider.type == "eks" ? false : true
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



generate "provider_aws_eks_helm" {
  path      = "provider_aws_eks_helm.tf"
  if_exists = "overwrite_terragrunt"
  disable   = local.provider.type == "eks" ? false : true
  contents  = <<-EOF

    variable "provider_aws_eks_cluster_endpoint" {
      type = string
    }
    variable "provider_aws_eks_cluster_certificate_authority_data" {
      type = string
    }
    variable "provider_aws_eks_cluster_name" {
      type = string
    }
    variable "GITHUB_PAT" {
      type = string
    }
    provider "kubernetes" {
      host                   = var.provider_aws_eks_cluster_endpoint
      cluster_ca_certificate = base64decode(var.provider_aws_eks_cluster_certificate_authority_data)

      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        # This requires the awscli to be installed locally where Terraform is executed
        args = ["eks", "get-token", "--cluster-name", var.provider_aws_eks_cluster_name]
      }
    }    
    provider "helm" {
      kubernetes {
        host                   = var.provider_aws_eks_cluster_endpoint
        cluster_ca_certificate = base64decode(var.provider_aws_eks_cluster_certificate_authority_data)

        exec {
          api_version = "client.authentication.k8s.io/v1beta1"
          command     = "aws"
          # This requires the awscli to be installed locally where Terraform is executed
          args = ["eks", "get-token", "--cluster-name", var.provider_aws_eks_cluster_name]
        }
      }
      registry {
        url = "oci://ghcr.io"
        username = "_PAT_"
        password = var.GITHUB_PAT
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
  provider_aws_tags   = local.common.cloud.tags
  provider_aws_region = local.provider.type == "aws" || local.provider.type == "eks" ? local.provider.aws.region : ""

  provider_aws_eks_cluster_endpoint                   = local.provider.type == "eks" ? dependency.kubernetes.outputs.cluster_endpoint : ""
  provider_aws_eks_cluster_certificate_authority_data = local.provider.type == "eks" ? dependency.kubernetes.outputs.cluster_certificate_authority_data : ""
  provider_aws_eks_cluster_name                       = local.provider.type == "eks" ? dependency.kubernetes.outputs.cluster_name : ""


  provider_google_project     = local.provider.type == "google" ? local.provider.google.project_id : ""
  provider_google_region      = local.provider.type == "google" ? local.provider.google.region : ""
  provider_google_credentials = file(find_in_parent_folders("env0_credential_configuration.json"))
}