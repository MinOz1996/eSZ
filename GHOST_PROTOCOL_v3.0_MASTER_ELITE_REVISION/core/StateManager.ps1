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
    $identity["ComputerName"] = $env:COMPUTERNAME
    $identity["MachineGuid"]  = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Cryptography" -ErrorAction SilentlyContinue).MachineGuid
    $identity["ProductId"]    = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction SilentlyContinue).ProductId

    $sysInfo = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -ErrorAction SilentlyContinue
    $identity["Manufacturer"] = if ($sysInfo.SystemManufacturer) { $sysInfo.SystemManufacturer } else { "Unknown" }
    $identity["Product"]      = if ($sysInfo.SystemProductName) { $sysInfo.SystemProductName } else { "Unknown" }
    $identity["Chassis"]      = "Desktop"

    $cpu = Get-ItemProperty "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0" -ErrorAction SilentlyContinue
    $identity["CPU"] = if ($cpu.ProcessorNameString) { $cpu.ProcessorNameString.Trim() } else { "Unknown" }
    
    $gpuPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
    $gpuKeys = Get-ChildItem $gpuPath -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match "^\d{4}$" }
    $identity["GPU"] = if ($gpuKeys) { (Get-ItemProperty $gpuKeys[0].PSPath -ErrorAction SilentlyContinue).DriverDesc } else { "Unknown" }

    $bios = Get-ItemProperty "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -ErrorAction SilentlyContinue
    $identity["BiosVendor"]  = if ($bios.BIOSVendor) { $bios.BIOSVendor } else { "Unknown" }
    $identity["BiosVersion"] = if ($bios.BIOSVersion) { $bios.BIOSVersion } else { "Unknown" }
    $identity["BiosDate"]    = if ($bios.BIOSReleaseDate) { $bios.BIOSReleaseDate } else { "Unknown" }
    $identity["Serial"]      = if ($bios.SystemSerialNumber) { $bios.SystemSerialNumber } else { "Unknown" }

    # MAC Address Fix
    $netPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"
    $netKeys = Get-ChildItem $netPath -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match "^\d{4}$" }
    $mac = "00:00:00:00:00:00"
    foreach ($nk in $netKeys) {
        $addr = (Get-ItemProperty $nk.PSPath -ErrorAction SilentlyContinue).NetworkAddress
        if ($addr -and $addr.Length -eq 12) { $mac = ($addr -replace '(..)(..)(..)(..)(..)(..)', '$1:$2:$3:$4:$5:$6'); break }
    }
    $identity["MacAddress"] = $mac

    # Dynamic States from Memory/File
    $identity["DiskModel"]  = (Get-AegisState -Key "LastDiskModel" -Default "Standard Disk Drive")
    $identity["DiskSerial"] = (Get-AegisState -Key "LastDiskSerial" -Default "DISK-SN-DEFAULT")
    $identity["VolumeId"]   = (Get-AegisState -Key "LastVolumeId" -Default "C0E1-F291")
    $identity["UUID"]       = (Get-AegisState -Key "LastUUID" -Default "00000000-0000-0000-0000-000000000000")
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
    if (Test-Path $backupDir) {
        Get-ChildItem $backupDir -Filter "*.reg" | ForEach-Object { try { & reg import "$($_.FullName)" /reg:64 } catch {} }
    }
    # Clear States
    if (Test-Path $script:AEGIS_STATE_FILE) { Remove-Item $script:AEGIS_STATE_FILE -Force }
    Get-ChildItem $script:STATE_DIR -Filter "snapshot_*.json" | Remove-Item -Force
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
