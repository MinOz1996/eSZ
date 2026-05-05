# AegisShroud: Sovereign Edition - USN Journal & Deep Trace Purger Module

function Invoke-USNJournalPurger {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[MinOz] Invoking USN Journal & Deep Trace Purger..."

    try {
        # FIX: ใช้ Get-WmiObject Win32_LogicalDisk แทน Get-PSDrive (ไม่มี .DriveType)
        Write-AegisLog -Level "DEBUG" -Message "[MinOz] Clearing USN Journal for all fixed drives..."
        try {
            $fixedDrives = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue
            if ($fixedDrives) {
                foreach ($disk in $fixedDrives) {
                    $driveLetter = $disk.DeviceID  # e.g. "C:"
                    try {
                        $result = & fsutil usn deletejournal /d /n $driveLetter 2>&1
                        Write-AegisLog -Level "DEBUG" -Message "[MinOz] USN cleared for ${driveLetter}: $result"
                    } catch {
                        Write-AegisLog -Level "WARN" -Message "[MinOz] USN clear failed for ${driveLetter}: $($_.Exception.Message)"
                    }
                }
            }
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] USN Journal purge skipped: $($_.Exception.Message)"
        }

        # Clear Prefetch files
        Write-AegisLog -Level "DEBUG" -Message "[MinOz] Clearing Prefetch files..."
        try {
            Remove-Item "$env:SystemRoot\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-AegisLog -Level "INFO" -Message "[MinOz] Prefetch files cleared."
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Prefetch clear failed: $($_.Exception.Message)"
        }

        # Clear Temporary files
        Write-AegisLog -Level "DEBUG" -Message "[MinOz] Clearing temporary files..."
        $tempPaths = @(
            "$env:TEMP\*",
            "$env:LOCALAPPDATA\Temp\*",
            "$env:SystemRoot\Temp\*"
        )
        foreach ($path in $tempPaths) {
            try {
                Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] Cleared: $path"
            } catch {
                Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to clear ${path}: $($_.Exception.Message)"
            }
        }

        Write-AegisLog -Level "INFO" -Message "[MinOz] USN Journal & Deep Trace Purger completed."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] USN Journal Purger partial: $($_.Exception.Message)"
        # ไม่ throw เพื่อไม่ให้ block operation อื่น
    }
}

function Remove-USNJournalPurger {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[MinOz] USN Journal Purger: clean is permanent, no undo."
}
