# output "admin_password" {
#   sensitive = true
#   value     = random_password.bootstrap_password.result
# }
# output "admin_token" {
#   sensitive = true
#   value     = random_password.bootstrap_token.result
# }
# output "url" {
#   value = "https://identity.${var.domain_name}"
# }

output "metadata" {
  value = data.authentik_provider_saml_metadata.provider.metadata
}
output "url" {
  value = resource.authentik_provider_saml.this.url_sso_redirect
}

output "signing_certificate" {
  value = data.authentik_certificate_key_pair.generated.certificate_data
}

output "issuer" {
  value = resource.authentik_provider_saml.this.issuer
}
