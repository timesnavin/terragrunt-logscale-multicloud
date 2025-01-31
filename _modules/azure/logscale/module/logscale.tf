# _modules/azure/logscale/module/logscale.tf

resource "kubectl_manifest" "logscale" {
  yaml_body = templatefile(
    "${path.module}/manifests/helm-manifests/logscale-azure.yaml",
    {
      namespace                = local.namespace
      tenant                   = var.tenant
      managed_identity_client_id = azurerm_user_assigned_identity.logscale.client_id
      tenant_id                = data.azurerm_client_config.current.tenant_id
      kafka_namespace          = var.kafka_namespace
      kafka_name              = var.kafka_name
      kafka_prefix            = var.kafka_prefix
      storage_account_name    = var.storage_account_name
      container_storage       = var.container_storage
      container_export        = var.container_export
      container_archive       = var.container_archive
      container_prefix        = "${local.namespace}/"
      logscale_sa_name       = var.service_account
      logscale_license       = var.logscale_license
      fqdn                   = local.fqdn
      fqdn_ingest            = local.fqdn_ingest
      saml_issuer            = var.saml_issuer
      saml_signing_certificate = var.saml_signing_certificate
      saml_url               = var.saml_url
      rootUser               = var.LogScaleRoot
    }
  )
}
