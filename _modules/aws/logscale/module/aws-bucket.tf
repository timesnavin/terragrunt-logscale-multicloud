module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.1"

  # aliases               = ["eks/${var.cluster_name}-ck"]
#   description           = "bucket encryption key"
  enable_default_policy = true
  key_owners = concat(
    ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"],
    var.additional_kms_owners
  )
}



module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.2"

  attach_deny_insecure_transport_policy = true
  bucket_prefix                         = var.namespace

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = var.force_destroy
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.kms.key_arn
        sse_algorithm     = "aws:kms"
      }
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
      id      = "default"
      enabled = true
      # filter = {
      #   prefix = "globalsnapshots/"
      # }
      abort_incomplete_multipart_upload_days = 2
      noncurrent_version_expiration = {
        days = 7
      }
      expiration = {
        days                         = 36500
        # expired_object_delete_marker = true
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
        # expired_object_delete_marker = true
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
        # expired_object_delete_marker = true
      }

    },

  ]
  attach_policy = true

}
