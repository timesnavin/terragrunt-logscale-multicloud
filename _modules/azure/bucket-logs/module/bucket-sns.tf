# Service Bus Namespace
resource "azurerm_servicebus_namespace" "log_namespace" {
  name                = "${var.sbname}-log-namespace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags
}

# Service Bus Topics
resource "azurerm_servicebus_topic" "apps_logs_topic" {
  name                = "${var.sbname}-app-logs-topic"
  #resource_group_name = var.resource_group_name
  namespace_id      = azurerm_servicebus_namespace.log_namespace.id
  #enable_partitioning = true
}

resource "azurerm_servicebus_topic" "storage_logs_topic" {
  name                = "${var.sbname}-storage-logs-topic"
  #resource_group_name = var.resource_group_name
  namespace_id      = azurerm_servicebus_namespace.log_namespace.id
  #enable_partitioning = true
}

# Event Grid System Topic for Storage Account
resource "azurerm_eventgrid_system_topic" "storage_events" {
  #name                = "${var.sbname}-storage_events"

  name                = "test"   #Test Config
  resource_group_name = var.resource_group_name
  location            = var.location
  topic_type          = "Microsoft.Storage.StorageAccounts"
  source_arm_resource_id = azurerm_storage_account.log_storage_account.id
}

# User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "eventgrid_identity" {
  name                = "${var.sbname}-eventgrid-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Assign Role to  Managed Identity
resource "azurerm_role_assignment" "eventgrid_to_servicebus" {
  scope                = azurerm_servicebus_namespace.log_namespace.id
  #name                 = "${var.sbname}-eventgrid-identity"
  role_definition_name =  "Azure Service Bus Data Sender"
  principal_id         = azurerm_user_assigned_identity.eventgrid_identity.principal_id
}

# Event Grid Events Subscriptions

# Application Logs Subscription
resource "azurerm_eventgrid_system_topic_event_subscription" "app_logs_subscription" {
  name                        = "${var.sbname}-app-logs-subscription"
  resource_group_name         = var.resource_group_name
  system_topic              = azurerm_eventgrid_system_topic.storage_events.name
 
 
  service_bus_topic_endpoint_id  = azurerm_servicebus_topic.apps_logs_topic.id

  included_event_types         = ["Microsoft.Storage.BlobCreated"]

  labels                      = ["AppLogs"]

  advanced_filter {
    string_begins_with {
      key = "subject"
      values    = ["/blobServices/default/containers/${var.container_name}/blobs/AppLogs/"]
    }
  }

  #identity_type = "UserAssigned"
  #user_assigned_identity = azurerm_user_assigned_identity.eventgrid_identity.id
} 

# Storage Logs Subscription
resource "azurerm_eventgrid_system_topic_event_subscription" "storage_logs_subscription" {
  name                        = "${var.sbname}-storage-logs-subscription"
  resource_group_name         = var.resource_group_name
  system_topic              = azurerm_eventgrid_system_topic.storage_events.name
 
 
  service_bus_topic_endpoint_id  = azurerm_servicebus_topic.storage_logs_topic.id

  included_event_types         = ["Microsoft.Storage.BlobCreated"]

  labels                      = ["StorageLogs"]

  advanced_filter {
    string_begins_with {
      key = "subject"
      values    = ["/blobServices/default/containers/${var.container_name}/blobs/StorageLogs/"]
    }
  }

  #identity_type = "UserAssigned"
  #user_assigned_identity = azurerm_user_assigned_identity.eventgrid_identity.id
} 