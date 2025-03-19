# Python Runner

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/mantis-software-company/python-runner/docker-build.yml)

A flexible Docker-based Python runner that simplifies deployment and execution of Python applications with configurable environments.

## Available Images

Three variants are provided to suit different needs:

- **Regular** (`mantissoftware/python-runner:[version]`): Based on the official Python image, includes typical packages for general use.
- **Slim** (`mantissoftware/python-runner:[version]-slim`): Based on python:[version]-slim, smaller size with minimal dependencies.
- **Lite** (`mantissoftware/python-runner:[version]-lite`): Based on python:[version]-alpine, ultra-lightweight for minimal deployments.

Replace `[version]` with a Python version like `3.12`.

## Features

- Creates a Python virtual environment automatically
- Supports installation of packages from custom repositories
- Installs OS-level dependencies on demand
- Provides development tools when needed
- Configurable startup commands
- Support for pre-start and post-start scripts

## Environment Variables

### Package Installation

| Variable | Description | Example |
|----------|-------------|---------|
| `REQUIREMENTS_PACKAGES` | Space-separated list of packages to install.  Usable when third party tools/libraries is required but they're not dependency of main package. | `"numpy pandas requests"` |
| `PACKAGE_NAME` | Main package to install | `"flask"` |
| `PACKAGE_VERSION` | Version of the main package (Optional). Latest available version will install when  not specified. | `"2.0.1"` |
| `UPDATE_PIP` | Update pip before run (default: true) | `"false"` |

### Repository Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `REPOSITORY_URL` | URL of custom PyPI repository | `"https://pypi.mycompany.com"` |
| `REPOSITORY_HOST` | Host of custom PyPI repository | `"pypi.mycompany.com"` |

### System Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `OS_DEPENDENCIES` | Space-separated list of system packages to install. | `"curl git"` |
| `INSTALL_DEV_TOOLS` | Whether to install build tools. Use it  (default: false) | `"true"` |

### Execution Control

| Variable | Description | Example |
|----------|-------------|---------|
| `STARTUP_COMMAND` | Command to execute | `"flask"` or `"python app.py"` |
| `PRE_START_SCRIPT` | Path to script to run before startup | `"/app/pre_start.sh"` |
| `POST_START_SCRIPT` | Path to script to run after startup | `"/app/post_start.sh"` |

## Usage Examples

### Simple Run
```bash
docker run -it --rm mantissoftware/python-runner:3.12 \
-e REQUIREMENTS_PACKAGES="requests" \
-e STARTUP_COMMAND="python"
```

### Run a Flask Application
```yaml
version: '3'

services:
  web:
    image: mantissoftware/python-runner:3.12-slim
    environment:
      - REQUIREMENTS_PACKAGES=flask gunicorn
      - STARTUP_COMMAND=gunicorn -b 0.0.0.0:5000 app:app
    ports:
      - "5000:5000"
    volumes:
      - ./:/app/src
    working_dir: /app/src
```

### Data Science Environment
```yaml
version: '3'

services:
  jupyter:
    image: mantissoftware/python-runner:3.12
    environment:
      - REQUIREMENTS_PACKAGES=jupyter pandas matplotlib scikit-learn
      - STARTUP_COMMAND=jupyter notebook --ip=0.0.0.0 --no-browser --allow-root
      - INSTALL_DEV_TOOLS=true
    ports:
      - "8888:8888"
    volumes:
      - ./notebooks:/app/notebooks
    working_dir: /app/notebooks
```
## Building Locally
To build the images locally:
```bash
# Set Python version
PYTHON_VERSION=3.12

# Regular image
docker build -t python-runner:${PYTHON_VERSION} \
  -f Dockerfile-regular \
  --build-arg PYTHON_VERSION=${PYTHON_VERSION} .

# Slim image
docker build -t python-runner:${PYTHON_VERSION}-slim \
  -f Dockerfile-slim \
  --build-arg PYTHON_VERSION=${PYTHON_VERSION} .

# Lite image
docker build -t python-runner:${PYTHON_VERSION}-lite \
  -f Dockerfile-lite \
  --build-arg PYTHON_VERSION=${PYTHON_VERSION} .
```

## How It Works

The container starts and installs any requested OS dependencies

1. A virtual environment is created in /app/venv
2. Pip is configured for custom repositories if needed
3. Required packages are installed
4. Pre-start script is executed (if specified)
5. The startup command or package is executed
6. Post-start script is executed (if specified)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
