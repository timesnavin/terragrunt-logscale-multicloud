module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.0.0"

  domain_name = "${var.child_domain}.${var.parent_domain}"
  zone_id     = var.parent_zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.child_domain}.${var.parent_domain}",
    "${var.child_domain}.${var.parent_domain}",
  ]

  wait_for_validation = false

}
