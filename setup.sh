#!/bin/bash
# e-Hotels Database Setup Script
# Usage: bash setup.sh

set -e

if [ -f ".env" ]; then
  set -a
  source ".env"
  set +a
fi

DB_USER="${DB_USER:-$(id -un)}"
DB_NAME="${DB_NAME:-ehotels}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_HOST="${DB_HOST:-}"
DB_PORT="${DB_PORT:-5432}"

export PGUSER="$DB_USER"
export PGDATABASE="$DB_NAME"
export PGPORT="$DB_PORT"

if [ -n "$DB_PASSWORD" ]; then
  export PGPASSWORD="$DB_PASSWORD"
fi

if [ -n "$DB_HOST" ]; then
  export PGHOST="$DB_HOST"
fi

echo "=== e-Hotels Database Setup ==="
echo "Using PostgreSQL role '$DB_USER' on ${DB_HOST:-local socket}:${DB_PORT}"

# Create database (ignore error if exists)
echo "Creating database '$DB_NAME'..."
createdb "$DB_NAME" 2>/dev/null || echo "Database already exists, continuing..."

echo "Running schema.sql..."
psql -d "$DB_NAME" -f sql/schema.sql

echo "Running triggers.sql..."
psql -d "$DB_NAME" -f sql/triggers.sql

echo "Running indexes.sql..."
psql -d "$DB_NAME" -f sql/indexes.sql

echo "Running views.sql..."
psql -d "$DB_NAME" -f sql/views.sql

echo "Running seed.sql..."
psql -d "$DB_NAME" -f sql/seed.sql

echo ""
echo "=== Database setup complete! ==="
echo "Run 'npm start' to start the web server."
