# ID of the Storage Account
output "log_storage_account_id" {
  value = azurerm_storage_account.log_storage_account.id
}

# Name of the Storage Account
output "log_storage_account_name" {
  value = azurerm_storage_account.log_storage_account.name
}

# Primary Blob Endpoint of the Storage Account
output "log_storage_account_primary_blob_endpoint" {
  value = azurerm_storage_account.log_storage_account.primary_blob_endpoint
}

# ID of the Storage Account
output "log_storage_container_id" {
  value = azurerm_storage_container.logs_container.id
}

# Name of the Storage Container
output "log_storage_container_name" {
  value = azurerm_storage_container.logs_container.name
}

# Resource ID of the Service Bus Topic for Application Logs
output "app_logs_servicebus_topic_id" {
  value = azurerm_servicebus_topic.apps_logs_topic.id
}

# Name of the Service Bus Topic for Application Logs
output "app_logs_servicebus_topic_name" {
  value = azurerm_servicebus_topic.apps_logs_topic.name
}

# Resource ID of the Service Bus Topic for Storage Logs
output "storage_logs_servicebus_topic_id" {
  value = azurerm_servicebus_topic.storage_logs_topic.id
}

# Name  of the Service Bus Topic for Storage Logs
output "storage_logs_servicebus_topic_name" {
  value = azurerm_servicebus_topic.storage_logs_topic.name
}

# Service Bus Namespace Name
output "servicebus_namespace_name" {
  value   = azurerm_servicebus_namespace.log_namespace.name
}

# Service Bus Namespace Connection String
output "servicebus_namespace_connection_string" {
  value   = azurerm_servicebus_namespace.log_namespace.default_primary_connection_string
  sensitive = true
}

# Even Grid System Topic ID
output "eventgrid_system_topic_id" {
  value   = azurerm_eventgrid_system_topic.storage_events.id
}

# Managed Identity ID for Event Grid
output "eventgrid_managed_identity_id" {
  value   = azurerm_user_assigned_identity.eventgrid_identity.id
}