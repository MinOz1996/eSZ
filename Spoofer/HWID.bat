@echo off
mode con:cols=100 lines=80
title Serial Check
color 2

echo [92mDisks
echo [92m------------[91m
wmic diskdrive get serialnumber

echo [92mSerial
echo [92m------------[91m
wmic baseboard get serialnumber

echo [92mSMBios
echo [92m------------[91m
wmic path win32_computersystemproduct get uuid

echo [92mCPU
echo [92m------------[91m
wmic cpu get processorid, serialnumber

echo [92mBios2
echo [92m------------[91m
wmic bios get serialnumber

echo [92mGPU
echo [92m------------[91m
wmic PATH Win32_VideoController GET Description,PNPDeviceID

echo [92mRAM
echo [92m------------[91m
wmic memorychip get serialnumber

echo [92mMac
echo [92m------------[91m
getmac

pause 0
asdgfasdgasgd