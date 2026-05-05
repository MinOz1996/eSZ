# MinOz GHOST PROTOCOL (2026) - Deep Cleaner Module v3.0 Ultimate Elite
# DEVELOPED BY: THE ARCHITECT ELITE SYSTEM
# FEATURE: Arduino/USB Trace Obliteration & ACE Log Purge.

function Invoke-DeepClean {
    [CmdletBinding()]
    param()

    Write-AegisLog -Level "INFO" -Message "Initiating Elite Deep Cleaning Sequence..."

    # 1. ACE (Anti-Cheat Expert) / Tencent Specific Traces
    Write-AegisLog -Level "INFO" -Message "Obliterating ACE/Tencent Anti-Cheat traces..."
    $acePaths = @(
        "$env:SystemDrive\Users\Public\Documents\Tencent",
        "$env:AppData\Tencent",
        "$env:LocalAppData\Tencent",
        "$env:ProgramData\Tencent",
        "$env:SystemRoot\System32\Drivers\ACE-BASE.sys",
        "$env:SystemRoot\System32\Drivers\TesSafe.sys",
        "$env:SystemRoot\System32\Drivers\SGuard64.sys",
        "$env:SystemRoot\System32\Drivers\SGuardLib64.sys",
        "$env:LocalAppData\Tencent\TencentLink",
        "$env:AppData\Tencent\TencentLink"
    )
    foreach ($path in $acePaths) {
        if (Test-Path $path) {
            try { 
                Takeown-File -Path $path
                Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue 
            } catch {}
        }
    }

    # 2. USB & Arduino Trace Obliteration (Brutal History Wipe)
    Write-AegisLog -Level "INFO" -Message "Obliterating USB/Arduino device history..."
    $usbKeys = @(
        "HKLM:\SYSTEM\CurrentControlSet\Enum\USB",
        "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR",
        "HKLM:\SYSTEM\CurrentControlSet\Enum\HID",
        "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceClasses"
    )
    
    foreach ($key in $usbKeys) {
        if (Test-Path $key) {
            Get-ChildItem -Path $key -ErrorAction SilentlyContinue | ForEach-Object {
                # Target common Arduino VIDs (2341, 1A86, 0403, 10C4) and generic history
                if ($_.PSChildName -match "VID_2341" -or $_.PSChildName -match "VID_1A86" -or $_.PSChildName -match "VID_0403" -or $_.PSChildName -match "VID_10C4") {
                    try { 
                        # Registry permission might be needed for Enum subkeys
                        Remove-Item -Path $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue 
                    } catch {}
                }
            }
        }
    }

    # 3. SetupAPI Log Purge (Critical for HWID change detection)
    Write-AegisLog -Level "INFO" -Message "Purging SetupAPI device installation logs..."
    $logFiles = @(
        "$env:SystemRoot\inf\setupapi.dev.log",
        "$env:SystemRoot\inf\setupapi.setup.log",
        "$env:SystemRoot\inf\setupapi.offline.log",
        "$env:SystemRoot\inf\setupapi.app.log"
    )
    foreach ($log in $logFiles) {
        if (Test-Path $log) {
            try { 
                Clear-Content -Path $log -ErrorAction SilentlyContinue
                Remove-Item -Path $log -Force -ErrorAction SilentlyContinue
                # Re-create as empty file to avoid system errors
                New-Item -Path $log -ItemType File -Force | Out-Null
            } catch {}
        }
    }

    # 4. Windows Event Logs (Security & System)
    Write-AegisLog -Level "INFO" -Message "Clearing Windows Event Logs..."
    try {
        Get-EventLog -LogName * | ForEach-Object { Clear-EventLog -LogName $_.Log }
    } catch {}

    # 5. Network & DNS Flush
    Write-AegisLog -Level "INFO" -Message "Flushing network cache and DNS..."
    try {
        & ipconfig /flushdns | Out-Null
        & netsh winsock reset | Out-Null
        & netsh int ip reset | Out-Null
    } catch {}

    Write-AegisLog -Level "INFO" -Message "Elite Deep Cleaning Sequence Completed."
}

function Takeown-File {
    param([string]$Path)
    try {
        & takeown /f "$Path" /r /d y | Out-Null
        & icacls "$Path" /grant administrators:F /t | Out-Null
    } catch {}
}

function Invoke-AegisCleaner {
    Invoke-DeepClean
}
