@echo off
TITLE MinOz GHOST PROTOCOL (2026) - Production v1.0
SETLOCAL EnableDelayedExpansion

:: --- Display Banner ---
cls
echo.
echo ================================================================
echo   MinOz GHOST PROTOCOL (2026) - Production Edition
echo   Developed by: MinOz Technology
echo   Version: 1.0.0 PRODUCTION
echo   Date: %DATE% %TIME:~0,5%
echo ================================================================
echo.

:: --- Admin Elevation Check ---
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run
) else (
    echo [!] Administrator privileges required!
    echo [*] Requesting elevation...
    echo.
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

:run
cd /d "%~dp0"
cls

:: --- Display Header ---
echo.
echo ================================================================
echo   MinOz GHOST PROTOCOL (2026)
echo   Started: %DATE% %TIME:~0,8%
echo ================================================================
echo.

:: --- Run Main Script ---
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "Aegis.ps1"

:: --- Error Handling ---
if %errorLevel% neq 0 (
    echo.
    echo ================================================================
    echo   ERROR: Script exited with code %errorLevel%
    echo   Time: %TIME:~0,8%
    echo ================================================================
    echo.
    pause
)

exit /b
