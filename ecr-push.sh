#!/usr/bin/env bash
set -euo pipefail

# Usage:
# AWS_REGION=eu-central-1 AWS_ACCOUNT_ID=123456789012 ./ecr-push.sh
# Optional: IMAGE_NAME=todoai IMAGE_TAG=latest

AWS_REGION="${AWS_REGION:?Set AWS_REGION, e.g. eu-central-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:?Set AWS_ACCOUNT_ID from your AWS account}"
IMAGE_NAME="${IMAGE_NAME:-todoai}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
REPOSITORY="${ECR_URI}/${IMAGE_NAME}"

aws sts get-caller-identity >/dev/null

if ! aws ecr describe-repositories \
  --repository-names "${IMAGE_NAME}" \
  --region "${AWS_REGION}" >/dev/null 2>&1; then
  aws ecr create-repository \
    --repository-name "${IMAGE_NAME}" \
    --image-scanning-configuration scanOnPush=true \
    --region "${AWS_REGION}"
fi

aws ecr get-login-password --region "${AWS_REGION}" |
  docker login --username AWS --password-stdin "${ECR_URI}"

docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${REPOSITORY}:${IMAGE_TAG}"
docker push "${REPOSITORY}:${IMAGE_TAG}"

echo "Image pushed: ${REPOSITORY}:${IMAGE_TAG}"
