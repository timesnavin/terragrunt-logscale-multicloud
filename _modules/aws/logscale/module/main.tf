data "aws_caller_identity" "current" {}

data "kubectl_path_documents" "flux2-repos" {
  pattern = "./manifests/flux-repos/*.yaml"
}

locals {
  fqdn        = "logscale.${var.tenant}.${var.domain_name}"
  fqdn_ingest = "logscale-ingest.${var.tenant}.${var.domain_name}"
  namespace   = "${var.tenant}-logscale"
}
