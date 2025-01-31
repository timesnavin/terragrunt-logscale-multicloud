# _modules/azure/logscale/module/outputs.tf

output "namespace" {
  value = local.namespace
}

output "managed_identity_id" {
  value = azurerm_user_assigned_identity.logscale.id
}

output "managed_identity_client_id" {
  value = azurerm_user_assigned_identity.logscale.client_id
}

output "fqdn" {
  value = local.fqdn
}

output "fqdn_ingest" {
  value = local.fqdn_ingest
}
