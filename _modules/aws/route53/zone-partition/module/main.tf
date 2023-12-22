module "zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.11.0"

  zones = {
    "${var.zone_name}" = {
      comment = "Zone for ${var.zone_name}"
    }
  }
}


module "zone" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.11.0"

  zone_id = var.parent_zone_id
  records = [{
    name    = "${var.zone_name}"
    type    = "NS"
    ttl     = 600
    records = module.zone.outputs.route53_zone_name_servers[var.zone_name]
  }]
}
