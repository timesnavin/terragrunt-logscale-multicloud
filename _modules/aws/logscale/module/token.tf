resource "dns_address_validation" "logscale" {
  depends_on = [kubectl_manifest.flux2-releases]
  provider   = dns-validation

  name = local.fqdn
}
resource "dns_address_validation" "ingest" {
  depends_on = [kubectl_manifest.flux2-releases]
  provider   = dns-validation

  name = local.fqdn_ingest
}

resource "time_sleep" "dns" {
  depends_on = [
    dns_address_validation.logscale,
    dns_address_validation.ingest
  ]
  create_duration = "1m"
}
data "kubernetes_secret" "otel-token" {
  depends_on = [time_sleep.dns]
  metadata {
    name      = "infra-kubernetes-otel"
    namespace = local.namespace
  }
}
