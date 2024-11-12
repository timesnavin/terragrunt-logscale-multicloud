output "zone_name" {
  value = azurerm_dns_zone.child_zone.name
}
output "name_servers" {
  value = azurerm_dns_zone.child_zone.name_servers
}
output "zone_resource_id" {
  value = azurerm_dns_zone.child_zone.id
}
output "zone_max_number_of_record_sets" {
  value = azurerm_dns_zone.child_zone.max_number_of_record_sets
}

output "zone_number_of_record_sets" {
  value = azurerm_dns_zone.child_zone.number_of_record_sets
}