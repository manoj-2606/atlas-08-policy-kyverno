#!/bin/bash
########################################
# Install Kyverno via Helm — Atlas-08
# B2s-safe resource limits
########################################
set -euo pipefail

echo "=== Atlas-08: Install Kyverno ==="

AKS_NAME="$1"
RG_NAME="$2"
KYVERNO_VERSION="$3"

# Get AKS credentials
az aks get-credentials \
  --resource-group "${RG_NAME}" \
  --name "${AKS_NAME}" \
  --overwrite-existing

# Add Kyverno Helm repo
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

# Install Kyverno with B2s-safe resources
helm upgrade --install kyverno kyverno/kyverno \
  --namespace kyverno \
  --create-namespace \
  --version "${KYVERNO_VERSION}" \
  --set admissionController.replicas=1 \
  --set admissionController.resources.requests.cpu=100m \
  --set admissionController.resources.requests.memory=256Mi \
  --set admissionController.resources.limits.cpu=300m \
  --set admissionController.resources.limits.memory=384Mi \
  --set backgroundController.resources.requests.cpu=50m \
  --set backgroundController.resources.requests.memory=128Mi \
  --set backgroundController.resources.limits.cpu=200m \
  --set backgroundController.resources.limits.memory=256Mi \
  --set cleanupController.resources.requests.cpu=50m \
  --set cleanupController.resources.requests.memory=64Mi \
  --set cleanupController.resources.limits.cpu=100m \
  --set cleanupController.resources.limits.memory=128Mi \
  --set reportsController.resources.requests.cpu=50m \
  --set reportsController.resources.requests.memory=128Mi \
  --set reportsController.resources.limits.cpu=200m \
  --set reportsController.resources.limits.memory=256Mi \
  --wait \
  --timeout 300s

echo "--- Verify Kyverno pods ---"
kubectl get pods -n kyverno
kubectl rollout status deployment -n kyverno --timeout=120s

echo "=== Kyverno installed ==="