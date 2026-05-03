
# AegisShroud: Sovereign Edition - State Manager Module
# DEVELOPED BY: MinOz (Enhanced by Manus AI)
# This module handles system state snapshots, backup, and restore operations.

# Path Detection
$root = $script:AegisRoot
if ([string]::IsNullOrEmpty($root)) {
    $root = $PSScriptRoot
}
if ([string]::IsNullOrEmpty($root)) {
    $root = Get-Location
}

$STATE_DIR = Join-Path $root "state"
$BACKUP_DIR = Join-Path $root "backup"
$SCHEDULED_TASK_NAME = "AegisShroudSovereignLogon"

function Get-CurrentSystemIdentity {
    $identity = @{}
    try { $identity.MachineGuid = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid" -ErrorAction SilentlyContinue).MachineGuid } catch {}
    try { $identity.ProductId = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductId" -ErrorAction SilentlyContinue).ProductId } catch {}
    try { $identity.ComputerName = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" -Name "ComputerName" -ErrorAction SilentlyContinue).ComputerName } catch {}
    try { $identity.MacAddress = (Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -and $_.MACAddress } | Select-Object -ExpandProperty MACAddress -First 1) } catch {}
    try { $identity.VolumeId = (Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' } | Select-Object -ExpandProperty SerialNumber -First 1) } catch {}
    try { $identity.Manufacturer = (Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue).Manufacturer } catch {}
    try { $identity.Product = (Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue).Model } catch {}
    try { $identity.CPU = (Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue).Name } catch {}
    try { $identity.GPU = (Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue).Name } catch {}
    try { $identity.BiosVendor = (Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue).Manufacturer } catch {}
    try { $identity.BiosVersion = (Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue).SMBIOSBIOSVersion } catch {}
    try { $identity.BiosDate = (Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue).ReleaseDate } catch {}
    try { $identity.Serial = (Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue).SerialNumber } catch {}
    try { $identity.Chassis = (Get-CimInstance Win32_SystemEnclosure -ErrorAction SilentlyContinue).ChassisTypes | Out-String -Stream | Select-Object -First 1 } catch {}
    try { $identity.AssetTag = (Get-CimInstance Win32_SystemEnclosure -ErrorAction SilentlyContinue).SMBIOSAssetTag } catch {}
    try { $identity.Monitor = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY\*\*\Device Parameters" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty MonitorUserFriendlyName -First 1) } catch {}
    try { $identity.DiskModel = (Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Model -First 1) } catch {}
    try { $identity.DiskSerial = (Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue | Select-Object -ExpandProperty SerialNumber -First 1) } catch {}
    try { $identity.HwProfileGuid = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\IDConfigDB\Hardware Profiles\0001" -Name "HwProfileGuid" -ErrorAction SilentlyContinue).HwProfileGuid } catch {}
    return $identity
}

function Save-SystemSnapshot {
    param([hashtable]$SnapshotData, [string]$Type)
    if (-not (Test-Path $STATE_DIR)) { New-Item -Path $STATE_DIR -ItemType Directory -Force | Out-Null }
    
    # Use a fixed filename for the latest state of each type to ensure consistency
    $filePath = Join-Path -Path $STATE_DIR -ChildPath "AegisShroud_State_${Type}_Latest.json"
    
    try {
        # Convert to PSCustomObject first to ensure clean JSON serialization
        [PSCustomObject]$SnapshotData | ConvertTo-Json -Depth 100 | Set-Content -Path $filePath -Force
        Write-AegisLog -Level "INFO" -Message "[MinOz] Saved ${Type} system snapshot to ${filePath}."
    } catch {
        Write-AegisLog -Level "ERROR" -Message "[MinOz] Failed to save ${Type} snapshot: $($_.Exception.Message)"
    }
}

function Get-SystemSnapshot {
    param([string]$Type)
    try {
        $filePath = Join-Path -Path $STATE_DIR -ChildPath "AegisShroud_State_${Type}_Latest.json"
        if (Test-Path $filePath) {
            $content = Get-Content -Path $filePath -Raw | ConvertFrom-Json
            return $content
        }
    } catch { 
        Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to load ${Type} snapshot."
    }
    return $null
}

function Backup-AegisSystem {
    Write-AegisLog -Level "INFO" -Message "[MinOz] Creating original system identity backup..."
    if (-not (Test-Path $BACKUP_DIR)) { New-Item -Path $BACKUP_DIR -ItemType Directory -Force | Out-Null }
    $regKeysToBackup = @(
        "HKLM:\SOFTWARE\Microsoft\Cryptography", "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion",
        "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName", "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters",
        "HKLM:\HARDWARE\DESCRIPTION\System\BIOS", "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0",
        "HKLM:\SYSTEM\CurrentControlSet\Enum\DISK", "HKLM:\SYSTEM\CurrentControlSet\Enum\STORAGE",
        "HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY", "HKLM:\SYSTEM\CurrentControlSet\Enum\USB",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}",
        "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache",
        "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR", "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
    )
    foreach ($keyPath in $regKeysToBackup) {
        try {
            $safeName = ($keyPath -replace "\\", "_").Replace("HKLM:", "HKLM").Replace("HKCU:", "HKCU") + ".reg"
            $backupFilePath = Join-Path -Path $BACKUP_DIR -ChildPath $safeName
            reg export $keyPath.Replace("HKLM:", "HKEY_LOCAL_MACHINE").Replace("HKCU:", "HKEY_CURRENT_USER") $backupFilePath /y | Out-Null
        } catch {
            Write-AegisLog -Level "WARN" -Message "Failed to backup registry key ${keyPath}: $($_.Exception.Message)"
        }
    }
    Save-SystemSnapshot -SnapshotData (Get-CurrentSystemIdentity) -Type "Pre"
}

function Restore-AegisSystem {
    Write-AegisLog -Level "INFO" -Message "[MinOz] Restoring original system identity..."
    try {
        if (Test-Path $BACKUP_DIR) {
            Get-ChildItem -Path $BACKUP_DIR -Filter "*.reg" | ForEach-Object {
                try { reg import $_.FullName /y | Out-Null } catch {}
            }
            Remove-Item -Path $BACKUP_DIR -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Get-ScheduledTask -TaskName $SCHEDULED_TASK_NAME -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName $SCHEDULED_TASK_NAME -Confirm:$false | Out-Null
        }
        if (Test-Path $STATE_DIR) { Remove-Item -Path $STATE_DIR -Recurse -Force -ErrorAction SilentlyContinue }
        Write-AegisLog -Level "INFO" -Message "[MinOz] System restore completed successfully."
    } catch {
        Write-AegisLog -Level "ERROR" -Message "[MinOz] System restore failed: $($_.Exception.Message)"
    }
}

function Enable-AegisPersistence {
    Write-AegisLog -Level "INFO" -Message "[MinOz] Enabling persistence..."
    try {
        $mainScriptPath = Join-Path $root "Aegis.ps1"
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$mainScriptPath`" -ApplyProfile"
        $trigger = New-ScheduledTaskTrigger -AtLogon
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $SCHEDULED_TASK_NAME -Description "AegisShroud Sovereign Identity" -Force | Out-Null
    } catch {
        Write-AegisLog -Level "ERROR" -Message "[MinOz] Failed to enable persistence: $($_.Exception.Message)"
    }
}
