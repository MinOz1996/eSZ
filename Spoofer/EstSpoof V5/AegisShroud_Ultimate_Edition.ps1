# AegisShroud_Ultimate_Edition.ps1 (v2 - Fixed Syntax)
# The Ultimate System Hardening, Identity Virtualization & Trace Cleaning Suite
# Merged & Optimized: Refactored Logic + Professional Features

param(
    [switch]$ApplyProfile,
    [string]$ProfilePath,
    [switch]$Restore
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==============================================================================
# Global Configuration & Obfuscated Paths
# ==============================================================================
$PROFILE_FILE = "AegisUltimateProfile.json"
$BACKUP_DIR = "AegisUltimate_Backup"
$SCHEDULED_TASK_NAME = "AegisShroudUltimateLogon"

function Get-DeobfuscatedString {
    param([string]$Base64String)
    $Base64String = $Base64String.Trim()
    $padding = $Base64String.Length % 4
    if ($padding -gt 0) { $Base64String += "=" * (4 - $padding) }
    try { return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Base64String)) }
    catch { return $Base64String }
}

$RegCrypto = Get-DeobfuscatedString "SEtMTTpcU09GVFdBUkVcTWljcm9zb2Z0XENyeXB0b2dyYXBoeQ==" # HKLM:\SOFTWARE\Microsoft\Cryptography
$RegWinNT = Get-DeobfuscatedString "SEtMTTpcU09GVFdBUkVcTWljcm9zb2Z0XFdpbmRvd3MgTlRcQ3VycmVudFZlcnNpb24=" # HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion
$RegCompName = Get-DeobfuscatedString "SEtMTTpcU1lTVEVNXEN1cnJlbnRDb250cm9sU2V0XENvbnRyb2xcQ29tcHV0ZXJOYW1lXENvbXB1dGVyTmFtZQ==" # HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName
$RegTcpip = Get-DeobfuscatedString "SEtMTTpcU1lTVEVNXEN1cnJlbnRDb250cm9sU2V0XFNlcnZpY2VzXFRjcGlwXFBhcmFtZXRlcnM=" # HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters
$RegBios = Get-DeobfuscatedString "SEtMTTpcSEFSRFdBUkVcREVTQ1JJUFRJT05cU3lzdGVtXEJJT1M=" # HKLM:\HARDWARE\DESCRIPTION\System\BIOS
$RegCpu = Get-DeobfuscatedString "SEtMTTpcSEFSRFdBUkVcREVTQ1JJUFRJT05cU3lzdGVtXENlbnRyYWxQcm9jZXNzb3JcMA==" # HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0

# ==============================================================================
# DIRE_Core: Deep Identity Randomization Engine (Enhanced Mutation)
# ==============================================================================
function Get-EnvironmentalEntropy {
    $entropy = ""
    $entropy += (Get-Date).Ticks.ToString()
    $entropy += $PID.ToString()
    $entropy += (Get-Process).Count.ToString()
    $systemDrive = Get-PSDrive -Name C -ErrorAction SilentlyContinue
    if ($systemDrive) { $entropy += $systemDrive.Free.ToString() }
    try { $entropy += (Get-CimInstance Win32_LogonSession | Where-Object {$_.LogonType -eq 2}).Count.ToString() } catch { $entropy += "0" }
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    (Get-Random -Minimum 0 -Maximum 1000 | Out-Null)
    $stopwatch.Stop()
    $entropy += $stopwatch.ElapsedTicks.ToString()

    $hasher = New-Object System.Security.Cryptography.SHA256Managed
    return $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($entropy))
}

function Get-SecureRandomBytes {
    param([int]$Length)
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[] $Length
    $entropy = Get-EnvironmentalEntropy
    $temp = New-Object byte[] $entropy.Length
    $rng.GetBytes($temp)
    for ($i = 0; $i -lt $entropy.Length; $i++) { $temp[$i] = $temp[$i] -bxor $entropy[$i] }
    $rng.GetBytes($bytes)
    return $bytes
}

function Get-SecureRandomNumber {
    param([int]$Min, [int]$Max)
    $bytes = Get-SecureRandomBytes -Length 4
    $num = [math]::Abs([System.BitConverter]::ToInt32($bytes, 0))
    return ($num % ($Max - $Min + 1)) + $Min
}

function Get-SecureRandomString {
    param([int]$Length, [string]$Charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
    $res = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $Length; $i++) {
        $idx = Get-SecureRandomNumber -Min 0 -Max ($Charset.Length - 1)
        [void]$res.Append($Charset[$idx])
    }
    return $res.ToString()
}

# ==============================================================================
# Identity Generators (Refactored Logic)
# ==============================================================================
function Generate-UltimateProductId {
    $segments = @()
    for ($i = 0; $i -lt 5; $i++) {
        $len = Get-SecureRandomNumber -Min 4 -Max 5
        $segments += Get-SecureRandomString -Length $len
    }
    return ($segments -join "-")
}

function Generate-UltimateComputerName {
    $prefixes = @("DESKTOP", "WIN", "PC", "STATION")
    $prefix = $prefixes[(Get-SecureRandomNumber -Min 0 -Max ($prefixes.Length - 1))]
    $suffixLen = Get-SecureRandomNumber -Min 5 -Max 8
    $suffix = Get-SecureRandomString -Length $suffixLen
    return "$prefix-$suffix"
}

function Generate-UltimateMacAddress {
    $bytes = Get-SecureRandomBytes -Length 6
    $bytes[0] = $bytes[0] -band 0xFC # Locally administered, unicast
    $macParts = $bytes | ForEach-Object { $_.ToString("X2") }
    return ($macParts -join "")
}

function Generate-CoherentHardware {
    $profiles = @(
        @{Manufacturer="ASUSTeK COMPUTER INC."; Product="ROG STRIX Z790-E"; CPU="13th Gen Intel(R) Core(TM) i9-13900K"; GPU="NVIDIA GeForce RTX 4090"},
        @{Manufacturer="Micro-Star International"; Product="MPG Z690 CARBON"; CPU="12th Gen Intel(R) Core(TM) i7-12700K"; GPU="NVIDIA GeForce RTX 3080 Ti"},
        @{Manufacturer="Gigabyte Technology"; Product="X670E AORUS MASTER"; CPU="AMD Ryzen 9 7950X"; GPU="AMD Radeon RX 7900 XTX"},
        @{Manufacturer="Dell Inc."; Product="Alienware m18 R1"; CPU="13th Gen Intel(R) Core(TM) i9-13980HX"; GPU="NVIDIA GeForce RTX 4080 Laptop"}
    )
    $selected = $profiles[(Get-SecureRandomNumber -Min 0 -Max ($profiles.Length - 1))]
    $selected.Serial = Get-SecureRandomString -Length 12
    $selected.BiosVer = Get-SecureRandomString -Length 4 -Charset "0123456789"
    return $selected
}

# ==============================================================================
# Trace Cleaning & Privacy (Professional Features)
# ==============================================================================
function Clear-DeepTraces {
    Write-Host "[i] Executing Ultimate Deep Trace Cleaner..." -ForegroundColor Cyan
    
    # 1. SetupAPI Logs
    $logs = @("C:\Windows\inf\setupapi.dev.log", "C:\Windows\inf\setupapi.setup.log")
    foreach ($log in $logs) {
        if (Test-Path $log) { 
            try { 
                Set-Content -Path $log -Value "" -Force
                Write-Host "  [+] Cleared: $log" 
            } catch {} 
        }
    }

    # 2. Prefetch & Temp
    $tempPaths = @("C:\Windows\Prefetch\*.pf", "$env:TEMP\*", "C:\Windows\Temp\*")
    foreach ($path in $tempPaths) {
        try { Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue } catch {}
    }

    # 3. Recent Files & Jump Lists
    $recentPath = "$env:APPDATA\Microsoft\Windows\Recent\*"
    try { Get-ChildItem $recentPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue } catch {}

    # 4. Event Logs
    $eventLogs = @("System", "Security", "Application", "Setup", "Windows PowerShell")
    foreach ($logName in $eventLogs) {
        wevtutil cl "$logName" 2>$null
        Write-Host "  [+] Event Log Cleared: $logName"
    }

    # 5. MUICache & ShimCache
    try {
        $muiPath = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
        if (Test-Path $muiPath) {
            $key = Get-Item $muiPath
            foreach ($valName in $key.GetValueNames()) {
                if ($valName -ne "(Default)") { Remove-ItemProperty $muiPath -Name $valName -Force -ErrorAction SilentlyContinue }
            }
        }
        Remove-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache" -Name "AppCompatCache" -Force -ErrorAction SilentlyContinue
    } catch {}

    Write-Host "[+] Deep Cleaning Completed." -ForegroundColor Green
}

function Apply-UltimatePrivacy {
    Write-Host "[i] Configuring Ultimate Privacy Settings..." -ForegroundColor Cyan
    $settings = @(
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; N="AllowTelemetry"; V=0},
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; N="AllowTelemetry"; V=0},
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\Activities"; N="EnableActivityFeed"; V=0},
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; N="Enabled"; V=0}
    )
    foreach ($s in $settings) {
        if (-not (Test-Path $s.P)) { try { New-Item $s.P -Force | Out-Null } catch {} }
        try { Set-ItemProperty -Path $s.P -Name $s.N -Value $s.V -Force -ErrorAction SilentlyContinue } catch {}
    }
    Write-Host "[+] Privacy Settings Hardened." -ForegroundColor Green
}

# ==============================================================================
# Core Application Logic
# ==============================================================================
function Backup-System {
    Write-Host "[i] Creating Original Identity Backup..." -ForegroundColor Yellow
    if (-not (Test-Path $BACKUP_DIR)) { New-Item $BACKUP_DIR -ItemType Directory | Out-Null }
    
    $keys = @("HKLM\SOFTWARE\Microsoft\Cryptography", "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName", "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "HKLM\HARDWARE\DESCRIPTION\System\BIOS")
    foreach ($k in $keys) {
        $safeName = $k.Replace("\", "_") + ".reg"
        $backupPath = Join-Path $BACKUP_DIR $safeName
        reg export "$k" "$backupPath" /y | Out-Null
    }
    Write-Host "[+] Backup saved in $BACKUP_DIR" -ForegroundColor Green
}

function Apply-UltimateProfile {
    param($P)
    Write-Host "[i] Applying Ultimate Virtual Identity..." -ForegroundColor Cyan
    try {
        Set-ItemProperty -Path $RegCrypto -Name "MachineGuid" -Value $P.MachineGuid -Force
        Set-ItemProperty -Path $RegWinNT -Name "ProductId" -Value $P.ProductId -Force
        
        # Computer Name
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" -Name "ComputerName" -Value $P.ComputerName -Force
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" -Name "ComputerName" -Value $P.ComputerName -Force
        
        # Hardware
        Set-ItemProperty -Path $RegBios -Name "SystemManufacturer" -Value $P.Manufacturer -Force
        Set-ItemProperty -Path $RegBios -Name "SystemProductName" -Value $P.Product -Force
        Set-ItemProperty -Path $RegBios -Name "BIOSSerialNumber" -Value $P.Serial -Force
        Set-ItemProperty -Path $RegCpu -Name "ProcessorNameString" -Value $P.CPU -Force
        
        # Network (MAC Spoofing)
        $adapters = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -and $_.MACAddress }
        foreach ($a in $adapters) {
            $path = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\$($a.DeviceID.PadLeft(4, '0'))"
            if (Test-Path $path) { Set-ItemProperty -Path $path -Name "NetworkAddress" -Value $P.MacAddress -Force }
        }
        Write-Host "[+] Identity Layers Applied Successfully." -ForegroundColor Green
    } catch {
        Write-Warning "Failed to apply identity: $($_.Exception.Message)"
    }
}

function Enable-Persistence {
    Write-Host "[i] Enabling Persistence (Scheduled Task)..." -ForegroundColor Cyan
    try {
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ApplyProfile"
        $trigger = New-ScheduledTaskTrigger -AtLogon
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $SCHEDULED_TASK_NAME -Description "Applies Aegis Ultimate Identity" -Force | Out-Null
        Write-Host "[+] Persistence Enabled." -ForegroundColor Green
    } catch {
        Write-Warning "Failed to enable persistence: $($_.Exception.Message)"
    }
}

# ==============================================================================
# UI & Execution
# ==============================================================================
function Show-UltimateMenu {
    Clear-Host
    $ui = @"
  ####################################################################
  #                                                                  #
  #             THE AEGIS SHROUD - ULTIMATE EDITION                  #
  #          [ Refactored Logic + Professional Features ]            #
  #                                                                  #
  ####################################################################

  [1] FULL PROTECTION (Backup + Randomize + Clean + Privacy + Persist)
  [2] RESTORE ORIGINAL IDENTITY (Remove Shroud & Persistence)
  [3] VIEW CURRENT VIRTUAL PROFILE
  [4] DEEP CLEAN TRACES ONLY
  [5] EXIT
"@
    Write-Host $ui -ForegroundColor Magenta
    return Read-Host "`nSelect an option [1-5]"
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Administrator privileges required!" -ForegroundColor Red; exit 1
}

if ($ApplyProfile) {
    if (Test-Path $PROFILE_FILE) {
        $p = Get-Content $PROFILE_FILE | ConvertFrom-Json
        Apply-UltimateProfile -P $p
        Clear-DeepTraces
        Apply-UltimatePrivacy
    }
    exit 0
}

while ($true) {
    $c = Show-UltimateMenu
    switch ($c) {
        "1" {
            Backup-System
            $hw = Generate-CoherentHardware
            $p = @{
                MachineGuid = [guid]::NewGuid().ToString();
                ProductId = Generate-UltimateProductId;
                ComputerName = Generate-UltimateComputerName;
                MacAddress = Generate-UltimateMacAddress;
                Manufacturer = $hw.Manufacturer;
                Product = $hw.Product;
                CPU = $hw.CPU;
                Serial = $hw.Serial
            }
            $p | ConvertTo-Json | Set-Content $PROFILE_FILE
            Apply-UltimateProfile -P $p
            Clear-DeepTraces
            Apply-UltimatePrivacy
            Enable-Persistence
            Write-Host "`n[!!!] ULTIMATE PROTECTION APPLIED. REBOOT RECOMMENDED." -ForegroundColor Yellow
            Read-Host "Press Enter..."
        }
        "2" {
            Write-Host "[i] Restoring..." -ForegroundColor Yellow
            if (Test-Path $BACKUP_DIR) {
                Get-ChildItem $BACKUP_DIR -Filter "*.reg" | ForEach-Object { reg import $_.FullName | Out-Null }
                Write-Host "[+] Registry Restored."
            }
            if (Get-ScheduledTask -TaskName $SCHEDULED_TASK_NAME -ErrorAction SilentlyContinue) {
                Unregister-ScheduledTask -TaskName $SCHEDULED_TASK_NAME -Confirm:$false | Out-Null
                Write-Host "[+] Persistence Removed."
            }
            Read-Host "Done. Press Enter..."
        }
        "3" {
            if (Test-Path $PROFILE_FILE) { Get-Content $PROFILE_FILE | ConvertFrom-Json | Format-List }
            else { Write-Host "No profile found." }
            Read-Host "Press Enter..."
        }
        "4" { Clear-DeepTraces; Read-Host "Press Enter..." }
        "5" { exit 0 }
    }
}
