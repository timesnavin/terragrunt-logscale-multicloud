resource "azurerm_virtual_network" "main" {
  name                = "mainVnet"
  address_space       = [local.cidr]
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "random_shuffle" "az" {
  input        = local.availability_zones
  result_count = length(local.availability_zones) > var.max_zones ? var.max_zones : length(local.availability_zones)
}

# Create public IPv6 subnets
resource "azurerm_subnet" "public" {
  count                = length(local.public_subnets)
  name                 = "publicSubnet${count.index + 1}"
  resource_group_name  = azurerm_virtual_network.main.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [element(local.public_subnets, count.index)]
  depends_on           = [random_shuffle.az]
}

# Create private IPv6 subnets
resource "azurerm_subnet" "private" {
  count                = length(local.private_subnets)
  name                 = "privateSubnet${count.index + 1}"
  resource_group_name  = azurerm_virtual_network.main.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [element(local.private_subnets, count.index)]
  depends_on           = [random_shuffle.az]
}
