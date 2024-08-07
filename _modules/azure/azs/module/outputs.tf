output "az_names" {
  value = random_shuffle.az.result
}
output "public_subnet_ipv4_prefixes" {
  value = azurerm_subnet.public[*].address_prefixes
}

output "vpc_cidr" {
  value = azurerm_virtual_network.main.address_space[0]
}
output "public_subnets" {
  value = azurerm_subnet.public[*].id
}
output "private_subnets" {
  value = azurerm_subnet.private[*].id
}