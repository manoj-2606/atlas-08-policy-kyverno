#!/bin/bash
########################################
# Infrastructure provisioning — Atlas-08
# Runs inside AzureCLI@2 with OIDC
########################################
set -euo pipefail

echo "=== Atlas-08: Infrastructure ==="

# OIDC authentication
export ARM_USE_OIDC=true
export ARM_CLIENT_ID="$servicePrincipalId"
export ARM_TENANT_ID="$tenantId"
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export ARM_OIDC_TOKEN="$idToken"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/../terraform"

cd "$TF_DIR"

echo "--- Terraform Init ---"
terraform init \
  -backend-config="resource_group_name=rg-atlas-tfstate" \
  -backend-config="storage_account_name=atlastfstate2606" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=atlas-08.tfstate" \
  -backend-config="use_oidc=true"

echo "--- Terraform Plan ---"
terraform plan \
  -var-file="environments/dev.tfvars" \
  -out=tfplan

echo "--- Terraform Apply ---"
terraform apply -auto-approve tfplan

# Export outputs for downstream stages
RG_NAME=$(terraform output -raw resource_group_name)
ACR_SERVER=$(terraform output -raw acr_login_server)
ACR_NAME=$(terraform output -raw acr_name)
AKS_NAME=$(terraform output -raw aks_cluster_name)

echo "##vso[task.setvariable variable=RG_NAME;isOutput=true]${RG_NAME}"
echo "##vso[task.setvariable variable=ACR_SERVER;isOutput=true]${ACR_SERVER}"
echo "##vso[task.setvariable variable=ACR_NAME;isOutput=true]${ACR_NAME}"
echo "##vso[task.setvariable variable=AKS_NAME;isOutput=true]${AKS_NAME}"

echo "=== Infrastructure complete ==="
echo "  RG:  ${RG_NAME}"
echo "  ACR: ${ACR_SERVER}"
echo "  AKS: ${AKS_NAME}"