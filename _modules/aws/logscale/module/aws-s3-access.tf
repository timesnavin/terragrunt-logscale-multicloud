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
    namespace = local.namespace
  }

  data = {
    platformType             = "aws"
    bucket_prefix            = "${local.namespace}/"
    bucket_storage           = var.logscale_storage_bucket_id
    bucket_export            = var.logscale_export_bucket_id
    bucket_archive           = var.logscale_archive_bucket_id
    kafka_prefix             = "g000"
    logscale_sa_arn          = module.irsa.iam_role_arn
    logscale_sa_name         = var.service_account
    logscale_license         = var.logscale_license
    fqdn                     = local.fqdn
    fqdn_ingest              = local.fqdn_ingest
    saml_issuer              = var.saml_issuer
    saml_signing_certificate = base64encode(var.saml_signing_certificate)
    saml_url                 = var.saml_url
  }
}
