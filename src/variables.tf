variable "customer_name" {
  description = "Customer name for resource naming convention"
  type        = string
  default     = "cantoso"
}

variable "module_name" {
  description = "Module name for resource naming convention"
  type        = string
  default     = "mod"
}

variable "env_name" {
  description = "Environment name for resource naming convention (e.g., dev, staging, prod)"
  type        = string
  default     = "test"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_address" {
  description = "Address prefix for the AKS subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
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

variable "storage_account_name" {
  description = "Optional custom name for the storage account (must be globally unique, lowercase letters and numbers only, 3-24 chars)."
  type        = string
  default     = null

  validation {
    condition     = var.storage_account_name == null || can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 characters, using lowercase letters and numbers only."
  }
}

variable "queue_name" {
  description = "Queue name to create in the storage account"
  type        = string
  default     = "archestrator"
}
