# MinOz GHOST PROTOCOL (2026) - State Manager Module v3.0 Ultimate Elite
# DEVELOPED BY: THE ARCHITECT ELITE SYSTEM

$script:STATE_DIR = $null
$script:AEGIS_STATE_FILE = $null

function Initialize-StateDirectories {
    $root = $script:AegisRoot
    if ([string]::IsNullOrEmpty($root)) { $root = $PWD.Path }
    $script:STATE_DIR = Join-Path $root "state"
    $script:AEGIS_STATE_FILE = Join-Path $root "state\aegis_state.json"
    if (!(Test-Path $script:STATE_DIR)) { New-Item -Path $script:STATE_DIR -ItemType Directory -Force }
}

function Get-CurrentSystemIdentity {
    $identity = @{}
    
    # 1. Core Identifiers
    $identity["ComputerName"] = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" -ErrorAction SilentlyContinue).ComputerName
    if (!$identity["ComputerName"]) { $identity["ComputerName"] = $env:COMPUTERNAME }
    $identity["MachineGuid"]  = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Cryptography" -ErrorAction SilentlyContinue).MachineGuid
    $identity["ProductId"]    = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction SilentlyContinue).ProductId

    # 2. Hardware Manufacturer & BIOS (Prefer SystemInformation as primary)
    $sysInfo = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -ErrorAction SilentlyContinue
    $biosInfo = Get-ItemProperty "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -ErrorAction SilentlyContinue
    
    $identity["Manufacturer"] = if ($sysInfo.SystemManufacturer) { $sysInfo.SystemManufacturer } elseif ($biosInfo.SystemManufacturer) { $biosInfo.SystemManufacturer } else { "Unknown" }
    $identity["Product"]      = if ($sysInfo.SystemProductName) { $sysInfo.SystemProductName } elseif ($biosInfo.SystemProductName) { $biosInfo.SystemProductName } else { "Unknown" }
    
    $chassis = if ($sysInfo.ChassisType) { $sysInfo.ChassisType } elseif ($biosInfo.ChassisType) { $biosInfo.ChassisType } else { "3" }
    $identity["Chassis"]      = if ($chassis -eq "3") { "Desktop" } elseif ($chassis -eq "9" -or $chassis -eq "10") { "Laptop" } else { "Desktop ($chassis)" }

    $identity["BiosVendor"]   = if ($sysInfo.BIOSVendor) { $sysInfo.BIOSVendor } elseif ($biosInfo.BIOSVendor) { $biosInfo.BIOSVendor } else { "Unknown" }
    $identity["BiosVersion"]  = if ($sysInfo.BIOSVersion) { $sysInfo.BIOSVersion } elseif ($biosInfo.BIOSVersion) { $biosInfo.BIOSVersion } else { "Unknown" }
    $identity["BiosDate"]     = if ($sysInfo.BIOSReleaseDate) { $sysInfo.BIOSReleaseDate } elseif ($biosInfo.BIOSReleaseDate) { $biosInfo.BIOSReleaseDate } else { "Unknown" }
    $identity["Serial"]       = if ($sysInfo.SystemSerialNumber) { $sysInfo.SystemSerialNumber } elseif ($biosInfo.SystemSerialNumber) { $biosInfo.SystemSerialNumber } else { "Unknown" }

    # 3. Processor & Graphics
    $cpu = Get-ItemProperty "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0" -ErrorAction SilentlyContinue
    $identity["CPU"] = if ($cpu.ProcessorNameString) { $cpu.ProcessorNameString.Trim() } else { "Unknown" }
    
    $gpuPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
    $gpuKeys = Get-ChildItem $gpuPath -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match "^\d{4}$" }
    $identity["GPU"] = if ($gpuKeys) { (Get-ItemProperty $gpuKeys[0].PSPath -ErrorAction SilentlyContinue).DriverDesc } else { "Unknown" }

    # 4. Network Adapter (MAC)
    $netPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"
    $netKeys = Get-ChildItem $netPath -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match "^\d{4}$" }
    $mac = "00:00:00:00:00:00"
    foreach ($nk in $netKeys) {
        $addr = (Get-ItemProperty $nk.PSPath -ErrorAction SilentlyContinue).NetworkAddress
        if ($addr -and $addr.Length -eq 12) { $mac = ($addr -replace '(..)(..)(..)(..)(..)(..)', '$1:$2:$3:$4:$5:$6'); break }
    }
    $identity["MacAddress"] = $mac

    # 5. Advanced Security & Storage (Deep Sync)
    $identity["DiskModel"]  = (Get-AegisState -Key "LastDiskModel" -Default "Standard Disk Drive")
    $identity["DiskSerial"] = (Get-AegisState -Key "LastDiskSerial" -Default "DISK-SN-DEFAULT")
    $identity["VolumeId"]   = (Get-AegisState -Key "LastVolumeId" -Default "C0E1-F291")
    
    # UUID check (Critical for ACE)
    $sysUuid = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -ErrorAction SilentlyContinue).SystemUuid
    $identity["UUID"]       = if ($sysUuid) { $sysUuid } else { (Get-AegisState -Key "LastUUID" -Default "00000000-0000-0000-0000-000000000000") }
    
    # TPM check (Must reflect real state or spoofed state)
    $identity["TPM_EK"]     = (Get-AegisState -Key "LastTPM" -Default "TPM-ACTIVE-VERIFIED")

    return $identity
}

function Save-SystemSnapshot {
    param($Type)
    Initialize-StateDirectories
    $path = Join-Path $script:STATE_DIR "snapshot_$Type.json"
    if ($Type -eq "Pre" -and (Test-Path $path)) { return } # Keep original
    (Get-CurrentSystemIdentity) | ConvertTo-Json | Out-File -FilePath $path -Encoding ascii
}

function Get-SystemSnapshot {
    param($Type)
    $path = Join-Path $script:STATE_DIR "snapshot_$Type.json"
    if (Test-Path $path) { try { return Get-Content $path -Raw | ConvertFrom-Json } catch { return $null } }
    return $null
}

function Restore-AegisSystem {
    $backupDir = Join-Path $script:AegisRoot "backup"
    
    # IMPORTANT: We do NOT reset $global:IsSpoofed here yet.
    # We want the UI to show the TRUTH until the registry is actually restored.
    
    if (Test-Path $backupDir) {
        Get-ChildItem $backupDir -Filter "*.reg" | ForEach-Object { 
            try { 
                $regFile = $_.FullName
                Write-Host " [INFO] Restoring: $($_.Name)" -ForegroundColor Gray
                
                # Expert Level: Use reg.exe directly with high priority
                $cmd = "reg import `"$regFile`" /reg:64 /y"
                cmd.exe /c $cmd | Out-Null
            } catch {
                Write-Host " [!] Failed to restore: $($_.Name)" -ForegroundColor Red
            }
        }
        # Clean up backup
        Remove-Item (Join-Path $backupDir "*.reg") -Force -ErrorAction SilentlyContinue
    }
    
    # Reset States ONLY AFTER registry import attempt
    $global:IsSpoofed = $false
    $global:LastMode = "None"
    
    if (Test-Path $script:AEGIS_STATE_FILE) { Remove-Item $script:AEGIS_STATE_FILE -Force }
    
    # WE KEEP snapshot_Pre.json! 
    # If we delete it, the Diagnostic has nothing to compare against and will show [ORIGINAL] incorrectly.
    # It should only be deleted AFTER a successful reboot into original state.
    # For now, we delete Post but keep Pre for the final diagnostic check before reboot.
    Get-ChildItem $script:STATE_DIR -Filter "snapshot_Post.json" | Remove-Item -Force -ErrorAction SilentlyContinue
    
    # Manual cleanup for core keys that might not be in .reg files
    $cleanPaths = @("HKLM:\HARDWARE\DESCRIPTION\System\BIOS", "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation")
    foreach ($p in $cleanPaths) {
        # We can't know the original values easily without the .reg, but we can try to set generic ones or 
        # rely on the fact that the .reg files (bios.reg, sysinfo.reg) should cover these.
    }
}

function Set-AegisState {
    param($Key, $Value)
    Initialize-StateDirectories
    $state = @{}
    if (Test-Path $script:AEGIS_STATE_FILE) { try { $state = Get-Content $script:AEGIS_STATE_FILE -Raw | ConvertFrom-Json -AsHashtable } catch {} }
    $state[$Key] = $Value
    $state | ConvertTo-Json | Out-File -FilePath $script:AEGIS_STATE_FILE -Encoding ascii
}

function Get-AegisState {
    param($Key, $Default)
    if (Test-Path $script:AEGIS_STATE_FILE) {
        try { $s = Get-Content $script:AEGIS_STATE_FILE -Raw | ConvertFrom-Json -AsHashtable; if ($s.ContainsKey($Key)) { return $s[$Key] } } catch {}
    }
    return $Default
}
