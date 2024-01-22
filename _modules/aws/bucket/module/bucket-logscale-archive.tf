
module "s3_logscale_archive" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.0.1"

  bucket_prefix = "${var.partition_name}-logscale-archive"
  acl           = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = module.log_bucket.s3_bucket_id
    target_prefix = "S3Logs/"
  }

  lifecycle_rule = [
    {
      id                                     = "archive"
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
