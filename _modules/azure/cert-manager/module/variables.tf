variable "namespace" {
  type        = string
  default     = "cert-manager"
  description = "The namespace where cert-manager will be installed"
}

variable "cert_manager_version" {
  type        = string
  default = "v1.16.1"
  description = "The version of cert-manager to install"
}