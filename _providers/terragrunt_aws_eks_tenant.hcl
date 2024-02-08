# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


locals {
  common    = yamldecode(file(find_in_parent_folders("common.yaml")))
  partition = yamldecode(file(find_in_parent_folders("partition.yaml")))
  tenant    = yamldecode(file(find_in_parent_folders("tenant.yaml")))
}

generate "provider_aws" {
  path      = "provider_aws.tf"
  if_exists = "overwrite_terragrunt"
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
  contents  = <<-EOF
  
    variable "provider_aws_eks_cluster_name" {
      type = string
    }

  data "aws_eks_cluster" "this" {
    name = var.provider_aws_eks_cluster_name
  }
  provider "kubernetes" {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.this.name]
    }
  }


  provider "kubectl" {
    load_config_file       = false
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.this.name]
    }
  }
EOF
}

inputs = {
  provider_aws_tags             = local.common.cloud.tags
  provider_aws_region           = local.tenant.region
  provider_aws_eks_cluster_name = "${local.partition.name}-${local.tenant.region}"
}