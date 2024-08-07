
resource "azurerm_virtual_network" "main" {
  name = "mainVnet"
  address_space = [local.cidr]
  location = local.location
  resource_group_name = local.resource_group_name
  }

resource "random_shuffle" "az" {
  input        = local.availability_zones
  result_count = length(local.availability_zones) > var.max_zones ? var.max_zones : length(local.availability_zones)
}


# Create public subnets
resource "azurerm_subnet" "public" {
  count                = length(local.public_prefixes)
  name                 = "publicSubnet${count.index + 1}"
  resource_group_name  = azurerm_virtual_network.main.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [element(local.public_prefixes, count.index)]
  /*service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "publicSubnetDelegation"
    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      ]
    }
  }*/
  # Use randomized availability zones
  depends_on = [random_shuffle.az]
}

# Create private subnets
resource "azurerm_subnet" "private" {
  count                = length(local.private_prefixes)
  name                 = "privateSubnet${count.index + 1}"
  resource_group_name  = azurerm_virtual_network.main.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [element(local.private_prefixes, count.index)]
  /*service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "privateSubnetDelegation"
    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      ]
    }
  }*/
  # Use randomized availability zones
  depends_on = [random_shuffle.az]
}
