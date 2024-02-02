variable "domain_name" {
    type = string
    description = "(optional) describe your variable"
}
variable "host_name" {
    type = string
    default = "identity"
    description = "(optional) describe your variable"
}
variable "admin_email" {
    type = string
    description = "(optional) describe your variable"
}

variable "smtp_user" {
    type = string
    description = "(optional) describe your variable"
}
variable "smtp_password" {
    type = string
    description = "(optional) describe your variable"
}
variable "smtp_server" {
    type = string
    description = "(optional) describe your variable"
}
variable "smtp_port" {
    type = string
    default = "587"
    description = "(optional) describe your variable"
}
variable "smtp_tls" {
    type = bool
    default = true
    description = "(optional) describe your variable"
}

variable "from_email" {
    type = string
    description = "(optional) describe your variable"
}