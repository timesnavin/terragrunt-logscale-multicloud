
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


variable "azure_dns_zone_name" {
  description = "Name of Azure DNS zone"
  type        = string
  default = "logsr.life"
}

variable "application_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string
  default = "logscale-apigw"
}

variable "appgw_subnet_prefix" {
  description = "CIDR block for Application Gateway subnet"
  type = string
  default = "10.0.3.0/24"
}

variable "name" {
  description = "Azure Virtual Network name from Vnet module"
  type = string
}
