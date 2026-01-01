# Azure Automation Account for AKS Start/Stop
resource "azurerm_automation_account" "aks_automation" {
  name                = "${var.customer_name}-aa-${var.module_name}-${var.env_name}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.env_name
    ManagedBy   = "Terraform"
    Project     = "AKS-GitOps"
    Customer    = var.customer_name
    Module      = var.module_name
  }
}

# Role assignment for Automation Account to manage AKS
resource "azurerm_role_assignment" "automation_aks_contributor" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service Contributor Role"
  principal_id         = azurerm_automation_account.aks_automation.identity[0].principal_id
}

# Runbook to stop AKS cluster
resource "azurerm_automation_runbook" "stop_aks" {
  name                    = "Stop-AKSCluster"
  location                = azurerm_resource_group.aks_rg.location
  resource_group_name     = azurerm_resource_group.aks_rg.name
  automation_account_name = azurerm_automation_account.aks_automation.name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"

  content = <<-EOT
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$true)]
        [string]$ClusterName
    )

    try {
        # Ensures you do not inherit an AzContext in your runbook
        Disable-AzContextAutosave -Scope Process

        # Connect to Azure with system-assigned managed identity
        Connect-AzAccount -Identity

        Write-Output "Stopping AKS cluster: $ClusterName in resource group: $ResourceGroupName"
        
        Stop-AzAksCluster -Name $ClusterName -ResourceGroupName $ResourceGroupName -Force
        
        Write-Output "AKS cluster stopped successfully"
    }
    catch {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
  EOT

  tags = {
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

# Runbook to start AKS cluster
resource "azurerm_automation_runbook" "start_aks" {
  name                    = "Start-AKSCluster"
  location                = azurerm_resource_group.aks_rg.location
  resource_group_name     = azurerm_resource_group.aks_rg.name
  automation_account_name = azurerm_automation_account.aks_automation.name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"

  content = <<-EOT
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$true)]
        [string]$ClusterName
    )

    try {
        # Ensures you do not inherit an AzContext in your runbook
        Disable-AzContextAutosave -Scope Process

        # Connect to Azure with system-assigned managed identity
        Connect-AzAccount -Identity

        Write-Output "Starting AKS cluster: $ClusterName in resource group: $ResourceGroupName"
        
        Start-AzAksCluster -Name $ClusterName -ResourceGroupName $ResourceGroupName
        
        Write-Output "AKS cluster started successfully"
    }
    catch {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
  EOT

  tags = {
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

# Schedule to stop AKS at 10 PM (Central European Time)
resource "azurerm_automation_schedule" "stop_aks_schedule" {
  name                    = "Stop-AKS-10PM"
  resource_group_name     = azurerm_resource_group.aks_rg.name
  automation_account_name = azurerm_automation_account.aks_automation.name
  frequency               = "Day"
  interval                = 1
  timezone                = "W. Europe Standard Time"
  start_time              = timeadd(timestamp(), "24h") # Starts tomorrow
  description             = "Stop AKS cluster daily at 10 PM"

  lifecycle {
    ignore_changes = [start_time]
  }
}

# Link stop schedule to runbook
resource "azurerm_automation_job_schedule" "stop_aks_job" {
  resource_group_name     = azurerm_resource_group.aks_rg.name
  automation_account_name = azurerm_automation_account.aks_automation.name
  schedule_name           = azurerm_automation_schedule.stop_aks_schedule.name
  runbook_name            = azurerm_automation_runbook.stop_aks.name

  parameters = {
    ResourceGroupName = azurerm_resource_group.aks_rg.name
    ClusterName       = azurerm_kubernetes_cluster.aks.name
  }
}
