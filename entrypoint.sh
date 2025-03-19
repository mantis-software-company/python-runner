#!/bin/bash
set -e

# Detect OS type for package installation
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_TYPE=$ID
else
    # Default to debian if can't detect
    OS_TYPE="debian"
fi

# Install OS dependencies if specified
if [[ -n "$OS_DEPENDENCIES" ]]; then
    echo "Installing OS dependencies: $OS_DEPENDENCIES"
    if [[ "$OS_TYPE" == "alpine" ]]; then
        apk add --no-cache $OS_DEPENDENCIES
    else
        apt-get update && apt-get install -y --no-install-recommends $OS_DEPENDENCIES && rm -rf /var/lib/apt/lists/*
    fi
fi

# Install development tools if requested
if [[ "${INSTALL_DEV_TOOLS}" == "true" ]]; then
    echo "Installing development tools"
    if [[ "$OS_TYPE" == "alpine" ]]; then
        apk add --no-cache build-base linux-headers
    else
        apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*
    fi
fi

# Create virtualenv
python -m venv /app/venv

# Configure pip if repository info provided
if [[ -n "$REPOSITORY_URL" && -n "$REPOSITORY_HOST" ]]; then
    cat > /app/venv/pip.conf << EOF
[global]
index = ${REPOSITORY_URL}/
index-url = ${REPOSITORY_URL}/simple
trusted-host = ${REPOSITORY_HOST}
EOF
fi

# Update pip if needed (default is true)
if [[ "${UPDATE_PIP:-true}" != "false" ]]; then
    /app/venv/bin/pip install --upgrade pip
fi

# Install requirements packages if specified
if [[ -n "$REQUIREMENTS_PACKAGES" ]]; then
    /app/venv/bin/pip install $REQUIREMENTS_PACKAGES
fi

# Install specified package
if [[ -n "$PACKAGE_NAME" ]]; then
    if [[ -n "$PACKAGE_VERSION" ]]; then
        /app/venv/bin/pip install "${PACKAGE_NAME}==${PACKAGE_VERSION}"
    else
        /app/venv/bin/pip install "${PACKAGE_NAME}"
    fi
fi

# Run pre-start script if specified
if [[ -n "$PRE_START_SCRIPT" ]]; then
    source "$PRE_START_SCRIPT"
fi

# Run startup command or package
if [[ -n "$STARTUP_COMMAND" ]]; then
    exec /app/venv/bin/$STARTUP_COMMAND
elif [[ -n "$PACKAGE_NAME" ]]; then
    exec /app/venv/bin/$PACKAGE_NAME
else
    echo "Error: Neither STARTUP_COMMAND nor PACKAGE_NAME specified"
    exit 1
fi

# Run post-start script if specified
if [[ -n "$POST_START_SCRIPT" ]]; then
    source "$POST_START_SCRIPT"
fi 