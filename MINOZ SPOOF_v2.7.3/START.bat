@echo off
TITLE MinOz GHOST PROTOCOL (2026) - v2.5.0
SETLOCAL EnableDelayedExpansion
cls

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo  [ MinOz GHOST PROTOCOL ]  Requesting Administrator privileges...
    echo.
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
cls
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "Aegis.ps1"

if %errorLevel% neq 0 (
    echo.
    echo  ================================================================
    echo   ERROR: Script exited with code: %errorLevel%
    echo   Time : %TIME%
    echo  ================================================================
    echo.
    pause
)
exit /b
