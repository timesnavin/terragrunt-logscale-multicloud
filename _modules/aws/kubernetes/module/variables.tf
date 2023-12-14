variable "iam_role_path" {
  description = "The path to the role"
  type        = string
  default     = "/"

}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string

}
variable "subnet_ids" {
  description = "The subnet IDs"
  type        = list(string)

}
variable "control_plane_subnet_ids" {
  description = "The control plane subnet IDs"
  type        = list(string)
  default     = null
}
