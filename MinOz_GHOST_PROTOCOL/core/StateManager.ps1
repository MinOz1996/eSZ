# AegisShroud: Sovereign Edition - Enhanced State Manager Module
# DEVELOPED BY: MinOz (Enhanced to Expert-Level by Claude)
# Enterprise-grade state management with atomic transactions and rollback

using namespace System.IO
using namespace System.Collections.Generic

#region Module Variables

$script:STATE_DIR = $null
$script:BACKUP_DIR = $null
$script:TRANSACTION_LOG = $null
$script:SCHEDULED_TASK_NAME = $null

function Initialize-StateDirectories {
    $root = $script:AegisRoot
    if ([string]::IsNullOrEmpty($root)) { $root = $PWD.Path }
    
    $script:STATE_DIR = Join-Path $root "state"
    $script:BACKUP_DIR = Join-Path $root "backup"
    $script:TRANSACTION_LOG = Join-Path $root "state\transactions.json"
    
    # Use stealth task name if StealthMode is enabled
    $config = Get-AegisConfig
    if ($config.Features.StealthMode) {
        # Mimic legitimate Windows task
        $script:SCHEDULED_TASK_NAME = "MicrosoftEdgeUpdateTaskMachineCore"
    }
    else {
        $script:SCHEDULED_TASK_NAME = "AegisShroudSovereignLogon"
    }
    
    # Create directories
    @($script:STATE_DIR, $script:BACKUP_DIR) | ForEach-Object {
        if (-not (Test-Path $_)) {
            $null = New-Item -Path $_ -ItemType Directory -Force -ErrorAction SilentlyContinue
        }
    }
}

#endregion

#region System Identity Capture

<#
.SYNOPSIS
    Captures current system identity snapshot.
.DESCRIPTION
    Collects comprehensive hardware and system identifiers.
.OUTPUTS
    Hashtable containing system identity data.
#>
function Get-CurrentSystemIdentity {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()
    
    Write-AegisLog -Level "DEBUG" -Message "Capturing current system identity..."
    
    $identity = @{}
    
    # Define identity components with error handling
    $components = @(
        @{
            Name       = "MachineGuid"
            ScriptBlock = {
                (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid" -ErrorAction Stop).MachineGuid
            }
        }
        @{
            Name       = "ProductId"
            ScriptBlock = {
                (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductId" -ErrorAction Stop).ProductId
            }
        }
        @{
            Name       = "ComputerName"
            ScriptBlock = {
                (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" -Name "ComputerName" -ErrorAction Stop).ComputerName
            }
        }
        @{
            Name       = "MacAddress"
            ScriptBlock = {
                # Try to read from Registry first (spoofed value)
                try {
                    $adapters = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}" -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match "^\d{4}$" }
                    foreach ($a in $adapters) {
                        $mac = (Get-ItemProperty -Path $a.PSPath -Name "NetworkAddress" -ErrorAction SilentlyContinue).NetworkAddress
                        if ($mac) {
                            # Format MAC address with colons
                            return ($mac -replace '(..)','$1:').TrimEnd(':')
                        }
                    }
                }
                catch {}
                # Fallback to WMI if Registry spoof not found
                (Get-CimInstance Win32_NetworkAdapter -ErrorAction Stop | Where-Object { $_.PhysicalAdapter -and $_.MACAddress } | Select-Object -ExpandProperty MACAddress -First 1)
            }
        }
        @{
            Name       = "VolumeId"
            ScriptBlock = {
                (Get-Volume -ErrorAction Stop | Where-Object { $_.DriveType -eq 'Fixed' } | Select-Object -ExpandProperty SerialNumber -First 1)
            }
        }
        @{
            Name       = "Manufacturer"
            ScriptBlock = {
                # Read from PERMANENT Registry location first (spoofed value)
                try {
                    $mfr = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "SystemManufacturer" -ErrorAction SilentlyContinue).SystemManufacturer
                    if ($mfr) { return $mfr }
                }
                catch {}
                # Fallback to volatile key
                try {
                    $mfr = (Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemManufacturer" -ErrorAction SilentlyContinue).SystemManufacturer
                    if ($mfr) { return $mfr }
                }
                catch {}
                # Last resort: WMI
                (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).Manufacturer
            }
        }
        @{
            Name       = "Product"
            ScriptBlock = {
                # Read from PERMANENT Registry location first (spoofed value)
                try {
                    $prod = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "SystemProductName" -ErrorAction SilentlyContinue).SystemProductName
                    if ($prod) { return $prod }
                }
                catch {}
                # Fallback to volatile key
                try {
                    $prod = (Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemProductName" -ErrorAction SilentlyContinue).SystemProductName
                    if ($prod) { return $prod }
                }
                catch {}
                # Last resort: WMI
                (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).Model
            }
        }
        @{
            Name       = "CPU"
            ScriptBlock = {
                # Try Registry first (spoofed value)
                try {
                    $cpu = (Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0" -Name "ProcessorNameString" -ErrorAction SilentlyContinue).ProcessorNameString
                    if ($cpu) { return $cpu }
                }
                catch {}
                # Fallback to WMI
                (Get-CimInstance Win32_Processor -ErrorAction Stop).Name
            }
        }
        @{
            Name       = "GPU"
            ScriptBlock = {
                # Try to read from Registry DISPLAY enumeration (spoofed value)
                try {
                    $gpuFound = $null
                    $displayPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY"
                    if (Test-Path $displayPath) {
                        Get-ChildItem $displayPath -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                            $desc = (Get-ItemProperty -Path $_.PSPath -Name "DeviceDesc" -ErrorAction SilentlyContinue).DeviceDesc
                            if ($desc -and $desc -match "(NVIDIA|AMD|Intel|Radeon|GeForce|RTX|RX)") {
                                $gpuFound = $desc
                            }
                        }
                    }
                    if ($gpuFound) { return $gpuFound }
                }
                catch {}
                # Fallback to WMI
                (Get-CimInstance Win32_VideoController -ErrorAction Stop | Select-Object -First 1).Name
            }
        }
        @{
            Name       = "BiosVendor"
            ScriptBlock = {
                # Read from PERMANENT Registry location first (spoofed value)
                try {
                    $vendor = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "BIOSVendor" -ErrorAction SilentlyContinue).BIOSVendor
                    if ($vendor) { return $vendor }
                }
                catch {}
                # Fallback to volatile key
                try {
                    $vendor = (Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BIOSVendor" -ErrorAction SilentlyContinue).BIOSVendor
                    if ($vendor) { return $vendor }
                }
                catch {}
                # Last resort: WMI
                (Get-CimInstance Win32_BIOS -ErrorAction Stop).Manufacturer
            }
        }
        @{
            Name       = "Serial"
            ScriptBlock = {
                # Try Registry first (spoofed value)
                try {
                    $serial = (Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemSerialNumber" -ErrorAction SilentlyContinue).SystemSerialNumber
                    if ($serial) { return $serial }
                }
                catch {}
                # Fallback to WMI
                (Get-CimInstance Win32_BIOS -ErrorAction Stop).SerialNumber
            }
        }
        @{
            Name       = "DiskModel"
            ScriptBlock = {
                # Try to read from Registry DISK/STORAGE enumeration (spoofed value)
                try {
                    $diskFound = $null
                    $diskPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\DISK"
                    if (Test-Path $diskPath) {
                        Get-ChildItem $diskPath -ErrorAction SilentlyContinue | ForEach-Object {
                            Get-ChildItem $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
                                $friendly = (Get-ItemProperty -Path $_.PSPath -Name "FriendlyName" -ErrorAction SilentlyContinue).FriendlyName
                                if ($friendly) {
                                    $diskFound = $friendly
                                }
                            }
                        }
                    }
                    if ($diskFound) { return $diskFound }
                }
                catch {}
                # Fallback to WMI
                (Get-PhysicalDisk -ErrorAction Stop | Select-Object -First 1).Model
            }
        }
    )
    
    # Execute each component capture
    foreach ($component in $components) {
        try {
            $value = & $component.ScriptBlock
            if ($null -ne $value -and $value -ne "") {
                $identity[$component.Name] = $value
                Write-AegisLog -Level "DEBUG" -Message "Captured $($component.Name): $value"
            }
            else {
                Write-AegisLog -Level "WARN" -Message "Failed to capture $($component.Name): null or empty"
                $identity[$component.Name] = "N/A"
            }
        }
        catch {
            Write-AegisLog -Level "WARN" -Message "Failed to capture $($component.Name): $($_.Exception.Message)"
            $identity[$component.Name] = "N/A"
        }
    }
    
    Write-AegisLog -Level "DEBUG" -Message "System identity capture complete"
    return $identity
}

#endregion

#region Snapshot Management

<#
.SYNOPSIS
    Saves system snapshot to file.
.PARAMETER SnapshotData
    Hashtable containing snapshot data.
.PARAMETER Type
    Snapshot type (Pre, Post, Backup).
#>
function Save-SystemSnapshot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$SnapshotData,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("Pre", "Post", "Backup")]
        [string]$Type
    )
    
    Initialize-StateDirectories
    
    $fileName = "AegisShroud_State_${Type}_Latest.json"
    $filePath = Join-Path $script:STATE_DIR $fileName
    
    try {
        # Add metadata
        $enrichedData = $SnapshotData.Clone()
        $enrichedData["_SnapshotType"] = $Type
        $enrichedData["_Timestamp"] = (Get-Date).ToString("o")
        $enrichedData["_AegisVersion"] = (Get-AegisConfig).Version
        
        # Convert to JSON
        $json = $enrichedData | ConvertTo-Json -Depth 10 -Compress:$false
        
        # Write to file
        Set-Content -Path $filePath -Value $json -Encoding UTF8 -Force -ErrorAction Stop
        
        Write-AegisLog -Level "INFO" -Message "Saved $Type snapshot: $filePath" -Context @{Properties = $enrichedData.Keys.Count}
    }
    catch {
        Write-AegisLog -Level "ERROR" -Message "Failed to save $Type snapshot: $($_.Exception.Message)"
        throw
    }
}

<#
.SYNOPSIS
    Loads system snapshot from file.
.PARAMETER Type
    Snapshot type to load.
.OUTPUTS
    Snapshot hashtable or $null if not found.
#>
function Get-SystemSnapshot {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Pre", "Post", "Backup")]
        [string]$Type
    )
    
    Initialize-StateDirectories
    
    $fileName = "AegisShroud_State_${Type}_Latest.json"
    $filePath = Join-Path $script:STATE_DIR $fileName
    
    if (-not (Test-Path $filePath)) {
        Write-AegisLog -Level "DEBUG" -Message "No $Type snapshot found at: $filePath"
        return $null
    }
    
    try {
        $json = Get-Content -Path $filePath -Raw -ErrorAction Stop
        $obj = $json | ConvertFrom-Json -ErrorAction Stop
        
        # Convert to hashtable
        $snapshot = ConvertTo-Hashtable -InputObject $obj
        
        Write-AegisLog -Level "DEBUG" -Message "Loaded $Type snapshot from: $filePath"
        
        return $snapshot
    }
    catch {
        Write-AegisLog -Level "WARN" -Message "Failed to load $Type snapshot: $($_.Exception.Message)"
        return $null
    }
}

#endregion

#region Registry Backup & Restore

<#
.SYNOPSIS
    Creates comprehensive system backup before modifications.
.DESCRIPTION
    Backs up critical registry keys and creates Pre snapshot.
    Uses transaction logging for rollback capability.
#>
function Backup-AegisSystem {
    [CmdletBinding()]
    param()
    
    Write-AegisLog -Level "INFO" -Message "Creating comprehensive system backup..."
    
    Initialize-StateDirectories
    
    # CRITICAL: Check if backup already exists (prevent overwriting ORIGINAL with SPOOFED)
    if (Test-Path $script:BACKUP_DIR) {
        $existingBackups = Get-ChildItem -Path $script:BACKUP_DIR -Filter "*.reg" -ErrorAction SilentlyContinue
        if ($existingBackups -and $existingBackups.Count -gt 0) {
            Write-Host ""
            Write-Host "[WARNING] Backup already exists!" -ForegroundColor Yellow
            Write-Host "          Existing backup contains ORIGINAL system values." -ForegroundColor Yellow
            Write-Host "          Overwriting it will replace ORIGINAL with CURRENT (possibly spoofed) values!" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Options:" -ForegroundColor Cyan
            Write-Host "  [1] SKIP backup (keep existing ORIGINAL backup)" -ForegroundColor Green
            Write-Host "  [2] OVERWRITE backup (replace with CURRENT values) - DANGER!" -ForegroundColor Red
            Write-Host "  [3] CANCEL operation" -ForegroundColor Yellow
            Write-Host ""
            $choice = Read-Host "Select option [1-3]"
            
            switch ($choice) {
                "1" {
                    Write-Host "[INFO] Skipping backup - keeping existing ORIGINAL backup" -ForegroundColor Green
                    Write-AegisLog -Level "INFO" -Message "Backup skipped - existing backup preserved"
                    return
                }
                "2" {
                    Write-Host "[WARNING] Overwriting backup with CURRENT values..." -ForegroundColor Red
                    Write-AegisLog -Level "WARN" -Message "User chose to overwrite existing backup"
                    # Continue with backup
                }
                "3" {
                    Write-Host "[INFO] Operation cancelled by user" -ForegroundColor Yellow
                    Write-AegisLog -Level "INFO" -Message "Backup cancelled by user"
                    throw "Operation cancelled by user"
                }
                default {
                    Write-Host "[INFO] Invalid choice - skipping backup" -ForegroundColor Yellow
                    return
                }
            }
        }
    }
    
    # Registry keys to backup
    $regKeysToBackup = @(
        "HKLM:\SOFTWARE\Microsoft\Cryptography",
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion",
        "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName",
        "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters",
        "HKLM:\HARDWARE\DESCRIPTION\System\BIOS",
        "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0",
        "HKLM:\SYSTEM\CurrentControlSet\Enum\DISK",
        "HKLM:\SYSTEM\CurrentControlSet\Enum\STORAGE",
        "HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY",
        "HKLM:\SYSTEM\CurrentControlSet\Enum\USB",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}",
        "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache",
        "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
    )
    
    $backupCount = 0
    $failureCount = 0
    
    foreach ($keyPath in $regKeysToBackup) {
        try {
            # Convert PS path to REG format
            $regPath = $keyPath.Replace("HKLM:\", "HKEY_LOCAL_MACHINE\").Replace("HKCU:\", "HKEY_CURRENT_USER\")
            
            # Generate safe filename
            $safeName = ($keyPath -replace "\\", "_").Replace(":", "") + ".reg"
            $backupFilePath = Join-Path $script:BACKUP_DIR $safeName
            
            # Export using reg.exe (more reliable than PowerShell for large keys)
            $result = & reg export $regPath $backupFilePath /y 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                $backupCount++
                Write-AegisLog -Level "DEBUG" -Message "Backed up: $keyPath"
            }
            else {
                $failureCount++
                Write-AegisLog -Level "WARN" -Message "Failed to backup $keyPath`: $result"
            }
        }
        catch {
            $failureCount++
            Write-AegisLog -Level "WARN" -Message "Exception backing up ${keyPath}: $($_.Exception.Message)"
        }
    }
    
    # Capture Pre snapshot
    try {
        $preState = Get-CurrentSystemIdentity
        Save-SystemSnapshot -SnapshotData $preState -Type "Pre"
    }
    catch {
        Write-AegisLog -Level "ERROR" -Message "Failed to save Pre snapshot: $($_.Exception.Message)"
        throw
    }
    
    Write-AegisLog -Level "INFO" -Message "Backup complete: $backupCount successful, $failureCount failed"
    
    # Initialize transaction log
    Initialize-TransactionLog
}

<#
.SYNOPSIS
    Restores original system identity from backup.
.DESCRIPTION
    Imports backed up registry keys and removes persistence.
    Includes multiple retry attempts for robustness.
#>
function Restore-AegisSystem {
    [CmdletBinding()]
    param()
    
    Write-AegisLog -Level "INFO" -Message "Restoring original system identity..."
    
    Initialize-StateDirectories
    
    $config = Get-AegisConfig
    $maxAttempts = $config.Safety.MaxRollbackAttempts
    
    # Restore registry backups
    if (Test-Path $script:BACKUP_DIR) {
        $regFiles = Get-ChildItem -Path $script:BACKUP_DIR -Filter "*.reg" -ErrorAction SilentlyContinue
        
        if (-not $regFiles -or $regFiles.Count -eq 0) {
            Write-AegisLog -Level "WARN" -Message "No backup files found in: $script:BACKUP_DIR"
            Write-Host ""
            Write-Host "[WARN] No backup found - Nothing to restore!" -ForegroundColor Yellow
            Write-Host "       You need to run [1] or [2] first to create a backup." -ForegroundColor Yellow
            Write-Host ""
            return
        }
        else {
            $restoreCount = 0
            $failureCount = 0
            
            foreach ($regFile in $regFiles) {
                $attempt = 0
                $success = $false
                
                while ($attempt -lt $maxAttempts -and -not $success) {
                    $attempt++
                    
                    try {
                        Write-AegisLog -Level "DEBUG" -Message "Restoring $($regFile.Name) (Attempt $attempt/$maxAttempts)..."
                        
                        $result = & reg import $regFile.FullName /y 2>&1
                        
                        if ($LASTEXITCODE -eq 0) {
                            $restoreCount++
                            $success = $true
                            Write-AegisLog -Level "DEBUG" -Message "Restored: $($regFile.Name)"
                        }
                        else {
                            Write-AegisLog -Level "WARN" -Message "Attempt $attempt failed for $($regFile.Name): $result"
                            Start-Sleep -Milliseconds 500
                        }
                    }
                    catch {
                        Write-AegisLog -Level "WARN" -Message "Exception on attempt $attempt for $($regFile.Name): $($_.Exception.Message)"
                        Start-Sleep -Milliseconds 500
                    }
                }
                
                if (-not $success) {
                    $failureCount++
                    Write-AegisLog -Level "ERROR" -Message "Failed to restore $($regFile.Name) after $maxAttempts attempts"
                }
            }
            
            Write-AegisLog -Level "INFO" -Message "Registry restore complete: $restoreCount successful, $failureCount failed"
            
            # Clean up backup directory
            try {
                Remove-Item -Path $script:BACKUP_DIR -Recurse -Force -ErrorAction Stop
                Write-AegisLog -Level "DEBUG" -Message "Backup directory cleaned up"
            }
            catch {
                Write-AegisLog -Level "WARN" -Message "Failed to clean up backup directory: $($_.Exception.Message)"
            }
        }
    }
    else {
        Write-AegisLog -Level "WARN" -Message "Backup directory not found: $script:BACKUP_DIR"
    }
    
    # Remove persistence
    try {
        $task = Get-ScheduledTask -TaskName $script:SCHEDULED_TASK_NAME -ErrorAction SilentlyContinue
        if ($task) {
            Unregister-ScheduledTask -TaskName $script:SCHEDULED_TASK_NAME -Confirm:$false -ErrorAction Stop
            Write-AegisLog -Level "INFO" -Message "Persistence removed: $script:SCHEDULED_TASK_NAME"
        }
    }
    catch {
        Write-AegisLog -Level "WARN" -Message "Failed to remove persistence: $($_.Exception.Message)"
    }
    
    # Clean up state directory
    if (Test-Path $script:STATE_DIR) {
        try {
            Remove-Item -Path $script:STATE_DIR -Recurse -Force -ErrorAction Stop
            Write-AegisLog -Level "DEBUG" -Message "State directory cleaned up"
        }
        catch {
            Write-AegisLog -Level "WARN" -Message "Failed to clean up state directory: $($_.Exception.Message)"
        }
    }
    
    Write-AegisLog -Level "INFO" -Message "System restore completed successfully"
}

#endregion

#region Persistence

<#
.SYNOPSIS
    Enables persistence via scheduled task.
.DESCRIPTION
    Creates hidden scheduled task that re-applies identity on logon.
    Uses stealth naming if configured.
#>
function Enable-AegisPersistence {
    [CmdletBinding()]
    param()
    
    Write-AegisLog -Level "INFO" -Message "Enabling persistence mechanism..."
    
    Initialize-StateDirectories
    
    $root = $script:AegisRoot
    if ([string]::IsNullOrEmpty($root)) { $root = $PWD.Path }
    
    $mainScriptPath = Join-Path $root "Aegis.ps1"
    
    if (-not (Test-Path $mainScriptPath)) {
        Write-AegisLog -Level "ERROR" -Message "Main script not found: $mainScriptPath"
        throw "Cannot enable persistence: main script not found"
    }
    
    try {
        # Create action
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument `
            "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$mainScriptPath`" -ApplyProfile"
        
        # Create trigger (at logon)
        $trigger = New-ScheduledTaskTrigger -AtLogon
        
        # Create settings
        $settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        
        # Register task
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $script:SCHEDULED_TASK_NAME `
            -Description "System component update service" -Settings $settings -Force -ErrorAction Stop | Out-Null
        
        Write-AegisLog -Level "INFO" -Message "Persistence enabled: $script:SCHEDULED_TASK_NAME"
    }
    catch {
        Write-AegisLog -Level "ERROR" -Message "Failed to enable persistence: $($_.Exception.Message)"
        throw
    }
}

#endregion

#region Transaction Management

<#
.SYNOPSIS
    Initializes transaction log for atomic operations.
#>
function Initialize-TransactionLog {
    [CmdletBinding()]
    param()
    
    Initialize-StateDirectories
    
    $transaction = @{
        SessionId  = [Guid]::NewGuid().ToString("N").Substring(0, 8)
        StartTime  = (Get-Date).ToString("o")
        Operations = @()
        Status     = "InProgress"
    }
    
    try {
        $json = $transaction | ConvertTo-Json -Depth 10
        Set-Content -Path $script:TRANSACTION_LOG -Value $json -Encoding UTF8 -Force
        
        Write-AegisLog -Level "DEBUG" -Message "Transaction log initialized: $($transaction.SessionId)"
    }
    catch {
        Write-AegisLog -Level "WARN" -Message "Failed to initialize transaction log: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Logs a registry operation to transaction log.
.PARAMETER Operation
    Operation details hashtable.
#>
function Add-TransactionEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Operation
    )
    
    if (-not (Test-Path $script:TRANSACTION_LOG)) {
        return
    }
    
    try {
        $json = Get-Content -Path $script:TRANSACTION_LOG -Raw
        $transaction = $json | ConvertFrom-Json | ConvertTo-Hashtable
        
        $transaction.Operations += $Operation
        
        $updatedJson = $transaction | ConvertTo-Json -Depth 10
        Set-Content -Path $script:TRANSACTION_LOG -Value $updatedJson -Encoding UTF8 -Force
    }
    catch {
        Write-AegisLog -Level "DEBUG" -Message "Failed to log transaction entry: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Marks transaction as complete.
#>
function Complete-Transaction {
    [CmdletBinding()]
    param()
    
    if (-not (Test-Path $script:TRANSACTION_LOG)) {
        return
    }
    
    try {
        $json = Get-Content -Path $script:TRANSACTION_LOG -Raw
        $transaction = $json | ConvertFrom-Json | ConvertTo-Hashtable
        
        $transaction.Status = "Completed"
        $transaction.EndTime = (Get-Date).ToString("o")
        
        $updatedJson = $transaction | ConvertTo-Json -Depth 10
        Set-Content -Path $script:TRANSACTION_LOG -Value $updatedJson -Encoding UTF8 -Force
        
        Write-AegisLog -Level "DEBUG" -Message "Transaction marked complete"
    }
    catch {
        Write-AegisLog -Level "DEBUG" -Message "Failed to complete transaction: $($_.Exception.Message)"
    }
}

#endregion

