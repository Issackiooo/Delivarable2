#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:-ehotels_d2}"
PORT="${EHOTELS_PORT:-8080}"

mkdir -p app/out
javac -d app/out app/src/*.java
exec env EHOTELS_DB="${DB_NAME}" EHOTELS_PORT="${PORT}" java -cp app/out EHotelsServer
