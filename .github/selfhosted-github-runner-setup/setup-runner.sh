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
    GITHUB_PAT
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
# Derive owner/repo from GITHUB_URL
# --------------------------------------------------

OWNER_REPO="$(echo "$GITHUB_URL" | sed -E 's#^https://github.com/##; s#\.git$##; s#/$##')"

if [[ ! "$OWNER_REPO" =~ ^[^/]+/[^/]+$ ]]; then
    echo "ERROR: Unable to parse owner/repo from GITHUB_URL: $GITHUB_URL"
    exit 1
fi

API_URL="https://api.github.com/repos/${OWNER_REPO}/actions/runners"

# --------------------------------------------------
# Request a short-lived runner registration token
# --------------------------------------------------

echo "Requesting runner registration token..."

GITHUB_TOKEN="$(curl -fsSL \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_PAT}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${API_URL}/registration-token" \
    | jq -r '.token')"

if [ -z "$GITHUB_TOKEN" ] || [ "$GITHUB_TOKEN" = "null" ]; then
    echo "ERROR: Failed to obtain runner registration token."
    exit 1
fi

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

    # curl -4 -fL \
    #     --resolve release-assets.githubusercontent.com:443:185.199.108.133 \
    #     -o "$RUNNER_PACKAGE" \
    #     "$RUNNER_DOWNLOAD_URL"

    curl -fL \
        --retry 3 \
        --connect-timeout 20 \
        -o "$RUNNER_PACKAGE" \
        "$RUNNER_DOWNLOAD_URL"
else

    echo "Runner package already exists."

fi

# --------------------------------------------------
# Extract runner from the package
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
# Discard the registration token now that it's used
# --------------------------------------------------

unset GITHUB_TOKEN

# --------------------------------------------------
# De-register the runner on container stop
# --------------------------------------------------

cleanup() {

    echo "=========================================="
    echo " Stopping GitHub Actions Runner"
    echo "=========================================="

    if [ -n "$RUN_PID" ] && kill -0 "$RUN_PID" 2>/dev/null; then
        kill -TERM "$RUN_PID" 2>/dev/null || true
        wait "$RUN_PID" 2>/dev/null || true
    fi

    echo "Requesting runner removal token..."

    REMOVAL_TOKEN="$(curl -fsSL \
        -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GITHUB_PAT}" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "${API_URL}/remove-token" \
        | jq -r '.token')"

    if [ -n "$REMOVAL_TOKEN" ] && [ "$REMOVAL_TOKEN" != "null" ]; then
        echo "Removing runner registration..."
        ./config.sh remove --token "$REMOVAL_TOKEN" || true
    else
        echo "WARNING: Failed to obtain runner removal token. Skipping remote de-registration."
    fi

    unset GITHUB_PAT
    unset REMOVAL_TOKEN

    echo "Runner de-registered and credentials cleared."
}

trap cleanup EXIT INT TERM

# --------------------------------------------------
# Start runner
# --------------------------------------------------

echo "=========================================="
echo " Starting GitHub Actions Runner"
echo "=========================================="

./run.sh &
RUN_PID=$!

wait "$RUN_PID"
