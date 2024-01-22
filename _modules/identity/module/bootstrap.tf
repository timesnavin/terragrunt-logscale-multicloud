
resource "random_password" "bootstrap_password" {
  length = 21
}
resource "random_password" "bootstrap_token" {
  length = 40
}

resource "kubernetes_secret" "bootstrap" {
  metadata {
    name      = "authentik-bootstrap"
    namespace = "identity"
  }

  data = {
    password = random_password.bootstrap_password.result
    token = random_password.bootstrap_token.result
    email = var.admin_email
  }
  type = "Opaque"
}