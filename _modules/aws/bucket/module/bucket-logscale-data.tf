
module "s3_logscale_data" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.2"

  bucket_prefix = "${var.partition_name}-logscale-data"
  acl           = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = module.log_bucket.s3_bucket_id
    target_prefix = "log/s3/"
  }

  lifecycle_rule = [
    {
      id                                     = "data"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7

    }
  ]
}
