
# AegisShroud: Sovereign Edition - USN Journal & Deep Trace Purger Module
# DEVELOPED BY: Manus AI
# Provides advanced deep trace cleaning, including USN Journal, Prefetch, and Superfetch.

function Invoke-USNJournalPurger {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[Manus AI] Invoking USN Journal & Deep Trace Purger..."

    try {
        # Clear USN Journal (NTFS Change Log) for all fixed drives
        Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Clearing USN Journal for all fixed drives..."
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DriveType -eq 'Fixed' }
        foreach ($drive in $drives) {
            $driveLetter = $drive.Name + ":"
            try {
                fsutil usn deletejournal /d /n $driveLetter 2>$null
                Write-AegisLog -Level "DEBUG" -Message "[Manus AI] USN Journal cleared for drive $driveLetter"
            } catch {
                Write-AegisLog -Level "WARN" -Message "[Manus AI] Failed to clear USN Journal for drive $driveLetter: $($_.Exception.Message)"
            }
        }

        # Clear Prefetch files
        Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Clearing Prefetch files..."
        try {
            Remove-Item "$env:SystemRoot\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-AegisLog -Level "INFO" -Message "[Manus AI] Prefetch files cleared."
        } catch {
            Write-AegisLog -Level "WARN" -Message "[Manus AI] Failed to clear Prefetch files: $($_.Exception.Message)"
        }

        # Clear Superfetch data (if applicable, though often managed by Prefetch)
        # Superfetch is typically managed by the Prefetcher service, clearing prefetch usually covers this.
        # For completeness, we can stop/start the service, but direct file deletion is more impactful.
        # try {
        #     Stop-Service -Name "SysMain" -ErrorAction SilentlyContinue
        #     # No direct files to delete, relies on service restart to rebuild
        #     Start-Service -Name "SysMain" -ErrorAction SilentlyContinue
        #     Write-AegisLog -Level "INFO" -Message "[Manus AI] Superfetch service restarted."
        # } catch {
        #     Write-AegisLog -Level "WARN" -Message "[Manus AI] Failed to restart Superfetch service: $($_.Exception.Message)"
        # }

        # Clear Temporary files (more aggressive)
        Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Clearing temporary files..."
        $tempPaths = @(
            "$env:TEMP\*",
            "$env:LOCALAPPDATA\Temp\*",
            "$env:SystemRoot\Temp\*"
        )
        foreach ($path in $tempPaths) {
            try {
                Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
                Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Cleared temp path: $path"
            } catch {
                Write-AegisLog -Level "WARN" -Message "[Manus AI] Failed to clear temp path $path: $($_.Exception.Message)"
            }
        }
        Write-AegisLog -Level "INFO" -Message "[Manus AI] Temporary files cleared."

        Write-AegisLog -Level "INFO" -Message "[Manus AI] USN Journal & Deep Trace Purger completed."
    } catch {
        Write-AegisLog -Level "ERROR" -Message "[Manus AI] USN Journal & Deep Trace Purger failed: $($_.Exception.Message)"
        throw
    }
}

function Remove-USNJournalPurger {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[Manus AI] USN Journal Purger does not have specific 'undo' actions. Cleaning is permanent."
    # No direct undo for clearing journals/prefetch. This is a destructive clean.
}
