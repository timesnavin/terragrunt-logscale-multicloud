variable "cluster_name" {

}
variable "node_subnet_ids" {
  description = "The node subnet IDs"
  type        = list(string)

}
variable "iam_role_path" {
  description = "The path to the role"
  type        = string
  default     = "/"

}

# variable "additional_aws_auth_roles" {
#   description = "Additional AWS IAM roles to add to the aws-auth configmap"
#   type        = list(any)
#   default     = []
# }
variable "additional_kms_owners" {
  description = "Additional AWS IAM roles to add to the kms key"
  type        = list(any)
  default     = []

}

variable "GITHUB_PAT" {
  type        = string
  description = "(optional) describe your variable"
}


variable "oidc_provider_arn" {
  type = string
  description = "(optional) describe your variable"
}