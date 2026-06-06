terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

provider "random" {}

data "azurerm_client_config" "current" {}

# ============================================================================
# Resource Group
# ============================================================================
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ============================================================================
# Random Suffix (for unique names)
# ============================================================================
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# ============================================================================
# Random Password (for database)
# ============================================================================
resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ============================================================================
# Container Registry (ACR)
# ============================================================================
resource "azurerm_container_registry" "main" {
  name                = "${var.app_name}registry${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = var.tags
}

# ============================================================================
# PostgreSQL Database
# ============================================================================
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "${var.app_name}-db-${random_integer.suffix.result}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  sku_name               = "B_Standard_B1ms"
  version                = "13"
  storage_mb             = 32768
  administrator_login    = var.db_username
  administrator_password = random_password.db_password.result
  backup_retention_days  = 7
  zone                   = "1"
  tags                   = var.tags
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name             = "AllowAllAzureIps"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
