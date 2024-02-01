
# output "otel-token" {
#   sensitive = true
#   value     = data.kubernetes_secret.otel-token.data["token"]
# }

output "logscale_fqdn" {
  value = local.fqdn
}
output "logscale_fqdn_ingest" {
  value = local.fqdn_ingest
}
