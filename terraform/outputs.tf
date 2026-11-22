########################################
# Outputs — Atlas-08
########################################

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.infra.resource_group_name
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = module.infra.acr_login_server
}

output "acr_name" {
  description = "ACR name"
  value       = module.infra.acr_name
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.infra.aks_cluster_name
}