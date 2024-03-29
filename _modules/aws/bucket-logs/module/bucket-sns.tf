module "AWSLogs" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 3.0"

  name_prefix = "${var.partition_name}-log-bucket-AWSLogs"
}
module "S3Logs" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 3.0"

  name_prefix = "${var.partition_name}-log-bucket-S3Logs"
}
module "all_notifications" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "4.1.1"

  bucket = module.log_bucket.s3_bucket_id

  eventbridge = true

  sns_notifications = {
    AWSLogs = {
      topic_arn     = module.AWSLogs.sns_topic_arn
      events        = ["s3:ObjectCreated:Put"]
      filter_prefix = "AWSLogs/"
    }
    S3Logs = {
      topic_arn     = module.S3Logs.sns_topic_arn
      events        = ["s3:ObjectCreated:Put"]
      filter_prefix = "S3Logs/"
    }
  }
}
