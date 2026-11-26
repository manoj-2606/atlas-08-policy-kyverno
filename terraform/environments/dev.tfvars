########################################
# Dev Environment — Atlas-08
########################################

environment            = "dev"
location               = "centralindia"
aks_kubernetes_version = "1.36.5"
aks_node_count         = 1
aks_node_size          = "Standard_B2s"
os_disk_size_gb        = 30

tags = {
  project     = "atlas-08-policy-kyverno"
  environment = "dev"
  team        = "platform"
  cost-center = "atlas-learning"
  created-by  = "terraform"
  managed-by  = "azure-devops"
  destroy-by  = "end-of-day"
}