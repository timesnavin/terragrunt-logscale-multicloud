

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
variable "service_account" {
    default = "logscale-sa"
}

variable "additional_kms_owners" {
  type        = list(string)
  description = "(optional) describe your variable"
  
}

variable "force_destroy" {
  default = true
  
}