output "admin_password" {
  sensitive = true
  value     = random_password.bootstrap_password.result
}
output "admin_token" {
  sensitive = true
  value     = random_password.bootstrap_token.result
}
output "url" {
  value = "https://${var.host_name}.${var.domain_name}"
}
