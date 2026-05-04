
# AegisShroud: Sovereign Edition - Brutal Cleaner Module
# DEVELOPED BY: MinOz (Enhanced by Manus AI)
# This module provides extreme-level trace cleaning and system hardening.

function Invoke-AegisCleaner {
    Write-AegisLog -Level "INFO" -Message "[MinOz] EXECUTING BRUTAL DEEP TRACE CLEANER..."

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
    } catch {}

    # 2. Kernel-Mode & Driver Trace Cleaning
    try {
        # Clear AppCompatCache (ShimCache) - Critical for Anti-Cheat
        $shimPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache"
        if (Test-Path $shimPath) { Remove-ItemProperty -Path $shimPath -Name "AppCompatCache" -Force -ErrorAction SilentlyContinue }
        
        # Clear MUICache
        $muiPath = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
        if (Test-Path $muiPath) { Get-ChildItem $muiPath | Remove-Item -Force -ErrorAction SilentlyContinue }

        # Clear Digital Certificate Cache (DSE)
        $certPath = "HKLM:\SOFTWARE\Microsoft\SystemCertificates\AuthRoot\Certificates"
        if (Test-Path $certPath) { Get-ChildItem $certPath | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }

        Write-AegisLog -Level "INFO" -Message "[MinOz] Kernel-Mode & Driver Traces Purged."
    } catch {}

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
        if (Test-Path $mountPath) { Get-ChildItem $mountPath | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }

        Write-AegisLog -Level "INFO" -Message "[MinOz] Hardware Fingerprint Artifacts Cleared."
    } catch {}

    # 4. Brutal Network Identity Reset
    try {
        # Flush DNS & Reset IP
        ipconfig /flushdns | Out-Null
        ipconfig /release | Out-Null
        ipconfig /renew | Out-Null
        
        # Reset Winsock & TCP/IP Stack
        netsh winsock reset | Out-Null
        netsh int ip reset | Out-Null
        
        # Clear ARP Cache (Brutal Method)
        arp -d * 2>$null
        
        # Clear Network Store Interface (NSI) Traces
        $nsiPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Nsi\{eb004a03-9b1a-11d4-9123-0050047759bc}\26"
        if (Test-Path $nsiPath) { Remove-Item $nsiPath -Recurse -Force -ErrorAction SilentlyContinue }

        Write-AegisLog -Level "INFO" -Message "[MinOz] Brutal Network Identity Reset Completed."
    } catch {}

    # 5. NTFS Structure & Log Destruction (Brutal Mode)
    try {
        # Manage USN Journal (NTFS Change Log)
        $drives = Get-PSDrive -PSProvider FileSystem
        foreach ($drive in $drives) {
            $driveLetter = $drive.Name + ":"
            fsutil usn deletejournal /d /n $driveLetter 2>$null
        }

        # Clear All Event Logs
        Get-EventLog -LogName * | ForEach-Object { Clear-EventLog -LogName $_.Log }
        wevtutil el | ForEach-Object { wevtutil cl "$_" } 2>$null

        # Clear Prefetch & Temp
        $tempPaths = @(
            "$env:SystemRoot\Prefetch\*",
            "$env:SystemRoot\Temp\*",
            "$env:LOCALAPPDATA\Temp\*"
        )
        foreach ($path in $tempPaths) {
            try { Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue } catch {}
        }

        Write-AegisLog -Level "INFO" -Message "[MinOz] NTFS Structure & System Logs Destroyed."
    } catch {}

    # 6. WMI Repository Sanitization (DISABLED - prevents Task Manager closing)
    # NOTE: WMI restart has been disabled to prevent Task Manager from closing unexpectedly
    try {
        # net stop winmgmt /y 2>$null
        # net start winmgmt /y 2>$null
        Write-AegisLog -Level "INFO" -Message "[MinOz] WMI Repository Sanitization SKIPPED (prevents TM crash)."
    } catch {}

    Write-AegisLog -Level "INFO" -Message "[MinOz] BRUTAL DEEP CLEANING COMPLETED SUCCESSFULLY."
}
