module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.0.0"

  domain_name = "*.${var.domain}"
  zone_id     = var.zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain}",
    var.domain,
  ]

  wait_for_validation = false

  key_algorithm = "EC_secp384r1"

}
