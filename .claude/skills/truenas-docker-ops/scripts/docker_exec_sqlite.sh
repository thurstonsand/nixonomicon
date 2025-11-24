#!/bin/bash
# Execute SQLite queries inside a Docker container on TrueNAS server
# Usage: docker_exec_sqlite.sh <container_name> <db_path> <sql_query>

set -euo pipefail

if [ $# -ne 3 ]; then
    echo "Usage: $0 <container_name> <db_path> <sql_query>" >&2
    echo "Example: $0 anypod /data/db/anypod.db 'SELECT * FROM feed;'" >&2
    exit 1
fi

CONTAINER_NAME="$1"
DB_PATH="$2"
SQL_QUERY="$3"

# Execute SQLite query in container via Python (since sqlite3 CLI may not be available)
# This approach works universally since Python is always available in the containers
PYTHON_CODE=$(cat <<EOF
import sqlite3, json, sys
try:
    conn = sqlite3.connect("${DB_PATH}")
    conn.row_factory = sqlite3.Row
    result = conn.execute("""${SQL_QUERY}""").fetchall()
    if result:
        for row in result:
            print(json.dumps(dict(row)))
    conn.close()
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
EOF
)

echo "$PYTHON_CODE" | ssh truenas docker exec -i "${CONTAINER_NAME}" /app/.venv/bin/python -
