const fs = require('fs');
const os = require('os');
const path = require('path');
const { Pool } = require('pg');

function loadEnvFile() {
  const envPath = path.join(__dirname, '.env');

  if (!fs.existsSync(envPath)) {
    return;
  }

  const contents = fs.readFileSync(envPath, 'utf8');

  for (const rawLine of contents.split(/\r?\n/)) {
    const line = rawLine.trim();

    if (!line || line.startsWith('#')) {
      continue;
    }

    const separatorIndex = line.indexOf('=');

    if (separatorIndex === -1) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    let value = line.slice(separatorIndex + 1).trim();

    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }

    if (!(key in process.env)) {
      process.env[key] = value;
    }
  }
}

loadEnvFile();

const pool = new Pool({
  user: process.env.DB_USER || os.userInfo().username,
  password: process.env.DB_PASSWORD || undefined,
  host: process.env.DB_HOST || '/tmp',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'ehotels',
});

module.exports = pool;
