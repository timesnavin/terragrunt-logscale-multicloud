variable "resourceGroup" {
  type        = string
  description = "(optional) describe your variable"
}
variable "name" {
  type        = string
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


variable "vnet_address_space" {
  description = "The address space of the VNET"
  default     = ["10.0.0.0/16", "fd00:db8:deca::/48"]
}
