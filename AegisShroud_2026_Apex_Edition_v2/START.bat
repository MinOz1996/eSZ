@echo off
:: MinOz AegisShroud - Direct Launcher
setlocal EnableExtensions EnableDelayedExpansion

title MinOz - AegisShroud: Sovereign Edition

:: Check for Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo [!] Administrator privileges required
    echo [*] Attempting to elevate...
    echo.
    
    set "vbsFile=%temp%\MinOzElevate.vbs"
    echo Set UAC = CreateObject^("Shell.Application"^) > "%vbsFile%"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%vbsFile%"
    
    cscript //nologo "%vbsFile%"
    del "%vbsFile%" 2>nul
    exit /b
)

pushd "%~dp0"

:: Launch directly to Menu (silent load)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Aegis.ps1"

popd
pause
exit /b
