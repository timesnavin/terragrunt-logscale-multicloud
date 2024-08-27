terraform {
  required_version = ">= 1.0"


  required_providers {
    time = {
      source = "hashicorp/time"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.28.1"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}