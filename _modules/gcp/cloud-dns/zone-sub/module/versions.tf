terraform {
  required_version = ">= 1.0"

  required_providers {
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "5.35.0"
    # }
    google = {
      source = "hashicorp/google"
      version = "5.15.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "5.15.0"
    }
  }
}
