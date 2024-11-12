# Create child DNS Zone
resource "azurerm_dns_zone" "child_zone" {
  name                 = "${var.child_domain}.${var.parent_domain}"
  resource_group_name  = var.resource_group_name

  tags                 = var.tags
}


# Retrieve parent DNS Zone

data "azurerm_dns_zone" "parent_zone" {
  name = "${var.parent_domain}."
  resource_group_name = var.parent.resource_group_name
}

# Delegate the Child zone
resource "azurerm_dns_ns_record" "child_zone_delegation" {
  name                 = var.child_domain
  zone_name            = data.azurerm_dns_zone.parent_zone.name
  resource_group_name  = data.azurerm_dns_zone.parent_zone.resource_group_name
  ttl                  = 600
  records              = azurerm_dns_zone.child_zone_servers

  tags                 = var.tags
}