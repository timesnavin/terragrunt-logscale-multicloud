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

variable "control_plane_subnet_ids" {
  description = "The control plane subnet IDs"
  type        = list(string)

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
variable "iam_policy_path" {
  default = "/"
}
variable "iam_policy_name_prefix" {
  default = "AmazonEKS_"
}

variable "node_min_size" {
  type        = number
  default     = 0
  description = "(optional) describe your variable"
}
variable "node_max_size" {
  type        = number
  default     = 9
  description = "(optional) describe your variable"
}
variable "node_desired_size" {
  type    = number
  default = 0

  description = "(optional) describe your variable"
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
