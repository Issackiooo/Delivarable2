@echo off
setlocal

set DB_NAME=%1
if "%DB_NAME%"=="" set DB_NAME=ehotels_d2

psql -v ON_ERROR_STOP=1 -d %DB_NAME% -f sql/04_queries.sql
