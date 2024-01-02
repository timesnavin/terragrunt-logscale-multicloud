terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
      
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.7.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
