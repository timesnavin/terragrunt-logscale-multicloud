
module "s3_logscale_export" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.0"

  bucket_prefix = "${var.partition_name}-logscale-export"
  acl           = "private"

  control_object_ownership = false
  object_ownership         = "BucketOwnerEnforced"

  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = var.logs_s3_bucket_id
    target_prefix = "S3Logs/"
  }

  lifecycle_rule = [
    {
      id                                     = "export"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 3

      noncurrent_version_expiration = {
        days = 7
      }
    }
  ]

  server_side_encryption_configuration = {
    rule = {
      "apply_server_side_encryption_by_default" = {
        "kms_master_key_id" = ""
        "sse_algorithm" : "AES256"
      }

      bucket_key_enabled = true
    }
  }

}
