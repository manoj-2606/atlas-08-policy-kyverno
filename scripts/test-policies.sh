#!/bin/bash
########################################
# Negative testing — Atlas-08
# Tests that bad pods are BLOCKED by Kyverno
# Tests that good pods are ADMITTED
# Tests generate policy creates NetworkPolicy
########################################
set -euo pipefail

echo "=== Atlas-08: Policy Tests ==="

AKS_NAME="$1"
RG_NAME="$2"

# Get AKS credentials
az aks get-credentials \
  --resource-group "${RG_NAME}" \
  --name "${AKS_NAME}" \
  --overwrite-existing

SELF_DIR="${BUILD_SOURCESDIRECTORY}"
PASS=0
FAIL=0

# Create dev namespace for tests
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

# --- NEGATIVE TESTS: These MUST fail ---
echo ""
echo "========== NEGATIVE TESTS =========="
echo "Bad pods should be BLOCKED by Kyverno"
echo ""

BAD_TESTS=(
  "bad-no-limits:require-resource-limits"
  "bad-latest-tag:disallow-latest-tag"
  "bad-root-user:require-non-root"
  "bad-no-labels:require-labels"
)

for TEST_ENTRY in "${BAD_TESTS[@]}"; do
  TEST_NAME="${TEST_ENTRY%%:*}"
  POLICY="${TEST_ENTRY##*:}"

  echo "--- Test: ${TEST_NAME} (should be blocked by ${POLICY}) ---"
  set +e
  OUTPUT=$(kubectl apply -f "${SELF_DIR}/tests/${TEST_NAME}.yaml" 2>&1)
  EXIT_CODE=$?
  set -e

  if [ $EXIT_CODE -ne 0 ]; then
    echo "  PASS ✓ — Correctly blocked (exit code: ${EXIT_CODE})"
    echo "  Reason: ${OUTPUT}" | head -3
    PASS=$((PASS + 1))
  else
    echo "  FAIL ✗ — Pod was admitted (should have been blocked!)"
    kubectl delete pod "${TEST_NAME}" -n dev --ignore-not-found
    FAIL=$((FAIL + 1))
  fi
  echo ""
done

# --- POSITIVE TEST: This MUST succeed ---
echo "========== POSITIVE TEST =========="
echo "Good pod should be ADMITTED"
echo ""

echo "--- Test: good-compliant (should be admitted) ---"
set +e
OUTPUT=$(kubectl apply -f "${SELF_DIR}/tests/good-compliant.yaml" 2>&1)
EXIT_CODE=$?
set -e

if [ $EXIT_CODE -eq 0 ]; then
  echo "  PASS ✓ — Correctly admitted"
  PASS=$((PASS + 1))
  kubectl delete pod good-compliant -n dev --ignore-not-found
else
  echo "  FAIL ✗ — Pod was blocked (should have been admitted!)"
  echo "  Reason: ${OUTPUT}" | head -3
  FAIL=$((FAIL + 1))
fi

# --- GENERATE POLICY TEST ---
echo ""
echo "========== GENERATE POLICY TEST =========="
echo "New namespace should auto-get NetworkPolicy"
echo ""

TEST_NS="test-mutate-$(date +%s)"
echo "--- Creating namespace: ${TEST_NS} ---"
kubectl create namespace "${TEST_NS}"
sleep 5

echo "--- Checking for generated NetworkPolicy ---"
set +e
NP=$(kubectl get networkpolicy default-deny-ingress -n "${TEST_NS}" -o name 2>&1)
EXIT_CODE=$?
set -e

if [ $EXIT_CODE -eq 0 ] && [ -n "$NP" ]; then
  echo "  PASS ✓ — NetworkPolicy auto-generated"
  PASS=$((PASS + 1))
else
  echo "  FAIL ✗ — NetworkPolicy not found"
  FAIL=$((FAIL + 1))
fi

# Cleanup test namespace
kubectl delete namespace "${TEST_NS}" --ignore-not-found

# --- RESULTS ---
echo ""
echo "========================================"
echo "  TEST RESULTS: ${PASS} passed, ${FAIL} failed"
echo "========================================"

if [ $FAIL -gt 0 ]; then
  echo "ERROR: ${FAIL} test(s) failed!"
  exit 1
fi

echo "=== All tests passed ==="