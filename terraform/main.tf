provider "aws" {
  region                  = var.region
  shared_credentials_file = "~/.aws/credentials"
}

#-----------network module-----------------
module "network" {
  source       = "./modules/network"
  env          = var.env
  region       = var.region
  vpc_cidr     = var.vpc_cidr
  subnet_cidrs = var.subnet_cidrs
}

#-----------ec2 module-------------
module "ec2" {
  source = "./modules/ec2"
  env    = var.env
  region = var.region

  instance_type = var.instance_type
  volume_size   = var.volume_size

  vpc_id_test    = module.network.vpc_id_test
  subnet_id_test = module.network.subnet_id_test
}






# resource "azurerm_resource_group" "tutorial" {
#   name     = "${var.project}-${var.environment}-rg"
#   location = var.location
#   tags = local.tags
# }
#
# resource "azurerm_virtual_network" "tutorial" {
#   name                = "tutorial-vnet"
#   resource_group_name = azurerm_resource_group.tutorial.name
#   location            = azurerm_resource_group.tutorial.location
#   address_space       = ["172.16.0.0/16"]
# }
#
# resource "azurerm_subnet" "tutorial" {
#   name                 = "tutorial-subnet"
#   resource_group_name  = azurerm_resource_group.tutorial.name
#   virtual_network_name = azurerm_virtual_network.tutorial.name
#   address_prefixes     = ["172.16.1.0/24"]
# }