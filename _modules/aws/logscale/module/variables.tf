

# variable "iam_role_path" {

# }
# variable "iam_policy_path" {
#   default = "/"
# }
variable "region" {
  type = string
  description = "(optional) describe your variable"
}

variable "oidc_provider_arn" {
  type        = string
  description = "(optional) describe your variable"
}

variable "logscale_storage_bucket_id" {
  type        = string
  description = "(optional) describe your variable"
}
variable "logscale_export_bucket_id" {
  type        = string
  description = "(optional) describe your variable"
}
variable "logscale_archive_bucket_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "service_account" {
  default = "logscale-sa"
}

variable "logscale_license" {
  type        = string
  description = "(optional) describe your variable"
}

variable "force_destroy" {
  default = true
}

variable "domain_name" {
  type        = string
  description = "(optional) describe your variable"
}


variable "tenant" {

}

variable "saml_url" {
  type        = string
  description = "(optional) describe your variable"
}

variable "saml_signing_certificate" {
  type        = string
  description = "(optional) describe your variable"
}
variable "saml_issuer" {
  type = string
  description = "(optional) describe your variable"
}

variable "LogScaleRoot" {
  type = string
  description = "(optional) describe your variable"
}