variable "name" {
  type        = string
  description = "(optional) describe your variable"
}
variable "azs" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "public_subnet_ipv6_prefixes" {
  type        = list(string)
  description = "(optional) describe your variable"
}
variable "private_subnet_ipv6_prefixes" {
  type        = list(string)
  description = "(optional) describe your variable"
}
variable "private_subnets" {
  type        = list(string)
  description = "(optional) describe your variable"
}
variable "public_subnets" {
  type        = list(string)
  description = "(optional) describe your variable"
}
variable "cidr" {
  type = string
  description = "(optional) describe your variable"
}