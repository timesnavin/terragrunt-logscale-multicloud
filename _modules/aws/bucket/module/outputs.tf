output "log_s3_bucket_id" {
  value = module.log_bucket.s3_bucket_id
}
output "log_s3_bucket_arn" {
  value = module.log_bucket.s3_bucket_arn
}

output "logscale_data_bucket_arn" {
  value = module.s3_logscale_data.s3_bucket_arn
}
output "logscale_export_bucket_arn" {
  value = module.s3_logscale_export.s3_bucket_arn
}
