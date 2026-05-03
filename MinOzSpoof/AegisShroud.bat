@echo off
setlocal EnableExtensions EnableDelayedExpansion
title AegisShroud: Sovereign Edition

:: --- ADMINISTRATOR PRIVILEGES CHECK ---
fltmc >nul 2>&1 || (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\GetAdmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\GetAdmin.vbs"
    "%temp%\GetAdmin.vbs"
    del "%temp%\GetAdmin.vbs"
    exit /b
)

:: --- SILENT LAUNCH ---
pushd "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "Aegis.ps1"
popd
exit /b
