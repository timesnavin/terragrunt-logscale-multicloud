variable "kubeconfig_path" {
  description = "Path to the Kubernetes kubeconfig file."
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster."
  type        = string
}

variable "instance_profile" {
  description = "Instance profile for Karpenter to use."
  type        = string
}

variable "resource_group_name" {

  description = "(optional) describe your variable"
  type = string
}

variable "location" {
  type        = string

  description = "(optional) describe your variable"
}

variable "karpenter_service_account_name" {
  description = "The name of the Karpenter service account"
  type        = string
}

variable "karpenter_user_assigned_identity_name" {
  description = "The name of the Karpenter user-assigned identity"
  type        = string
}