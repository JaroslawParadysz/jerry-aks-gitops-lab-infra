output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.aks_rg.name
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.vnet.vnet_id
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_kubeconfig" {
  description = "Kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "automation_account_name" {
  description = "The name of the Azure Automation Account"
  value       = azurerm_automation_account.aks_automation.name
}

output "stop_schedule" {
  description = "AKS stop schedule"
  value       = "Daily at 10 PM (W. Europe Time)"
}

output "start_runbook" {
  description = "Manual start runbook"
  value       = "Use Azure Portal or CLI to manually trigger Start-AKSCluster runbook"
}
