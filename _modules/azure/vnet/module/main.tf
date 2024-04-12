resource "azurerm_virtual_network" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resourceGroup
  address_space       = var.vnet_address_space
}

#Create the Subnet
resource "azurerm_subnet" "gw" {
  name                 = "gateway"
  resource_group_name  = var.resourceGroup
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24", "fd00:db8:deca::/64"]
}

#Create the Subnet
resource "azurerm_subnet" "aks" {
  name                 = "aks"
  resource_group_name  = var.resourceGroup
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24", "fd00:db8:deca:1::/64"]
}

resource "azurerm_subnet" "pods" {
  name                 = "pods"
  resource_group_name  = var.resourceGroup
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.16.0/20", "fd00:db8:deca:10::/64"]

  delegation {
    name = "aks-delegation"

    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
