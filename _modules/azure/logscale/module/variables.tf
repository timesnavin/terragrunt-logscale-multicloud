# _modules/azure/logscale/module/variables.tf

# Basic configuration variables
variable "tenant" {
  type        = string
  description = "Name of the tenant"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region location"
}

variable "domain_name" {
  type        = string
  description = "Domain name for FQDN construction"
}

# Kubernetes configuration
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}

# LogScale configuration
variable "LogScaleRoot" {
  type        = string
  description = "LogScale root user"
}

# Kafka configuration
variable "kafka_namespace" {
  type        = string
  description = "Kafka namespace"
}

variable "kafka_name" {
  type        = string
  description = "Kafka cluster name"
}

variable "kafka_prefix" {
  type        = string
  description = "Kafka topic prefix"
}

# Service account
variable "service_account" {
  type        = string
  description = "Name of the service account"
}

# Authentication and authorization
variable "logscale_license" {
  type        = string
  description = "LogScale license key"
  sensitive   = true
}

variable "saml_issuer" {
  type        = string
  description = "SAML issuer URL"
}

variable "saml_signing_certificate" {
  type        = string
  description = "SAML signing certificate"
  sensitive   = true
}

variable "saml_url" {
  type        = string
  description = "SAML URL"
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

# Storage configuration
variable "storage_account_name" {
  type        = string
  description = "Storage account name"
  default     = ""
}

variable "container_storage" {
  type        = string
  description = "Storage container name"
  default     = ""
}

variable "container_export" {
  type        = string
  description = "Export container name"
  default     = ""
}

variable "container_archive" {
  type        = string
  description = "Archive container name"
  default     = ""
}
