# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.
terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws?version=3.15.1"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {

}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  bucket_prefix        = "cs-ls-ps-prod-ops"
  attach_public_policy = false

  attach_deny_insecure_transport_policy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = false

  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = true
    }
  }
  versioning = {
    status = true
  }
  intelligent_tiering = {
    logscale = {
      status = "Enabled"
      filter = {
        prefix = "/"
      }
      tiering = {
        ARCHIVE_ACCESS = {
          days = 90
        }
        DEEP_ARCHIVE_ACCESS = {
          days = 180
        }
      }
    }
  }

  lifecycle_rule = [
    {
      id                                     = "default"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 2
      noncurrent_version_expiration = {
        days = 7
      }
      expiration = {
        days                         = 36500
        expired_object_delete_marker = true
      }

    },
    {
      id      = "globalsnapshots"
      enabled = true
      filter = {
        prefix = "globalsnapshots/"
      }
      abort_incomplete_multipart_upload_days = 2
      noncurrent_version_expiration = {
        days = 1
      }
      expiration = {
        days                         = 3
        expired_object_delete_marker = true
      }

    },
    {
      id      = "tmp"
      enabled = true
      filter = {
        prefix = "tmp/"
      }
      abort_incomplete_multipart_upload_days = 2
      noncurrent_version_expiration = {
        days = 1
      }
      expiration = {
        days                         = 3
        expired_object_delete_marker = true
      }

    },

  ] 
  attach_policy = true

  tags = {
    Owner   = "ryan.faircloth"
    Project = "selfcloud"
  }
}