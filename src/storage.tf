resource "azurerm_storage_account" "aks_queue_storage" {
  name                     = "${var.customer_name}-sa-${var.module_name}-${var.env_name}"
  resource_group_name      = azurerm_resource_group.aks_rg.name
  location                 = azurerm_resource_group.aks_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = {
    Environment = var.env_name
    ManagedBy   = "Terraform"
    Project     = "AKS-GitOps"
    Customer    = var.customer_name
    Module      = var.module_name
  }
}

resource "azurerm_storage_queue" "orchestrator" {
  name                 = var.queue_name
  storage_account_name = azurerm_storage_account.aks_queue_storage.name
}

resource "azurerm_user_assigned_identity" "aks_queue_identity" {
  name                = "${var.customer_name}-mi-aks-queue-${var.env_name}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  tags = {
    Environment = var.env_name
    ManagedBy   = "Terraform"
    Project     = "AKS-GitOps"
    Customer    = var.customer_name
    Module      = var.module_name
  }
}

resource "azurerm_role_assignment" "aks_queue_data_reader" {
  scope                = "${azurerm_storage_account.aks_queue_storage.id}/queueServices/default/queues/${azurerm_storage_queue.orchestrator.name}"
  role_definition_name = "Storage Queue Data Reader"
  principal_id         = azurerm_user_assigned_identity.aks_queue_identity.principal_id
}

resource "azurerm_role_assignment" "aks_queue_data_message_processor" {
  scope                = "${azurerm_storage_account.aks_queue_storage.id}/queueServices/default/queues/${azurerm_storage_queue.orchestrator.name}"
  role_definition_name = "Storage Queue Data Message Processor"
  principal_id         = azurerm_user_assigned_identity.aks_queue_identity.principal_id
}

resource "azurerm_role_assignment" "aks_blob_data_contributor" {
  scope                = azurerm_storage_account.aks_queue_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_queue_identity.principal_id
}

resource "azurerm_role_assignment" "aks_file_data_privileged_contributor" {
  scope                = azurerm_storage_account.aks_queue_storage.id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_queue_identity.principal_id
}
