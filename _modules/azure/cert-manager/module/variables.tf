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

#variable "email" {
#  type = string
#  description = "Email address for Let's Encrypt registration"
#}

variable "azure_dns_zone_name" {
  default = "logsr.life"
  description = "Name of the DNS Zone in Azure DNS"
  
}

variable "azure_dns_resource_group" {
  description = "Resource group where Azure DNS zone is located"
  default = "andre-test-env"
}

variable "resource_group_name" {
  description = "(optional) describe your variable"
  type = string
}

variable "location" {
  type        = string

  description = "(optional) describe your variable"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster."
  type        = string
}

variable "email" {
  description = "Email for Lets Encrypt"
  default = ""
}

variable "ingress_class" {
  description = "Ingress Class used by Ingress Controller"
  type = string
  default = "azure/application-gateway"
  
}