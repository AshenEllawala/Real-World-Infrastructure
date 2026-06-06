# ============================================================================
# AKS Cluster
# ============================================================================
resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.app_name}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.app_name}-aks"
  kubernetes_version  = "1.35.4"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_B2s_v2"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  role_based_access_control_enabled = true

  tags = var.tags

  depends_on = [
    azurerm_resource_group.main
  ]
}

# ============================================================================
# Log Analytics Workspace (for AKS monitoring)
# ============================================================================
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.app_name}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# ============================================================================
# Allow AKS to pull from Container Registry
# ============================================================================
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
