# Retreive information about current Azure Client configuration
data "azurerm_client_config" "current" {}

# Retreive Kubernetes manifest from the specified path
data "kubectl_path_documents" "flux2-repos" {
  pattern = "./manifests/flux-repos/*.yaml"
}

# Local variables
locals {
  fqdn        = "logscale.${var.tenant}.${var.domain_name}"
  fqdn_ingest = "logscale-ingest.${var.tenant}.${var.domain_name}"
  namespace   = "${var.tenant}-logscale"
}

# Data source to get the AKS cluster
data "azurerm_kubernetes_cluster" "aks" {
  name = var.cluster_name
  resource_group_name = var.resource_group_name
}