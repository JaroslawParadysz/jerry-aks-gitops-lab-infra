output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.aks_rg.name
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.aks_vnet.id
}

#output "aks_cluster_name" {
#  description = "The name of the AKS cluster"
#  value       = azurerm_kubernetes_cluster.aks.name
#}
#
#output "aks_cluster_id" {
#  description = "The ID of the AKS cluster"
#  value       = azurerm_kubernetes_cluster.aks.id
#}
#
#output "aks_kubeconfig" {
#  description = "Kubeconfig for the AKS cluster"
#  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
#  sensitive   = true
#}
#
#output "aks_cluster_fqdn" {
#  description = "The FQDN of the AKS cluster"
#  value       = azurerm_kubernetes_cluster.aks.fqdn
#}
