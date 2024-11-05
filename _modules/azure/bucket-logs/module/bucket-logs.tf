# Create Resource Group
/*
resource "azurerm_resource_group" "log_rg" {
  name = var.resource_group_name
  location = var.location
  
  tags = var.tags
}
*/
# Azure Storage Account
resource "azurerm_storage_account" "log_storage_account" {
  name                      = var.storage_account_name != null ? var.storage_account_name : lower(replace("${var.sbname}logstorage", "_", ""))
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  #enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
 # allow_blob_public_access  = false
  is_hns_enabled            = false
  #force_destroy             = true
  #enable_blob_versioning    = true

  tags = var.tags
}

# Storage Container
resource "azurerm_storage_container" "logs_container" {
  name                      = var.container_name
  storage_account_name      = azurerm_storage_account.log_storage_account.name
  container_access_type     = "private"
}

# Lifecycle Management Policy
resource "azurerm_storage_management_policy" "log_storage_account_policy" {
  storage_account_id = azurerm_storage_account.log_storage_account.id

  rule {
    name    = "delete-old-versions"
    enabled = true

    filters {
      prefix_match = ["*"]      
      blob_types   = ["blockBlob"]
    }

    actions {
      version {
        delete_after_days_since_creation = 14
      }
    }
  }
}