resource "azurerm_resource_group" "tutorial" {
  name     = "${var.project}-${var.environment}-rg"
  location = var.location
  tags = local.tags
}

resource "azurerm_virtual_network" "tutorial" {
  name                = "tutorial-vnet"
  resource_group_name = azurerm_resource_group.tutorial.name
  location            = azurerm_resource_group.tutorial.location
  address_space       = ["172.16.0.0/16"]
}

resource "azurerm_subnet" "tutorial" {
  name                 = "tutorial-subnet"
  resource_group_name  = azurerm_resource_group.tutorial.name
  virtual_network_name = azurerm_virtual_network.tutorial.name
  address_prefixes     = ["172.16.1.0/24"]
}