@echo off
setlocal

set DB_NAME=%1
if "%DB_NAME%"=="" set DB_NAME=ehotels_d2

if "%EHOTELS_PORT%"=="" set EHOTELS_PORT=8080

if not exist app\out mkdir app\out
javac -d app\out app\src\*.java

set EHOTELS_DB=%DB_NAME%
java -cp app\out EHotelsServer
