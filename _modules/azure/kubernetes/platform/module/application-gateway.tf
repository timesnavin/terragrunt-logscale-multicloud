# Use existing virtual network
data "azurerm_virtual_network" "main" {
  #name                 = module.vnet.name
  name                 = var.name 
  resource_group_name  = var.resource_group_name
  
}

# Create the Application Gateway Subet
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "logscale-appgw-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.main.name
  address_prefixes     = [var.appgw_subnet_prefix]
}

# Create a Public IP for the Application Gateway
resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "${var.application_gateway_name}-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Define the Application Gateway

resource "azurerm_application_gateway" "appgw" {
  name                = var.application_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location


  sku {
    name     = "WAF_v2"  # For enabling WAF_v2 a valid WAF policy or configuration needs to be provided
    tier     = "WAF_v2"
    capacity = 2
  }

  waf_configuration {
    enabled = "true"
    firewall_mode = "Detection"
    rule_set_type = "OWASP"
    rule_set_version = "3.2"
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = "httpPort"
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
  }

  backend_address_pool {
    name = "appGatewayBackendPool"
  }

  backend_http_settings {
    name                  = "appGatewayBackendHttpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    pick_host_name_from_backend_address = false
    probe_name = "appGatewayProbe"
  }

  http_listener {
    name                           = "appGatewayHttpListener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "httpPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "appGatewayRoutingRule"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "appGatewayHttpListener"
    backend_address_pool_name  = "appGatewayBackendPool"
    backend_http_settings_name = "appGatewayBackendHttpSettings"
  }
 
 probe {
   name = "appGatewayProbe"
   protocol = "Http"
   host = "127.0.0.1"
   path = "/"
   interval = 30
   timeout = 30
   unhealthy_threshold = 3
   match {
     body = ""
     status_code = ["200-399"]
   }
   pick_host_name_from_backend_http_settings = false
 }
 
 tags = {
   Environment = "Production"
 }
}

# Output the Application Gateway ID
output "application_gateway_id" {
  value = azurerm_application_gateway.appgw.id
  
}