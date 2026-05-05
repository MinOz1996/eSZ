# AegisShroud: Sovereign Edition - USN Journal & Deep Trace Purger Module v3.0
# DEVELOPED BY: THE ARCHITECT ELITE SYSTEM

function Invoke-USNPurger { return Invoke-USNJournalPurger }
function Invoke-USNJournalPurger {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[Elite] Invoking Deep Trace Purger (ACE/Tencent Special)..."

    try {
        # 1. USN Journal Purging (Critical for File History)
        Write-AegisLog -Level "DEBUG" -Message "[Elite] Obliterating USN Journal for all fixed drives..."
        try {
            $fixedDrives = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue
            if ($fixedDrives) {
                foreach ($disk in $fixedDrives) {
                    $driveLetter = $disk.DeviceID
                    try {
                        # Create and Delete Journal to wipe history
                        & fsutil usn deletejournal /d /n $driveLetter 2>&1 | Out-Null
                        & fsutil usn createjournal m=1000 a=100 $driveLetter 2>&1 | Out-Null
                        Write-AegisLog -Level "DEBUG" -Message "[Elite] USN history wiped for ${driveLetter}:"
                    } catch {}
                }
            }
        } catch {}

        # 2. ACE Anti-Cheat Specific Traces (Tencent Hidden Files)
        Write-AegisLog -Level "DEBUG" -Message "[Elite] Hunting for ACE/Tencent hidden artifacts..."
        $acePaths = @(
            "$env:ProgramData\Tencent",
            "$env:SystemDrive\Users\Public\Documents\Tencent",
            "$env:SystemDrive\Users\Public\Tencent",
            "$env:LOCALAPPDATA\Tencent",
            "$env:APPDATA\Tencent",
            "$env:SystemRoot\SysWOW64\Drivers\ACE-Base.sys",
            "$env:SystemRoot\System32\Drivers\ACE-Base.sys"
        )
        foreach ($path in $acePaths) {
            if (Test-Path $path) {
                try {
                    Takeown /F $path /R /D Y 2>&1 | Out-Null
                    Icacls $path /grant administrators:F /T 2>&1 | Out-Null
                    Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
                    Write-AegisLog -Level "INFO" -Message "[Elite] Obliterated ACE artifact: $path"
                } catch {}
            }
        }

        # 3. Windows Cryptographic GUIDs (Re-randomize MachineGuid if needed)
        # Note: Identity.ps1 handles MachineGuid, but we ensure it's not cached in other places

        # 4. Standard Traces (Prefetch, Temp, Logs)
        Write-AegisLog -Level "DEBUG" -Message "[Elite] Purging standard Windows forensic traces..."
        $stdPaths = @(
            "$env:SystemRoot\Prefetch\*",
            "$env:TEMP\*",
            "$env:SystemRoot\Temp\*",
            "$env:LOCALAPPDATA\Microsoft\Windows\History\*",
            "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*"
        )
        foreach ($path in $stdPaths) {
            try {
                Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            } catch {}
        }

        Write-AegisLog -Level "INFO" -Message "[Elite] Deep Trace Purger completed successfully."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[Elite] Deep Trace Purger encountered minor issues: $($_.Exception.Message)"
    }
}

function Remove-USNJournalPurger {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[Elite] Deep Trace Purge is permanent."
}
