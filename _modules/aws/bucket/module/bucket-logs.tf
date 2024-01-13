

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.2"

  bucket_prefix = "${var.partition_name}-log-bucket"
  force_destroy = true

  control_object_ownership = true

  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_access_log_delivery_policy     = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  access_log_delivery_policy_source_accounts = [data.aws_caller_identity.current.account_id]
  #   access_log_delivery_policy_source_buckets = [
  #     "arn:aws:s3:::${local.bucket_name}"
  #   ]

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id                                     = "logs"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_expiration = {
        days = 14
      }
    }
  ]
}
