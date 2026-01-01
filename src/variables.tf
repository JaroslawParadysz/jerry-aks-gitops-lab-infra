variable "customer_name" {
  description = "Customer name for resource naming convention"
  type        = string
}

variable "module_name" {
  description = "Module name for resource naming convention"
  type        = string
}

variable "env_name" {
  description = "Environment name for resource naming convention (e.g., dev, staging, prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_name" {
  description = "Name of the AKS subnet"
  type        = string
}

variable "aks_subnet_address" {
  description = "Address prefix for the AKS subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}
