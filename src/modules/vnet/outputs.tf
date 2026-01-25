output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}

output "vnet_address_space" {
  description = "The address space of the virtual network"
  value       = azurerm_virtual_network.vnet.address_space
}
