

variable "iam_role_path" {
  
}
variable "iam_policy_path" {
  default = "/"
}


variable "oidc_provider_arn" {
  type        = string
  description = "(optional) describe your variable"
}

variable "namespace" {
  
}

variable "logscale_data_bucket_arn" {
  type = string
  description = "(optional) describe your variable"
}
variable "logscale_export_bucket_arn" {
  type = string
  description = "(optional) describe your variable"
}

variable "service_account" {
    default = "logscale-sa"
}

variable "force_destroy" {
  default = true
  
}