output "logscale_storage_bucket_arn" {
  value = module.s3_logscale_storage.s3_bucket_arn
}
output "logscale_export_bucket_arn" {
  value = module.s3_logscale_export.s3_bucket_arn
}
output "logscale_archive_bucket_arn" {
  value = module.s3_logscale_archive.s3_bucket_arn
}

output "logscale_storage_bucket_id" {
  value = module.s3_logscale_storage.s3_bucket_id
}
output "logscale_export_bucket_id" {
  value = module.s3_logscale_export.s3_bucket_id
}
output "logscale_archive_bucket_id" {
  value = module.s3_logscale_archive.s3_bucket_id
}
