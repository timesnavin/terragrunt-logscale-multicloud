data "aws_s3_bucket" "ls_storage" {
  bucket = var.logscale_storage_bucket_id
}
data "aws_s3_bucket" "ls_export" {
  bucket = var.logscale_export_bucket_id
}
data "aws_s3_bucket" "ls_archive" {
  bucket = var.logscale_archive_bucket_id
}

resource "kubernetes_config_map" "logscale_vars" {
  depends_on = [kubernetes_namespace.logscale]
  metadata {
    name      = "logscalevars"
    namespace = var.namespace
  }

  data = {
    platformType     = "aws"
    bucket_prefix    = "${var.namespace}/"
    bucket_storage   = var.logscale_storage_bucket_id
    bucket_export    = var.logscale_export_bucket_id
    bucket_archive   = var.logscale_archive_bucket_id
    kafka_prefix     = "g000"
    logscale_sa_arn  = module.irsa.iam_role_arn
    logscale_sa_name = var.service_account
    logscale_license = var.logscale_license
  }
}


data "kubernetes_config_map" "clustervars" {
  metadata {
    name      = "clustervars"
    namespace = "flux-system"
  }
}


resource "kubernetes_config_map" "cluster_vars" {
  depends_on = [kubernetes_namespace.logscale]
  metadata {
    name      = "clustervars"
    namespace = var.namespace
  }

  data = data.kubernetes_config_map.clustervars.data
}
