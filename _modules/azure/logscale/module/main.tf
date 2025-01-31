# _modules/azure/logscale/module/main.tf

# Create managed identity for LogScale
resource "azurerm_user_assigned_identity" "logscale" {
  name                = "${var.tenant}-logscale-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

locals {
  namespace    = "${var.tenant}-logscale"
  fqdn        = "logscale.${var.tenant}.${var.domain_name}"
  fqdn_ingest = "logscale-ingest.${var.tenant}.${var.domain_name}"
}
