# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.71.0"
    }
  }

  required_version = ">= 1.1.0"
  backend "azurerm" {}

}

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "rg" {
  name     = "snowy-rg"
  location = var.location-rg
  tags = {
    "Application" = "DemoApp"
  }
}