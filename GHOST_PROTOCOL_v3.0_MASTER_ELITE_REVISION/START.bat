@echo off
TITLE THE ARCHITECT ELITE - GHOST PROTOCOL v3.0
SETLOCAL EnableDelayedExpansion
cls

:: Admin Check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo  [ ELITE SYSTEM ]  Requesting Administrator privileges for Kernel-level operations...
    echo.
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
cls

:: Environment Check
echo  [ ELITE SYSTEM ]  Initializing Environment...
powershell -Command "$PSVersionTable.PSVersion.Major" | findstr "5 7" >nul
if %errorLevel% neq 0 (
    echo  [ ERROR ] PowerShell is required to run this system.
    pause
    exit /b
)

:: Start Main System
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "Aegis.ps1"

if %errorLevel% neq 0 (
    echo.
    echo  ================================================================
    echo   CRITICAL ERROR: System execution interrupted.
    echo   Error Code: %errorLevel%
    echo   Timestamp : %DATE% %TIME%
    echo  ================================================================
    echo.
    pause
)
exit /b
