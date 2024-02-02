resource "aws_sesv2_configuration_set" "main" {
  configuration_set_name = var.partition

   delivery_options {
    tls_policy = "REQUIRE"
  }

  reputation_options {
    reputation_metrics_enabled = false
  }

  sending_options {
    sending_enabled = true
  }

  suppression_options {
    suppressed_reasons = ["BOUNCE", "COMPLAINT"]
  }

}

resource "aws_sesv2_email_identity" "main" {
  email_identity = var.domain
    configuration_set_name = aws_sesv2_configuration_set.main.configuration_set_name

}

resource "aws_route53_record" "dkim" {
  count = 3

  zone_id = var.domain_zone_id
  name    = "${aws_sesv2_email_identity.main.dkim_signing_attributes[0].tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_sesv2_email_identity.main.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]

  depends_on = [aws_sesv2_email_identity.main]
}


resource "aws_iam_policy" "send_mail" {
  name   = "${var.email_user_name_prefix}-send-mail-${random_string.random.result}"
  policy = data.aws_iam_policy_document.send_mail.json
}

data "aws_iam_policy_document" "send_mail" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = [aws_sesv2_email_identity.main.arn]
  }
}

resource "random_string" "random" {
  length           = 8
  special          = false
  upper = false  
}

module "iam_ses_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.33.1"

  name = "${var.email_user_name_prefix}-send-mail-${random_string.random.result}"

  create_iam_user_login_profile = false
  create_iam_access_key         = true
  password_reset_required = false
  policy_arns                   = [
    aws_iam_policy.send_mail.arn
    ]
}
