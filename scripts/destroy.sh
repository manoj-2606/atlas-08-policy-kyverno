#!/bin/bash
########################################
# Destroy infrastructure — Atlas-08
########################################
set -euo pipefail

echo "=== Atlas-08: Destroy ==="

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

echo "--- Terraform Destroy ---"
terraform destroy \
  -var-file="environments/dev.tfvars" \
  -auto-approve

echo "=== Destroy complete ==="