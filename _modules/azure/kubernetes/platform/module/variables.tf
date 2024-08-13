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