#!/bin/bash

set -e

# ==================================================
# Default Configuration
# ==================================================

DEFAULT_IMAGE_NAME="github_actions_demo-runner-image"
DEFAULT_IMAGE_TAG="latest"
DEFAULT_CONTAINER_NAME="github_actions_demo-runner-container"

ENV_FILE=".env"
DOCKERFILE="Dockerfile"

# ==================================================
# Read Parameters
# ==================================================

IMAGE="${1:-${DEFAULT_IMAGE_NAME}:${DEFAULT_IMAGE_TAG}}"
CONTAINER_NAME="${2:-${DEFAULT_CONTAINER_NAME}}"

# ==================================================
# Display Configuration
# ==================================================

echo "=========================================="
echo " Docker Build & Run"
echo "=========================================="

echo "Image      : $IMAGE"
echo "Container  : $CONTAINER_NAME"
echo "Dockerfile : $DOCKERFILE"
echo "Env File   : $ENV_FILE"

echo ""

# ==================================================
# Validate .env
# ==================================================

if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: $ENV_FILE file not found."
    exit 1
fi

# ==================================================
# Validate Dockerfile
# ==================================================

if [ ! -f "$DOCKERFILE" ]; then
    echo "ERROR: $DOCKERFILE file not found."
    exit 1
fi

# ==================================================
# Check Docker Image
# ==================================================

echo "=========================================="
echo " Checking Docker Image"
echo "=========================================="

if docker image inspect "$IMAGE" > /dev/null 2>&1; then

    echo "Docker image already exists:"
    echo "  $IMAGE"
    echo "Skipping image build."

else

    echo "Docker image not found:"
    echo "  $IMAGE"

    echo ""
    echo "=========================================="
    echo " Building Docker Image"
    echo "=========================================="

    docker build \
        -f "$DOCKERFILE" \
        -t "$IMAGE" \
        .

    echo ""
    echo "=========================================="
    echo " Docker Image Build Successful"
    echo "=========================================="

fi

echo ""

# ==================================================
# Remove Existing Container
# ==================================================

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then

    echo "=========================================="
    echo " Removing Existing Container"
    echo "=========================================="

    echo "Container: $CONTAINER_NAME"

    docker rm -f "$CONTAINER_NAME"

    echo "Existing container removed."

fi

# ==================================================
# Start Container
# ==================================================

echo ""
echo "=========================================="
echo " Starting Docker Container"
echo "=========================================="

docker run \
    --rm \
    -it \
    --name "$CONTAINER_NAME" \
    --env-file "$ENV_FILE" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    "$IMAGE"