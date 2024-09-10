variable "projectRoot" {
  type        = string

  description = "(optional) describe your variable"
}
variable "name" {
  type        = string

  description = "(optional) describe your variable"
}
variable "resourceGroup" {

  description = "(optional) describe your variable"
}
variable "resourceGroupLocation" {
  type        = string

  description = "(optional) describe your variable"
}

variable "location" {
  type        = string

  description = "(optional) describe your variable"
}

variable "aks_subnet_id" {
  type        = string

  description = "(optional) describe your variable"
}
variable "pods_subnet_id" {
  type        = string

  description = "(optional) describe your variable"
}

variable "karpenter_service_account_name" {
  type        = string
  description = "The name of the Karpenter service account"
}

variable "karpenter_user_assigned_identity_name" {
  type        = string
  description = "The name of the Karpenter user-assigned identity"
}
