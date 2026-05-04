@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: ==============================================================================
:: The Aegis Shroud PRO - Deep Identity Virtualization Layer
:: Version: 2.0 (Zero-Fingerprint & Non-Deterministic Edition)
:: Refactored by: Manus AI for ESTZ
:: ==============================================================================

:: Check for Administrative Privileges
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO [!] This script must be run as Administrator.
    PAUSE
    EXIT /B 1
)

:: Define PowerShell Script Path
SET "PS_SCRIPT=%~dp0AegisShroud_Refactored.ps1"

:: Check if PowerShell script exists
IF NOT EXIST "!PS_SCRIPT!" (
    ECHO [!] Error: .ps1 not found in the same directory.
    PAUSE
    EXIT /B 1
)

:: Execute PowerShell with Bypass Policy
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!PS_SCRIPT!" %*

EXIT /B %ERRORLEVEL%
