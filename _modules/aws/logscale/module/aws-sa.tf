
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
  path = var.iam_policy_path

  
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "FullAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetLifecycleConfiguration",
          "s3:DeleteObjectVersion",
          "s3:ListBucketVersions",
          "s3:GetBucketLogging",
          "s3:RestoreObject",
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:GetObject",
          "s3:PutLifecycleConfiguration",
          "s3:GetBucketCORS",
          "s3:DeleteObject",
          "s3:GetBucketLocation",
          "s3:GetObjectVersion"
        ],
        "Resource" : [
          "${module.s3-bucket.s3_bucket_arn}/*",
          module.s3-bucket.s3_bucket_arn
        ]
      },
      {
        "Sid" : "ListBucket",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:HeadBucket"
        ],
        "Resource" : module.s3-bucket.s3_bucket_arn
      },
      {
        "Sid" : "KMSEncryptDecrypt",
        "Effect" : "Allow",
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
          "kms:DescribeKey"
        ],
        "Resource" : [
          module.kms.key_arn
        ]
      }
    ]
  })
}