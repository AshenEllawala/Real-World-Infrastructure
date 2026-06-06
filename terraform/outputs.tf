output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.main.name
  description = "AKS cluster name"
}

output "container_registry_name" {
  value       = azurerm_container_registry.main.name
  description = "Container Registry name"
}

output "container_registry_login_server" {
  value       = azurerm_container_registry.main.login_server
  description = "Container Registry login server"
}

output "postgresql_fqdn" {
  value       = azurerm_postgresql_flexible_server.main.fqdn
  description = "PostgreSQL server FQDN"
}

output "db_password" {
  value       = random_password.db_password.result
  sensitive   = true
  description = "Database password (save this!)"
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
  description = "Kubernetes config for kubectl"
}
