
module "irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.0"

  role_name_prefix = "logscale"
  role_path        = var.iam_role_path

  role_policy_arns = {
    "object" = module.iam_iam-policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${var.service_account}"]
    }
  }
}

module "iam_iam-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.33.0"

  name_prefix = "${var.namespace}_${var.service_account}"
  path        = var.iam_policy_path


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "FullAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "${data.aws_s3_bucket.ls_storage.arn}/${var.namespace}/*",
          "${data.aws_s3_bucket.ls_archive.arn}/${var.namespace}/*",
          "${data.aws_s3_bucket.ls_export.arn}/${var.namespace}/*",
        ]
      },
      {
        "Sid" : "ListBucket",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          data.aws_s3_bucket.ls_storage.arn,
          data.aws_s3_bucket.ls_archive.arn,
          data.aws_s3_bucket.ls_export.arn,
        ]
      }
    ]
  })
}
