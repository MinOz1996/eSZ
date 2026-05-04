@echo off
TITLE MinOz - AegisShroud Sovereign: Ultimate Hybrid Edition (2026)
SETLOCAL EnableDelayedExpansion

:: --- Admin Elevation Check ---
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run
) else (
    echo ################################################################
    echo # REQUESTING ADMINISTRATOR PRIVILEGES...                      #
    echo ################################################################
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

:run
cd /d "%~dp0"
cls
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "Aegis.ps1"
if %errorLevel% neq 0 (
    echo.
    echo [!] Script exited with error code: %errorLevel%
    pause
)
exit /b
