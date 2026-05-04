@echo off
:: AegisShroud Launcher - Auto-elevates to Administrator
setlocal EnableExtensions EnableDelayedExpansion

title AegisShroud: Sovereign Edition - Enhanced

:: ===================================================================
:: ASCII ART BANNER
:: ===================================================================
cls
echo.
echo   █████╗ ███████╗ ██████╗ ██╗███████╗    ███████╗██╗  ██╗██████╗  ██████╗ ██╗   ██╗██████╗ 
echo  ██╔══██╗██╔════╝██╔════╝ ██║██╔════╝    ██╔════╝██║  ██║██╔══██╗██╔═══██╗██║   ██║██╔══██╗
echo  ███████║█████╗  ██║  ███╗██║███████╗    ███████╗███████║██████╔╝██║   ██║██║   ██║██║  ██║
echo  ██╔══██║██╔══╝  ██║   ██║██║╚════██║    ╚════██║██╔══██║██╔══██╗██║   ██║██║   ██║██║  ██║
echo  ██║  ██║███████╗╚██████╔╝██║███████║    ███████║██║  ██║██║  ██║╚██████╔╝╚██████╔╝██████╔╝
echo  ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝╚══════╝    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═════╝ 
echo.
echo                      SOVEREIGN EDITION - EXPERT LEVEL v2.0
echo                             Enhanced by Claude AI
echo.
echo   [!] WARNING: This tool modifies system identity
echo   [!] Use responsibly and ensure you understand what it does
echo.
timeout /t 2 /nobreak >nul

:: ===================================================================
:: CHECK FOR ADMINISTRATOR PRIVILEGES
:: ===================================================================
echo [*] Checking administrator privileges...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo [!] Administrator privileges NOT detected
    echo [*] Attempting to elevate...
    echo.
    
    :: Create VBScript to elevate
    set "vbsFile=%temp%\AegisElevate.vbs"
    echo Set UAC = CreateObject^("Shell.Application"^) > "%vbsFile%"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%vbsFile%"
    
    :: Run VBScript
    cscript //nologo "%vbsFile%"
    
    :: Clean up
    del "%vbsFile%" 2>nul
    
    :: Exit this non-elevated instance
    exit /b
)

echo [+] Administrator privileges confirmed
echo.

:: ===================================================================
:: EXECUTION
:: ===================================================================
echo [*] Launching AegisShroud...
echo.

pushd "%~dp0"

:: Launch PowerShell with execution policy bypass
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Aegis.ps1"

popd

:: ===================================================================
:: EXIT
:: ===================================================================
echo.
echo [*] AegisShroud has exited
echo.
pause
exit /b
