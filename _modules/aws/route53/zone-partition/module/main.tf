module "zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.11.0"

  zones = {
    "${var.child_domain}.${var.parent_domain}" = {
      comment = "Zone for partition ${var.child_domain}.${var.parent_domain}"
    }
  }
}

data "aws_route53_zone" "selected" {
  name = "${var.parent_domain}."
}

module "delegation_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.11.0"

  zone_id = data.aws_route53_zone.selected.zone_id
  records = [{
    name    = var.child_domain
    type    = "NS"
    ttl     = 600
    records = module.zone.route53_zone_name_servers["${var.child_domain}.${var.parent_domain}"]
  }]
}
