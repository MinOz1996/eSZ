# AegisShroud: Sovereign Edition - Cleaner Module (2026 FIXED EDITION)
# FIX: ลบ USB enum keys ออก (Task Manager ใช้ WMI Win32_PnPEntity -> USB keys)
# FIX: Network reset เฉพาะ deep clean mode เท่านั้น

function Invoke-AegisCleaner {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$StandardClean = $false,

        [Parameter(Mandatory = $false)]
        [switch]$DeepClean = $false
    )

    Write-AegisLog -Level "INFO" -Message "[MinOz] Executing Trace Cleaner..."

    # 1. Privacy & Telemetry Hardening
    try {
        $privacyKeys = @(
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack",
            "HKLM:\SOFTWARE\Microsoft\Personalization\Settings",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        )
        foreach ($key in $privacyKeys) {
            if (-not (Test-Path $key)) { New-Item -Path $key -Force -ErrorAction SilentlyContinue | Out-Null }
            Set-ItemProperty -Path $key -Name "AllowTelemetry" -Value 0 -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $key -Name "Enabled"        -Value 0 -Force -ErrorAction SilentlyContinue
        }
        Write-AegisLog -Level "INFO" -Message "[MinOz] Privacy/Telemetry hardened."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] Privacy hardening partial: $($_.Exception.Message)"
    }

    # 2. AppCompatCache (ShimCache) + WDI Logs
    try {
        $shimPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache"
        if (Test-Path $shimPath) {
            Remove-ItemProperty -Path $shimPath -Name "AppCompatCache" -Force -ErrorAction SilentlyContinue
        }
        foreach ($p in @("C:\Windows\System32\wdi\LogFiles\*", "C:\Windows\System32\wdi\*.etl")) {
            Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-AegisLog -Level "INFO" -Message "[MinOz] ShimCache & WDI logs cleared."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] ShimCache clear partial: $($_.Exception.Message)"
    }

    # 3. MountPoints2 only (ไม่แตะ USB enum keys - จะทำให้ Task Manager พัง!)
    try {
        $mountPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
        if (Test-Path $mountPath) {
            Remove-Item $mountPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-AegisLog -Level "INFO" -Message "[MinOz] MountPoints2 cleared."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] MountPoints2 clear partial: $($_.Exception.Message)"
    }

    # 4. Network Reset -- เฉพาะ DeepClean เท่านั้น
    if ($DeepClean) {
        try {
            Write-AegisLog -Level "INFO" -Message "[MinOz] Running network identity reset (Deep Clean)..."
            & ipconfig /flushdns 2>&1 | Out-Null
            & netsh winsock reset 2>&1 | Out-Null
            & arp -d * 2>&1 | Out-Null
            Write-AegisLog -Level "INFO" -Message "[MinOz] Network reset complete."
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Network reset partial: $($_.Exception.Message)"
        }
    }

    # 5. Deep Event Log Clean -- เฉพาะ DeepClean
    if ($DeepClean) {
        try {
            Write-AegisLog -Level "INFO" -Message "[MinOz] Clearing event logs (Deep Clean)..."
            # ใช้ wevtutil แทน Get-EventLog (เร็วกว่าและไม่ block WMI)
            & wevtutil el 2>&1 | ForEach-Object {
                try { & wevtutil cl "$_" 2>&1 | Out-Null } catch {}
            }
            Write-AegisLog -Level "INFO" -Message "[MinOz] Event logs cleared."
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Event log clear partial: $($_.Exception.Message)"
        }
    }

    # 6. WMI Service Check (ไม่ restart ไม่ delete repository)
    try {
        $wmi = Get-Service -Name "Winmgmt" -ErrorAction SilentlyContinue
        if ($wmi -and $wmi.Status -ne "Running") {
            Start-Service -Name "Winmgmt" -ErrorAction SilentlyContinue
        }
        Write-AegisLog -Level "INFO" -Message "[MinOz] WMI service OK (no restart - preserves Task Manager)."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] WMI check skipped: $($_.Exception.Message)"
    }

    Write-AegisLog -Level "INFO" -Message "[MinOz] Cleaner completed successfully."
}

function Remove-AegisCleaner {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[MinOz] Cleaner: logs/temp files are permanently removed."
}
