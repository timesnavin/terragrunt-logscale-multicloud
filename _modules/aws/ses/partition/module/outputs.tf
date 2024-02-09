output "smtp_user" {
  value = module.iam_ses_user.iam_access_key_id
}
output "smtp_password" {
  sensitive = true
  value     = module.iam_ses_user.iam_access_key_ses_smtp_password_v4
}
output "smtp_server" {
  value = "email-smtp.${var.region}.amazonaws.com"
}
