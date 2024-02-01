
resource "random_password" "key" {
  length  = 50
  special = false
}

resource "kubernetes_secret" "secretkey" {
  depends_on = [kubernetes_namespace.identity]
  metadata {
    name      = "authentik-secret-key"
    namespace = "identity"
  }

  data = {
    secretkey = random_password.key.result
  }
  type = "Opaque"
}


resource "dns_address_validation" "identity" {
  depends_on = [kubectl_manifest.flux2-releases]
  provider   = dns-validation

  name = "${var.host_name}.${var.domain_name}"
  timeouts {
    create = "5m"
  }
}

resource "time_sleep" "identity" {
  create_duration = "1m"
  depends_on      = [dns_address_validation.identity]
}
