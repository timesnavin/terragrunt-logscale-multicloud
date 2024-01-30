variable "name" {
  type        = string
  description = "(optional) describe your variable"
}
variable "cluster_version" {
  type        = string
  description = "(optional) describe your variable"
}
variable "vpc_id" {
  type        = string
  description = "(optional) describe your variable"
}
variable "subnets" {
  type        = list(string)
  description = "(optional) describe your variable"
}


variable "kms_key_administrators" {
  type        = list(string)
  description = "(optional) describe your variable"
}
variable "additional_aws_auth_roles" {
  description = "Additional AWS IAM roles to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "log_s3_bucket_id" {
  type        = string
  description = "(optional) describe your variable"
}
