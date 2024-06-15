terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
#     random = {
#       source  = "hashicorp/random"
#       version = "~>3.0"
#     }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-tutorial-rg"
    storage_account_name = "tfstatetutorialstg"
    container_name       = "tfstate"
    key                  = "tftutorial.dev.tfstate"
  }
}

provider "azurerm" {
  features {}
}
