#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:-ehotels_d2}"
psql -v ON_ERROR_STOP=1 -d "${DB_NAME}" -f sql/04_queries.sql
