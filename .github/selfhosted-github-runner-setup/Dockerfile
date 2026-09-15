# ==================================================
# GitHub Actions Self-Hosted Runner
# .NET 10 + Docker Buildx
# ==================================================

FROM ubuntu:24.04

# --------------------------------------------------
# Environment
# --------------------------------------------------

ENV DEBIAN_FRONTEND=noninteractive
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${PATH}:${DOTNET_ROOT}"

# --------------------------------------------------
# Build arguments
# --------------------------------------------------

ARG LINUX_USER_NAME="ubuntu"
ARG LINUX_GROUP_NAME="users"
ARG TIMEZONE="Asia/Kolkata"

# --------------------------------------------------
# Install required packages
# --------------------------------------------------

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        unzip \
        tzdata \
        docker.io \
        libicu74 \
        libssl3t64 \
        libstdc++6 \
        zlib1g \
        libunwind8 \
        libkrb5-3 \
        libgssapi-krb5-2 \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# Install .NET 10 SDK
# --------------------------------------------------

RUN curl -fL \
        https://dot.net/v1/dotnet-install.sh \
        -o /tmp/dotnet-install.sh && \
    chmod +x /tmp/dotnet-install.sh && \
    /tmp/dotnet-install.sh \
        --channel 10.0 \
        --install-dir /usr/share/dotnet && \
    ln -sf /usr/share/dotnet/dotnet /usr/local/bin/dotnet && \
    rm -f /tmp/dotnet-install.sh

# --------------------------------------------------
# Create runner user
# --------------------------------------------------

RUN groupadd -f ${LINUX_GROUP_NAME} && \
    id -u ${LINUX_USER_NAME} >/dev/null 2>&1 || \
    useradd \
        -m \
        -g ${LINUX_GROUP_NAME} \
        -s /bin/bash \
        ${LINUX_USER_NAME}

# --------------------------------------------------
# Docker socket access
# --------------------------------------------------

RUN usermod -aG docker ${LINUX_USER_NAME}

# --------------------------------------------------
# Configure timezone
# --------------------------------------------------

RUN ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone

# --------------------------------------------------
# GitHub Actions Runner setup script
# --------------------------------------------------

COPY setup-runner.sh /usr/local/bin/setup-runner.sh

RUN chmod +x /usr/local/bin/setup-runner.sh

# --------------------------------------------------
# Runner home
# --------------------------------------------------

RUN mkdir -p /home/${LINUX_USER_NAME}/runner && \
    chown -R \
        ${LINUX_USER_NAME}:${LINUX_GROUP_NAME} \
        /home/${LINUX_USER_NAME}

WORKDIR /home/${LINUX_USER_NAME}

# --------------------------------------------------
# Run as normal user
# --------------------------------------------------

USER ${LINUX_USER_NAME}

ENTRYPOINT ["/usr/local/bin/setup-runner.sh"]
