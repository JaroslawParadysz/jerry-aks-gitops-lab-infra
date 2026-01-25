variable "name" {
  description = "Name of the virtual network"
  type        = string
}

variable "location" {
  description = "Azure region for the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets to create within the virtual network"
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the virtual network and subnets"
  type        = map(string)
  default     = {}
}
