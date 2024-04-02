
module "irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.38.0"

  role_name_prefix = "${local.namespace}-logscale"
  # role_path        = var.iam_role_path

  role_policy_arns = {
    "object" = module.iam_iam-policy.arn
    "ingest" = module.iam_iam-assume_ingest-base.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${local.namespace}:${var.service_account}"]
    }
  }
}

module "iam_iam-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.38.0"

  name_prefix = "${local.namespace}_${var.service_account}"
  # path        = var.iam_policy_path


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "FullAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "${data.aws_s3_bucket.ls_storage.arn}/${local.namespace}/*",
          "${data.aws_s3_bucket.ls_archive.arn}/${local.namespace}/*",
          "${data.aws_s3_bucket.ls_export.arn}/${local.namespace}/*",
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


module "iam_iam-assume_ingest-base" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.38.0"

  name_prefix = "${local.namespace}_${var.service_account}-assume-ingest-base"
  # path        = var.iam_policy_path


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "FullAccess",
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Resource" : [
          module.ingest-role.iam_role_arn
        ]
      },
    ]
  })
}
