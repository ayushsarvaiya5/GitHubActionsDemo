#!/bin/bash

set -e

echo "=========================================="
echo " GitHub Actions Runner Setup"
echo "=========================================="

# --------------------------------------------------
# Validate environment variables
# --------------------------------------------------

required_vars=(
    GITHUB_URL
    GITHUB_TOKEN
    RUNNER_NAME
    RUNNER_LABELS
    RUNNER_VERSION
    RUNNER_ARCH
    RUNNER_WORK_FOLDER
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "ERROR: $var is not set."
        exit 1
    fi
done

# --------------------------------------------------
# Runner directory
# --------------------------------------------------

RUNNER_DIR="$HOME/runner"

mkdir -p "$RUNNER_DIR"

cd "$RUNNER_DIR"

# --------------------------------------------------
# Runner package
# --------------------------------------------------

RUNNER_PACKAGE="actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz"

RUNNER_DOWNLOAD_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_PACKAGE}"

# --------------------------------------------------
# Download runner
# --------------------------------------------------

if [ ! -f "$RUNNER_PACKAGE" ]; then

    echo "Downloading GitHub Actions Runner..."
    echo "Version : $RUNNER_VERSION"
    echo "Arch    : $RUNNER_ARCH"

    curl -fL \
        -o "$RUNNER_PACKAGE" \
        "$RUNNER_DOWNLOAD_URL"

else

    echo "Runner package already exists."

fi

# --------------------------------------------------
# Extract runner
# --------------------------------------------------

if [ ! -f "./config.sh" ]; then

    echo "Extracting runner..."

    tar xzf "$RUNNER_PACKAGE"

else

    echo "Runner already extracted."

fi

# --------------------------------------------------
# Remove previous configuration
# --------------------------------------------------

echo "Removing previous runner configuration..."

rm -f .runner
rm -f .credentials
rm -f .credentials_rsaparams

# --------------------------------------------------
# Configure GitHub Runner
# --------------------------------------------------

echo "=========================================="
echo " Configuring Runner"
echo "=========================================="

echo "Repository : $GITHUB_URL"
echo "Runner     : $RUNNER_NAME"
echo "Labels     : $RUNNER_LABELS"

./config.sh \
    --unattended \
    --url "$GITHUB_URL" \
    --token "$GITHUB_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work "$RUNNER_WORK_FOLDER" \
    --replace

# --------------------------------------------------
# Start runner
# --------------------------------------------------

echo "=========================================="
echo " Starting GitHub Actions Runner"
echo "=========================================="

./run.sh