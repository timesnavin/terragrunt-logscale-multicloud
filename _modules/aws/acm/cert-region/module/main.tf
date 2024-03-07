module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.0.1"

  domain_name = "*.${var.cert_domain}"
  zone_id     = var.parent_zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.cert_domain}",
    "${var.cert_domain}",
  ]

  wait_for_validation = true

  key_algorithm = "EC_secp384r1"

}
