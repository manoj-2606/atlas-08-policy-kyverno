#!/bin/bash
########################################
# Apply Kyverno policies — Atlas-08
# Single checkout stage
########################################
set -euo pipefail

echo "=== Atlas-08: Apply Policies ==="

AKS_NAME="$1"
RG_NAME="$2"

# Get AKS credentials
az aks get-credentials \
  --resource-group "${RG_NAME}" \
  --name "${AKS_NAME}" \
  --overwrite-existing

SELF_DIR="${BUILD_SOURCESDIRECTORY}"

echo "--- Apply validate policies ---"
kubectl apply -f "${SELF_DIR}/policies/validate/"
echo ""

echo "--- Apply mutate policies ---"
kubectl apply -f "${SELF_DIR}/policies/mutate/"
echo ""

echo "--- Apply generate policies ---"
kubectl apply -f "${SELF_DIR}/policies/generate/"
echo ""

echo "--- Verify policies ---"
echo "ClusterPolicies:"
kubectl get clusterpolicies
echo ""
echo "Policy status:"
kubectl get clusterpolicies -o custom-columns=NAME:.metadata.name,READY:.status.ready,ACTION:.spec.validationFailureAction

echo "=== Policies applied ==="