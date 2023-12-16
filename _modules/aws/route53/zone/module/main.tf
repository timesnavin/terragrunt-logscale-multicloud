module "zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "2.11.0"

  zones = {
    "${var.zone_name}" = {
      comment = "Zone for ${var.zone_name}"
    }
  }
}
