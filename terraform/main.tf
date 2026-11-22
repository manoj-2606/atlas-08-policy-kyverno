########################################
# Atlas-08: Policy Enforcement with Kyverno
# Terraform Root Module
########################################

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-atlas-tfstate"
    storage_account_name = "atlastfstate2606"
    container_name       = "tfstate"
    key                  = "atlas-08.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

module "infra" {
  source = "git::https://github.com/manoj-2606/atlas-infra-base.git"

  project_name           = "atlas-08"
  environment            = var.environment
  location               = var.location
  aks_kubernetes_version = var.aks_kubernetes_version
  aks_node_count         = var.aks_node_count
  aks_node_size          = var.aks_node_size
  os_disk_size_gb        = var.os_disk_size_gb
  tags                   = var.tags
}