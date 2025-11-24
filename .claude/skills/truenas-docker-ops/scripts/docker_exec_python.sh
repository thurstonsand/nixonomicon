#!/bin/bash
# Execute Python code inside a Docker container on TrueNAS server
# Usage: docker_exec_python.sh <container_name> <python_code>

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: $0 <container_name> <python_code>" >&2
    echo "Example: $0 anypod 'import sys; print(sys.version)'" >&2
    exit 1
fi

CONTAINER_NAME="$1"
PYTHON_CODE="$2"

# Execute Python code in container via SSH
# Pass Python code through stdin to avoid nested heredoc escaping issues
echo "$PYTHON_CODE" | ssh truenas docker exec -i "${CONTAINER_NAME}" /app/.venv/bin/python -
