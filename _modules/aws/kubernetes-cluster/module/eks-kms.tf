module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.1"

  aliases               = ["eks/${var.cluster_name}-ck"]
  description           = "${var.cluster_name} cluster encryption key"
  enable_default_policy = true
  key_owners = concat(
    ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"],
    var.additional_kms_owners
  )
}
