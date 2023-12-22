output "zone_name" {
  value = module.zone.route53_zone_name["${var.child_domain}.${var.parent_domain}"]
}
output "name_servers" {
  value = module.zone.route53_zone_name_servers["${var.child_domain}.${var.parent_domain}"]
}
output "zone_arn" {
  value = module.zone.route53_zone_zone_arn["${var.child_domain}.${var.parent_domain}"]
}
output "zone_id" {
  value = module.zone.route53_zone_zone_id["${var.child_domain}.${var.parent_domain}"]

}
