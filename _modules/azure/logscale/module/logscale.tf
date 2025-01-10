resource "kubectl_manifest" "logscale" {
  depends_on = [
    kubectl_manifest.kafka-topics
  ]
  yaml_body = templatefile(
    "./manifests/helm-manifests/logscale.yaml",
    {
      namespace                = local.namespace
      region                   = var.region
      platformType             = "aws"
      kafka_namespace          = var.kafka_namespace
      tenant                   = var.tenant
      kafka_name               = var.kafka_name
      kafka_prefix             = "${format("g%03s", counters_monotonic.kafka_prefix.value)}"
      bucket_prefix            = "${local.namespace}/"
      bucket_storage           = var.logscale_storage_bucket_id
      bucket_export            = var.logscale_export_bucket_id
      bucket_archive           = var.logscale_archive_bucket_id
      logscale_sa_arn          = module.irsa.iam_role_arn
      logscale_sa_name         = var.service_account
      logscale_license         = var.logscale_license
      fqdn                     = local.fqdn
      fqdn_ingest              = local.fqdn_ingest
      saml_issuer              = var.saml_issuer
      saml_signing_certificate = base64encode(var.saml_signing_certificate)
      saml_url                 = var.saml_url
      rootUser                 = var.LogScaleRoot
      ingest_role_arn          = module.ingest-role.iam_role_arn

  })
}
