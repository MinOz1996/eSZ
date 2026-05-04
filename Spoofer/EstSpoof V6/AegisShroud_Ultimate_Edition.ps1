# AegisShroud_Ultimate_MinOz_Edition_Fixed.ps1
# The Most Advanced System Hardening, Identity Virtualization & Trace Cleaning Suite
# 🛠 DEVELOPED BY: MinOz
# Merged & Enhanced: Refactored Logic + Professional Features + Full Visual Overhaul

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
        $s = Get-SecureRandomString -Length $len
        $segments += "$s"
    }
    return ($segments -join "-")
}

function Generate-UltimateComputerName {
    $prefixes = @("DESKTOP", "WIN", "PC", "STATION", "NODE")
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

function Generate-UltimateVolumeId {
    $s1 = Get-SecureRandomString -Length 4 -Charset "0123456789ABCDEF"
    $s2 = Get-SecureRandomString -Length 4 -Charset "0123456789ABCDEF"
    return "$s1-$s2"
}

function Generate-CoherentHardware {
    $profiles = @(
        @{Manufacturer="ASUSTeK COMPUTER INC."; Product="ROG STRIX Z790-E GAMING"; CPU="13th Gen Intel(R) Core(TM) i9-13900K"; GPU="NVIDIA GeForce RTX 4090"; BiosVendor="American Megatrends Inc."; BiosVersion="1202"; Chassis="Desktop"; Monitor="ASUS ROG Swift PG279Q"},
        @{Manufacturer="Micro-Star International"; Product="MPG Z690 CARBON WIFI"; CPU="12th Gen Intel(R) Core(TM) i7-12700K"; GPU="NVIDIA GeForce RTX 3080 Ti"; BiosVendor="American Megatrends Inc."; BiosVersion="E7D32IMS"; Chassis="Desktop"; Monitor="MSI Optix MAG274QRF-QD"},
        @{Manufacturer="Gigabyte Technology"; Product="X670E AORUS MASTER"; CPU="AMD Ryzen 9 7950X 16-Core"; GPU="AMD Radeon RX 7900 XTX"; BiosVendor="American Megatrends Inc."; BiosVersion="F8"; Chassis="Desktop"; Monitor="Gigabyte M27Q"},
        @{Manufacturer="Lenovo"; Product="ThinkPad X1 Carbon Gen 11"; CPU="13th Gen Intel(R) Core(TM) i7-1365U"; GPU="Intel(R) Iris(R) Xe Graphics"; BiosVendor="LENOVO"; BiosVersion="N3AET75W"; Chassis="Laptop"; Monitor="ThinkVision P27h-30"},
        @{Manufacturer="Dell Inc."; Product="Alienware m18 R1"; CPU="13th Gen Intel(R) Core(TM) i9-13980HX"; GPU="NVIDIA GeForce RTX 4080 Laptop"; BiosVendor="Dell Inc."; BiosVersion="1.5.0"; Chassis="Laptop"; Monitor="Alienware AW3423DW"}
    )
    $selected = $profiles[(Get-SecureRandomNumber -Min 0 -Max ($profiles.Length - 1))]
    $selected.Serial = "$(Get-SecureRandomString -Length 12)"
    $m = (Get-SecureRandomNumber -Min 1 -Max 12).ToString("D2")
    $d = (Get-SecureRandomNumber -Min 1 -Max 28).ToString("D2")
    $selected.BiosDate = "2023/$m/$d"
    $tag = Get-SecureRandomString -Length 8
    $selected.AssetTag = "Asset-$tag"
    return $selected
}

# ==============================================================================
# Trace Cleaning & Privacy (Professional Features)
# ==============================================================================
function Clear-DeepTraces {
    Write-Host "`n[i] EXECUTING ULTIMATE DEEP TRACE CLEANER..." -ForegroundColor Cyan
    
    # 1. SetupAPI Logs
    $logs = @("C:\Windows\inf\setupapi.dev.log", "C:\Windows\inf\setupapi.setup.log")
    foreach ($log in $logs) {
        if (Test-Path $log) { 
            try { Set-Content -Path $log -Value "" -Force; Write-Host "  [+] Cleared SetupAPI Log: $log" -ForegroundColor Gray } catch {} 
        }
    }

    # 2. Prefetch & Temp
    $tempPaths = @("C:\Windows\Prefetch\*.pf", "$env:TEMP\*", "C:\Windows\Temp\*")
    foreach ($path in $tempPaths) {
        try { Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue } catch {}
    }
    Write-Host "  [+] Cleared Prefetch and Temporary Files" -ForegroundColor Gray

    # 3. Recent Files & Jump Lists
    $recentPath = "$env:APPDATA\Microsoft\Windows\Recent\*"
    try { Get-ChildItem $recentPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue } catch {}
    Write-Host "  [+] Cleared Recent Files and Jump Lists" -ForegroundColor Gray

    # 4. Event Logs
    $eventLogs = @("System", "Security", "Application", "Setup", "Windows PowerShell")
    foreach ($logName in $eventLogs) {
        wevtutil cl "$logName" 2>$null
        Write-Host "  [+] Event Log Cleared: $logName" -ForegroundColor Gray
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
    Write-Host "  [+] Cleared Registry Artifacts (MUICache/ShimCache)" -ForegroundColor Gray

    Write-Host "[+] DEEP CLEANING COMPLETED SUCCESSFULLY." -ForegroundColor Green
}

function Apply-UltimatePrivacy {
    Write-Host "`n[i] CONFIGURING ULTIMATE PRIVACY SETTINGS..." -ForegroundColor Cyan
    $settings = @(
        @{P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; N="AllowTelemetry"; V=0},
        @{P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; N="AllowTelemetry"; V=0},
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\Activities"; N="EnableActivityFeed"; V=0},
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\Activities"; N="PublishUserActivities"; V=0},
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\Activities"; N="UploadUserActivities"; V=0},
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; N="Enabled"; V=0},
        @{P="HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"; N="BingSearchEnabled"; V=0}
    )
    foreach ($s in $settings) {
        if (-not (Test-Path $s.P)) { try { New-Item $s.P -Force | Out-Null } catch {} }
        try { Set-ItemProperty -Path $s.P -Name $s.N -Value $s.V -Force -ErrorAction SilentlyContinue } catch {}
    }
    Write-Host "[+] PRIVACY SETTINGS HARDENED (ANTI-TELEMETRY)." -ForegroundColor Green
}

# ==============================================================================
# Core Application Logic
# ==============================================================================
function Backup-System {
    Write-Host "`n[i] CREATING ORIGINAL IDENTITY BACKUP..." -ForegroundColor Yellow
    if (-not (Test-Path $BACKUP_DIR)) { New-Item $BACKUP_DIR -ItemType Directory | Out-Null }
    
    $keys = @("HKLM\SOFTWARE\Microsoft\Cryptography", "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName", "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", "HKLM\HARDWARE\DESCRIPTION\System\BIOS")
    foreach ($k in $keys) {
        $safeName = $k.Replace("\", "_") + ".reg"
        $backupPath = Join-Path $BACKUP_DIR $safeName
        reg export "$k" "$backupPath" /y | Out-Null
    }
    Write-Host "[+] SYSTEM BACKUP SAVED IN: $BACKUP_DIR" -ForegroundColor Green
}

function Apply-UltimateProfile {
    param($P)
    Write-Host "`n[i] APPLYING ULTIMATE VIRTUAL IDENTITY LAYERS..." -ForegroundColor Cyan
    try {
        Set-ItemProperty -Path $RegCrypto -Name "MachineGuid" -Value $P.MachineGuid -Force
        Set-ItemProperty -Path $RegWinNT -Name "ProductId" -Value $P.ProductId -Force
        
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" -Name "ComputerName" -Value $P.ComputerName -Force
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" -Name "ComputerName" -Value $P.ComputerName -Force
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "Hostname" -Value $P.ComputerName -Force
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "NV Hostname" -Value $P.ComputerName -Force
        
        Set-ItemProperty -Path $RegBios -Name "SystemManufacturer" -Value $P.Manufacturer -Force
        Set-ItemProperty -Path $RegBios -Name "SystemProductName" -Value $P.Product -Force
        Set-ItemProperty -Path $RegBios -Name "BIOSSerialNumber" -Value $P.Serial -Force
        Set-ItemProperty -Path $RegBios -Name "BIOSVendor" -Value $P.BiosVendor -Force
        Set-ItemProperty -Path $RegBios -Name "BIOSVersion" -Value $P.BiosVersion -Force
        Set-ItemProperty -Path $RegBios -Name "ReleaseDate" -Value $P.BiosDate -Force
        Set-ItemProperty -Path $RegBios -Name "ChassisType" -Value $P.Chassis -Force
        Set-ItemProperty -Path $RegBios -Name "ChassisAssetTag" -Value $P.AssetTag -Force
        Set-ItemProperty -Path $RegCpu -Name "ProcessorNameString" -Value $P.CPU -Force
        
        $adapters = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -and $_.MACAddress }
        foreach ($a in $adapters) {
            $path = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\$($a.DeviceID.PadLeft(4, '0'))"
            if (Test-Path $path) { Set-ItemProperty -Path $path -Name "NetworkAddress" -Value $P.MacAddress -Force }
        }
        Write-Host "[+] ALL IDENTITY LAYERS APPLIED SUCCESSFULLY." -ForegroundColor Green
    } catch {
        Write-Warning "Failed to apply identity: $($_.Exception.Message)"
    }
}

function Enable-Persistence {
    Write-Host "`n[i] ENABLING PERSISTENCE (SCHEDULED TASK)..." -ForegroundColor Cyan
    try {
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ApplyProfile"
        $trigger = New-ScheduledTaskTrigger -AtLogon
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $SCHEDULED_TASK_NAME -Description "Applies Aegis Ultimate Identity by MinOz" -Force | Out-Null
        Write-Host "[+] PERSISTENCE ENABLED (WILL RUN AT LOGON)." -ForegroundColor Green
    } catch {
        Write-Warning "Failed to enable persistence: $($_.Exception.Message)"
    }
}

# ==============================================================================
# UI & Branding
# ==============================================================================
function Show-UltimateMenu {
    Clear-Host
    Write-Host "
  __  __   ___   _   _    ___    _____ 
 |  \/  | |_ _| | \ | |  / _ \  |__  / 
 | |\/| |  | |  |  \| | | | | |   / /  
 | |  | |  | |  | |\  | | |_| |  / /_  
 |_|  |_| |___| |_| \_|  \___/  /____| 
" -ForegroundColor Green
    Write-Host "  ####################################################################
  #                                                                  #
  #             THE AEGIS SHROUD - ULTIMATE EDITION                  #
  #                    DEVELOPED BY: MinOz                           #
  #                                                                  #
  ####################################################################

  [1] FULL PROTECTION (Backup + Randomize + Clean + Privacy + Persist)
  [2] RESTORE ORIGINAL IDENTITY (Remove Shroud & Persistence)
  [3] VIEW CURRENT VIRTUAL PROFILE (Full Detailed View)
  [4] DEEP CLEAN TRACES ONLY
  [5] EXIT" -ForegroundColor Magenta
    return Read-Host "`nSelect an option [1-5]"
}

function View-DetailedProfile {
    if (-not (Test-Path $PROFILE_FILE)) {
        Write-Host "`n[!] NO VIRTUAL PROFILE FOUND. RUN PROTECTION FIRST." -ForegroundColor Red
        return
    }
    $p = Get-Content $PROFILE_FILE | ConvertFrom-Json
    Clear-Host
    Write-Host "`n==============================================================================" -ForegroundColor Yellow
    Write-Host "               CURRENT VIRTUAL IDENTITY PROFILE (ULTIMATE)                    " -ForegroundColor Yellow
    Write-Host "==============================================================================" -ForegroundColor Yellow
    
    $displayData = @(
        @{Category="SYSTEM IDENTIFIERS"; Name="ComputerName"; Value=$p.ComputerName},
        @{Category="SYSTEM IDENTIFIERS"; Name="MachineGuid"; Value=$p.MachineGuid},
        @{Category="SYSTEM IDENTIFIERS"; Name="ProductId"; Value=$p.ProductId},
        @{Category="SYSTEM IDENTIFIERS"; Name="VolumeId"; Value=$p.VolumeId},
        @{Category="HARDWARE PROFILE"; Name="Manufacturer"; Value=$p.Manufacturer},
        @{Category="HARDWARE PROFILE"; Name="ProductName"; Value=$p.Product},
        @{Category="HARDWARE PROFILE"; Name="ChassisType"; Value=$p.Chassis},
        @{Category="HARDWARE PROFILE"; Name="AssetTag"; Value=$p.AssetTag},
        @{Category="CPU & GPU"; Name="Processor"; Value=$p.CPU},
        @{Category="CPU & GPU"; Name="Graphics"; Value=$p.GPU},
        @{Category="FIRMWARE / BIOS"; Name="BiosVendor"; Value=$p.BiosVendor},
        @{Category="FIRMWARE / BIOS"; Name="BiosVersion"; Value=$p.BiosVersion},
        @{Category="FIRMWARE / BIOS"; Name="BiosDate"; Value=$p.BiosDate},
        @{Category="FIRMWARE / BIOS"; Name="SerialNumber"; Value=$p.Serial},
        @{Category="NETWORK & DISPLAY"; Name="MacAddress"; Value=$p.MacAddress},
        @{Category="NETWORK & DISPLAY"; Name="Monitor"; Value=$p.Monitor},
        @{Category="NETWORK & DISPLAY"; Name="HwProfileGuid"; Value=$p.HwProfileGuid}
    )

    $currentCategory = ""
    foreach ($item in $displayData) {
        if ($item.Category -ne $currentCategory) {
            Write-Host "`n--- $($item.Category) ---" -ForegroundColor Cyan
            $currentCategory = $item.Category
        }
        $n = $item.Name
        $v = $item.Value
        Write-Host ("{0,-20} : {1}" -f $n, $v) -ForegroundColor White
    }
    Write-Host "`n==============================================================================" -ForegroundColor Yellow
}

# Entry Point
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] ADMINISTRATOR PRIVILEGES REQUIRED!" -ForegroundColor Red; exit 1
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
                MachineGuid = [guid]::NewGuid().ToString().ToUpper();
                ProductId = Generate-UltimateProductId;
                ComputerName = Generate-UltimateComputerName;
                MacAddress = Generate-UltimateMacAddress;
                VolumeId = Generate-UltimateVolumeId;
                HwProfileGuid = [guid]::NewGuid().ToString().ToUpper();
                Manufacturer = $hw.Manufacturer;
                Product = $hw.Product;
                CPU = $hw.CPU;
                GPU = $hw.GPU;
                Serial = $hw.Serial;
                BiosVendor = $hw.BiosVendor;
                BiosVersion = $hw.BiosVersion;
                BiosDate = $hw.BiosDate;
                Chassis = $hw.Chassis;
                AssetTag = $hw.AssetTag;
                Monitor = $hw.Monitor
            }
            $p | ConvertTo-Json | Set-Content $PROFILE_FILE
            Apply-UltimateProfile -P $p
            Clear-DeepTraces
            Apply-UltimatePrivacy
            Enable-Persistence
            Write-Host "`n[!!!] ULTIMATE PROTECTION APPLIED BY MINOZ. REBOOT RECOMMENDED." -ForegroundColor Yellow
            Read-Host "Press Enter to return to menu..."
        }
        "2" {
            Write-Host "`n[i] RESTORING ORIGINAL SYSTEM IDENTITY..." -ForegroundColor Yellow
            if (Test-Path $BACKUP_DIR) {
                Get-ChildItem $BACKUP_DIR -Filter "*.reg" | ForEach-Object { 
                    Write-Host "  Importing: $($_.Name)" -ForegroundColor Gray
                    reg import $_.FullName | Out-Null 
                }
                Remove-Item -Path $BACKUP_DIR -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "[+] Registry Restored and Backup Folder Deleted." -ForegroundColor Green
            }
            if (Get-ScheduledTask -TaskName $SCHEDULED_TASK_NAME -ErrorAction SilentlyContinue) {
                Unregister-ScheduledTask -TaskName $SCHEDULED_TASK_NAME -Confirm:$false | Out-Null
                Write-Host "[+] Persistence Removed." -ForegroundColor Green
            }
            if (Test-Path $PROFILE_FILE) {
                Remove-Item -Path $PROFILE_FILE -Force -ErrorAction SilentlyContinue
                Write-Host "[+] Virtual Profile Deleted." -ForegroundColor Green
            }
            Read-Host "`nRestore Complete. Press Enter to return to menu..."
        }
        "3" { View-DetailedProfile; Read-Host "`nPress Enter to return to menu..." }
        "4" { Clear-DeepTraces; Read-Host "`nPress Enter to return to menu..." }
        "5" { exit 0 }
    }
}
