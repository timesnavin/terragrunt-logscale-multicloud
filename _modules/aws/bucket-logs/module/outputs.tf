output "log_s3_bucket_id" {
  value = module.log_bucket.s3_bucket_id
}
output "log_s3_bucket_arn" {
  value = module.log_bucket.s3_bucket_arn
}
output "bucket_id" {
  value = module.log_bucket.s3_bucket_id
}
output "log_sns_topic_arn" {
  value = module.AWSLogs.topic_arn
}
