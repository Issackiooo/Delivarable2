@echo off
setlocal

set DB_NAME=%1
if "%DB_NAME%"=="" set DB_NAME=ehotels_d2

psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='%DB_NAME%'" | findstr /R /C:"1" >nul
if errorlevel 1 (
  psql -v ON_ERROR_STOP=1 -d postgres -c "CREATE DATABASE %DB_NAME%;"
)

psql -v ON_ERROR_STOP=1 -d %DB_NAME% -f sql/00_reset.sql
psql -v ON_ERROR_STOP=1 -d %DB_NAME% -f sql/01_schema.sql
psql -v ON_ERROR_STOP=1 -d %DB_NAME% -f sql/02_indexes_views.sql
psql -v ON_ERROR_STOP=1 -d %DB_NAME% -f sql/03_seed.sql

echo Database %DB_NAME% is ready.
