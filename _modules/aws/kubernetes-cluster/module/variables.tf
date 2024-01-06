variable "cluster_name" {

}
variable "cluster_version" {
  description = "The Kubernetes version"
  type        = string
  default     = "1.27"

}
variable "cluster_region" {
  description = "The region"
  type        = string
  default     = "us-east-1"

}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string

}

variable "node_subnet_ids" {
  description = "The subnet IDs"
  type        = list(string)

}

variable "control_plane_subnet_ids" {
  description = "The control plane subnet IDs"
  type        = list(string)
  default     = null

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

# variable "vpc_id" {
#   description = "The VPC ID"
#   type        = string

# }

# variable "subnet_ids" {
#   description = "The subnet IDs"
#   type        = list(string)

# }

# variable "control_plane_subnet_ids" {
#   description = "The control plane subnet IDs"
#   type        = list(string)
#   default     = null

# }

# variable "external_dns_route53_zone_arns" {
#   type = list(string)

# }

variable "GITHUB_PAT" {
  description = "The PAT"
  type        = string

}