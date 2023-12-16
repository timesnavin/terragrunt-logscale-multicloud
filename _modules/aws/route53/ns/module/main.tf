module "zone" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "2.11.0"

  zone_id = var.zone_id
  records = var.records

}
