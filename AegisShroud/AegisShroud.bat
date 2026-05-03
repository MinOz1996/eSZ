@echo off
:: AegisShroud Professional Launcher
:: Purpose: Elevate privileges and launch the PowerShell Framework

setlocal
set "SCRIPT_PATH=%~dp0Aegis.ps1"

:: Check for Administrator Privileges
fltmc >nul 2>&1 || (
    echo [!] Requesting Administrator Privileges...
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

:: Launch AegisShroud Framework
pushd "%~dp0"
title AegisShroud Professional Framework
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"

if %ERRORLEVEL% neq 0 (
    echo.
    echo [!] AegisShroud exited with error code %ERRORLEVEL%
    pause
)
popd
