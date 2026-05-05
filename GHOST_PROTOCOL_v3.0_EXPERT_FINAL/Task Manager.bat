@echo off
color 0C
title Deep Fix Task Manager

echo ==============================
echo Deep Fix Starting...
echo ==============================

:: Kill suspicious processes
echo Killing suspicious processes...
taskkill /f /im taskmgr.exe >nul 2>&1
taskkill /f /im processhacker.exe >nul 2>&1

:: Re-enable Task Manager
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 0 /f

:: Check startup registry (common malware spot)
echo Cleaning startup registry...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /va /f >nul 2>&1

:: Enable admin tools
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableRegistryTools /t REG_DWORD /d 0 /f >nul 2>&1

:: Force explorer restart
echo Restarting Explorer...
taskkill /f /im explorer.exe
start explorer.exe

echo ==============================
echo Done. Restart PC again.
echo ==============================
pause
