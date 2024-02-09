
module "dns-public-zone" {
  source     = "terraform-google-modules/cloud-dns/google"
  version    = "5.2.0"
  project_id = var.project_id
  type       = "public"
  name       = replace("${var.child_domain}.${var.parent_domain}", ".", "-")
  domain     = "${var.child_domain}.${var.parent_domain}."
}

# module "zone" {
#   source  = "terraform-aws-modules/route53/aws//modules/zones"
#   version = "2.11.0"

#   zones = {
#     "${var.child_domain}.${var.parent_domain}" = {
#       comment = "Zone for partition ${var.child_domain}.${var.parent_domain}"
#     }
#   }
# }


# module "delegation_records" {
#   source  = "terraform-aws-modules/route53/aws//modules/records"
#   version = "2.11.0"

#   zone_id = var.parent_zone_id
#   records = [{
#     name    = var.child_domain
#     type    = "NS"
#     ttl     = 600
#     records = module.zone.route53_zone_name_servers["${var.child_domain}.${var.parent_domain}"]
#   }]
# }
