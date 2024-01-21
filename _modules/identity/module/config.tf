
resource "random_password" "salt" {
  length = 16
}
resource "random_password" "default" {
  length = 24
}
resource "random_password" "vc" {
  length = 24
}

resource "dns_address_validation" "identity" {
  depends_on = [kubectl_manifest.flux2-releases]
  provider   = dns-validation

  name = "identity.ref.loglabs.net"
}

resource "time_sleep" "identity" {
  create_duration = "1m"
  depends_on      = [dns_address_validation.identity]
}
