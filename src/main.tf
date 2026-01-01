# Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.customer_name}-rg-${var.module_name}-${var.env_name}"
  location = var.location

  tags = {
    Environment = var.env_name
    ManagedBy   = "Terraform"
    Project     = "AKS-GitOps"
    Customer    = var.customer_name
    Module      = var.module_name
  }
}

# Virtual Network
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.customer_name}-vnet-${var.module_name}-${var.env_name}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = var.vnet_address_space

  tags = {
    Environment = var.env_name
    ManagedBy   = "Terraform"
    Project     = "AKS-GitOps"
    Customer    = var.customer_name
    Module      = var.module_name
  }
}

# Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.customer_name}-snet-${var.module_name}-aks-${var.env_name}"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.aks_subnet_address
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.customer_name}-aks-${var.module_name}-${var.env_name}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${var.customer_name}-${var.module_name}-${var.env_name}"

  default_node_pool {
    name           = "default"
    node_count     = var.aks_node_count
    vm_size        = var.aks_node_vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip    = "10.1.0.10"
  }

  tags = {
    Environment  = var.env_name
    ManagedBy    = "Terraform"
    Project      = "AKS-GitOps"
    Customer     = var.customer_name
    Module       = var.module_name
  }
}
