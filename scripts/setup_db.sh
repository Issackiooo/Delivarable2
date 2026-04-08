#!/usr/bin/env bash
set -euo pipefail

DB_NAME="${1:-ehotels_d2}"

if ! psql -lqt | awk '{print $1}' | grep -qx "${DB_NAME}"; then
  psql -v ON_ERROR_STOP=1 -d postgres -c "CREATE DATABASE ${DB_NAME};"
fi

psql -v ON_ERROR_STOP=1 -d "${DB_NAME}" -f sql/00_reset.sql
psql -v ON_ERROR_STOP=1 -d "${DB_NAME}" -f sql/01_schema.sql
psql -v ON_ERROR_STOP=1 -d "${DB_NAME}" -f sql/02_indexes_views.sql
psql -v ON_ERROR_STOP=1 -d "${DB_NAME}" -f sql/03_seed.sql

echo "Database ${DB_NAME} is ready."
