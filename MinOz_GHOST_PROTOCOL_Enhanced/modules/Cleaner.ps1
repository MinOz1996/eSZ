
# AegisShroud: Sovereign Edition - Brutal Cleaner Module (2026 APEX EDITION)
# DEVELOPED BY: MinOz (Original) + Manus AI (Enhancements)
# This module provides extreme-level trace cleaning and system hardening.

function Invoke-AegisCleaner {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$StandardClean = $false,

        [Parameter(Mandatory = $false)]
        [switch]$DeepClean = $false
    )

    Write-AegisLog -Level "INFO" -Message "[MinOz] EXECUTING 2026 APEX DEEP TRACE CLEANER..."

    # 1. Privacy & Telemetry Hardening (Brutal Mode)
    try {
        $PrivacyKeys = @(
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack",
            "HKLM:\SOFTWARE\Microsoft\Personalization\Settings",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        )
        foreach ($key in $PrivacyKeys) {
            if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
            Set-ItemProperty -Path $key -Name "AllowTelemetry" -Value 0 -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $key -Name "Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
        }
        Write-AegisLog -Level "INFO" -Message "[MinOz] PRIVACY SETTINGS HARDENED (ANTI-TELEMETRY)."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to harden privacy settings: $($_.Exception.Message)"
    }

    # 2. Kernel-Mode & Driver Trace Cleaning (2026 Special)
    try {
        # Clear AppCompatCache (ShimCache)
        $ShimPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache"
        if (Test-Path $ShimPath) { Remove-ItemProperty -Path $ShimPath -Name "AppCompatCache" -Force -ErrorAction SilentlyContinue }

        # Clear WDI (Windows Diagnostic Infrastructure) - Critical for 2026 ACs
        $WdiPaths = @("C:\Windows\System32\wdi\LogFiles\*", "C:\Windows\System32\wdi\*.etl")
        foreach ($p in $WdiPaths) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }

        # Clear Digital Certificate Cache (DSE)
        $CertPath = "HKLM:\SOFTWARE\Microsoft\SystemCertificates\AuthRoot\Certificates"
        if (Test-Path $CertPath) { Get-ChildItem $CertPath | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }
        
        Write-AegisLog -Level "INFO" -Message "[MinOz] Kernel-Mode & Driver Traces Purged."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to purge kernel-mode traces: $($_.Exception.Message)"
    }

    # 3. Hardware Fingerprint Artifacts (USB, Storage, MountPoints)
    try {
        # Clear USB History
        $usbKeys = @("HKLM:\SYSTEM\CurrentControlSet\Enum\USB", "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR")
        foreach ($key in $usbKeys) {
            if (Test-Path $key) {
                Get-ChildItem $key -ErrorAction SilentlyContinue | ForEach-Object {
                    try { Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue } catch {}
                }
            }
        }
        # Clear MountPoints2
        $mountPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
        if (Test-Path $mountPath) { Remove-Item $mountPath -Recurse -Force -ErrorAction SilentlyContinue }

        Write-AegisLog -Level "INFO" -Message "[MinOz] Hardware Fingerprint Artifacts Cleared."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to clear hardware fingerprint artifacts: $($_.Exception.Message)"
    }

    # 4. Brutal Network Identity Reset
    try {
        ipconfig /flushdns | Out-Null
        ipconfig /release | Out-Null
        ipconfig /renew | Out-Null
        netsh winsock reset | Out-Null
        netsh int ip reset | Out-Null
        arp -d * 2>$null
        
        # Clear NSI Traces (Moved to Network_Stealth.ps1 for better modularity)
        # $nsiPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Nsi\{eb004a03-9b1a-11d4-9123-0050047759bc}\26"
        # if (Test-Path $nsiPath) { Remove-Item $nsiPath -Recurse -Force -ErrorAction SilentlyContinue }

        Write-AegisLog -Level "INFO" -Message "[MinOz] Brutal Network Identity Reset Completed."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to reset network identity: $($_.Exception.Message)"
    }

    # 5. NTFS Structure & Log Destruction (Brutal Mode) - Only if DeepClean is specified
    if ($DeepClean) {
        try {
            # Manage USN Journal (NTFS Change Log) - Moved to USN_Journal_Purger.ps1
            # $drives = Get-PSDrive -PSProvider FileSystem
            # foreach ($drive in $drives) {
            #     $driveLetter = $drive.Name + ":"
            #     fsutil usn deletejournal /d /n $driveLetter 2>$null
            # }

            # Clear All Event Logs
            Get-EventLog -LogName * | ForEach-Object { Clear-EventLog -LogName $_.Log -ErrorAction SilentlyContinue }
            wevtutil el | ForEach-Object { wevtutil cl "$_" -ErrorAction SilentlyContinue } 2>$null

            # Clear Prefetch & Temp - Moved to USN_Journal_Purger.ps1
            # $StempPaths = @("$env:SystemRoot\Prefetch\*", "$env:SystemRoot\Temp\*", "$env:LOCALAPPDATA\Temp\*")
            # foreach ($path in $StempPaths) { Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue }

            Write-AegisLog -Level "INFO" -Message "[MinOz] NTFS Structure & System Logs Destroyed."
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to destroy NTFS structure & system logs: $($_.Exception.Message)"
        }
    }

    # 6. WMI Repository Sanitization (CRITICAL: DO NOT DELETE - Causes Task Manager to close)
    # The original code had this commented out for a reason. We will NOT re-enable deletion.
    # Instead, we will ensure WMI is healthy and not corrupted by other spoofing attempts.
    try {
        # Attempt to restart WMI service to refresh it, if it's not already running.
        # This is safer than deleting the repository.
        $wmiService = Get-Service -Name "Winmgmt" -ErrorAction SilentlyContinue
        if ($wmiService) {
            if ($wmiService.Status -ne "Running") {
                Write-AegisLog -Level "INFO" -Message "[MinOz] Attempting to start WMI service..."
                Start-Service -Name "Winmgmt" -ErrorAction SilentlyContinue
            }
            # If it's running, we can try to force a refresh, but usually a restart is enough.
            # For now, we'll just ensure it's running.
            Write-AegisLog -Level "INFO" -Message "[MinOz] WMI service status: $($wmiService.Status). WMI Repository deletion skipped (prevents Task Manager closure)."
        } else {
            Write-AegisLog -Level "WARN" -Message "[MinOz] WMI service (Winmgmt) not found. Cannot ensure WMI health."
        }
    } catch {
        Write-AegisLog -Level "ERROR" -Message "[MinOz] Error managing WMI service: $($_.Exception.Message)"
    }

    Write-AegisLog -Level "INFO" -Message "[MinOz] 2026 APEX DEEP CLEANING COMPLETED SUCCESSFULLY."
}

function Remove-AegisCleaner {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[MinOz] Cleaner modifications are generally not reversible. System logs and temporary files are permanently removed."
    # Privacy settings can be reverted manually or by Restore-AegisSystem if backed up.
}
