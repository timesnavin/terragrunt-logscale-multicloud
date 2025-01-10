locals {
  cidr    = "10.0.0.0/16"
  subnets = cidrsubnets(local.cidr, 1, 1)
}

output "name" {
  value = azurerm_virtual_network.main.name
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "pods_subnet_id" {
  value = azurerm_subnet.pods.id
}
