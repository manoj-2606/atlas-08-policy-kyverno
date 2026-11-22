#!/bin/bash
########################################
# Build, scan, push container image — Atlas-08
# Multi-repo checkout: app at atlas-platform-app/
# Vendor approach for pip wheels
########################################
set -euo pipefail

echo "=== Atlas-08: Build ==="

ACR_SERVER="$1"
ACR_NAME="$2"
RG_NAME="$3"
BUILD_ID="$4"

# Multi-repo checkout path
SELF_DIR="${BUILD_SOURCESDIRECTORY}/atlas-08-policy-kyverno"
APP_DIR="${BUILD_SOURCESDIRECTORY}/atlas-platform-app"
IMAGE_NAME="atlas-platform-app"
IMAGE_TAG="${ACR_SERVER}/${IMAGE_NAME}:${BUILD_ID}"

echo "--- Vendor pip wheels ---"
cd "${APP_DIR}"
mkdir -p vendor
pip download \
  -r requirements.txt \
  -d vendor/ \
  --python-version 312 \
  --implementation cp \
  --abi cp312 \
  --platform manylinux2014_x86_64 \
  --only-binary=:all: \
  -i https://pypi.tuna.tsinghua.edu.cn/simple/ || \
pip download \
  -r requirements.txt \
  -d vendor/ \
  --no-binary=:all: \
  -i https://pypi.tuna.tsinghua.edu.cn/simple/

echo "--- Copy Dockerfile ---"
cp "${SELF_DIR}/Dockerfile" "${APP_DIR}/Dockerfile"

echo "--- Docker build ---"
cd "${APP_DIR}"
docker build -t "${IMAGE_TAG}" .

echo "--- Trivy scan ---"
trivy image \
  --severity HIGH,CRITICAL \
  --exit-code 0 \
  --format table \
  "${IMAGE_TAG}"

echo "--- SBOM generation ---"
trivy image \
  --format cyclonedx \
  --output "${SELF_DIR}/sbom.json" \
  "${IMAGE_TAG}"

echo "--- Push to ACR ---"
az acr login --name "${ACR_NAME}"
docker push "${IMAGE_TAG}"

echo "=== Build complete: ${IMAGE_TAG} ==="