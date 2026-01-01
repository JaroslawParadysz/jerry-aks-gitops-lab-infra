terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Backend configuration for storing Terraform state in Azure Storage
  # Values will be injected during terraform init from:
  # - GitHub Secrets (in CI/CD pipeline)
  # - Command-line flags (for local development)
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}

  # Authentication will be handled by:
  # - Azure CLI for local development
  # - Service Principal from GitHub Secrets for CI/CD
}
