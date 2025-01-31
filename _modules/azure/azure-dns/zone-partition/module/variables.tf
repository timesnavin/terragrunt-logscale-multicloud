variable "parent_domain" {
  type        = string
  description = "(optional) describe your variable"
}

variable "child_domain" {

}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
  
}

variable "resource_group_name" {

  description = "(optional) describe your variable"
  type = string
}
