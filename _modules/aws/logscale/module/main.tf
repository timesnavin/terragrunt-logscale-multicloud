data "aws_caller_identity" "current" {}

data "kubectl_path_documents" "flux2-repos" {
  pattern = "./manifests/flux-repos/*.yaml"
}

locals {
  fqdn        = "${var.tenant}-logscale.${var.domain_name}"
  fqdn_ingest = "${var.tenant}-logscale-ingest.${var.domain_name}"
  namespace   = "${var.tenant}-logscale"
}
