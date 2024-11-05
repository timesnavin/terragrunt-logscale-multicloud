variable "sbname" {
  type        = string
  description = "(optional) describe your variable"
  default = "sblogscale"
  
}

variable "resource_group_name" {

  description = "(optional) describe your variable"
  type = string
}

variable "location" {
  type        = string
  description = "(optional) describe your variable"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to resources"
  default = {}
  
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account"
  default     = null
}

variable "container_name" {
  type        = string
  description = "The name of the blob container within the storage account"
  default     = "logscontainer"
}

variable "service_bus_sku" {
  type        = string
  description = "The SKU of the Service Bus Namespace"
  default     = "standard"
}

variable "event_grid_identity_name" {
  type        = string
  description = "The name of the User Assigned Managed Identity for Event Grid"
  default     = null
}

