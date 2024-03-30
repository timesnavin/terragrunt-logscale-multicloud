module "AWSLogs" {
  source  = "terraform-aws-modules/sns/aws"
  version = "6.0.1"

  name = "${var.partition_name}-log-bucket-AWSLogs"
  use_name_prefix = true
}
module "S3Logs" {
  source  = "terraform-aws-modules/sns/aws"
  version = "6.0.1"

  name = "${var.partition_name}-log-bucket-S3Logs"
  use_name_prefix = true
}
module "all_notifications" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "4.1.1"

  bucket = module.log_bucket.s3_bucket_id

  eventbridge = true

  sns_notifications = {
    AWSLogs = {
      topic_arn     = module.AWSLogs.topic_arn
      events        = ["s3:ObjectCreated:Put"]
      filter_prefix = "AWSLogs/"
    }
    S3Logs = {
      topic_arn     = module.S3Logs.topic_arn
      events        = ["s3:ObjectCreated:Put"]
      filter_prefix = "S3Logs/"
    }
  }
}
