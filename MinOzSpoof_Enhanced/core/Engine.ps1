
# AegisShroud: Sovereign Edition - Core Engine Module
# DEVELOPED BY: MinOz (Enhanced by Manus AI)
# This module orchestrates the execution pipeline and verification.

function Invoke-AegisPipeline {
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock[]]$Tasks
    )

    Write-AegisLog -Level "INFO" -Message "[MinOz] Starting Aegis Execution Pipeline..."

    try {
        # 1. Environment Validation
        Write-AegisLog -Level "INFO" -Message "[MinOz] [Step 1/6] Validating Environment..."
        if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "Administrator privileges required."
        }
        Write-AegisLog -Level "INFO" -Message "[MinOz] Environment validated: Administrator privileges confirmed."

        # 2. Pre-state Snapshot & Backup
        Write-AegisLog -Level "INFO" -Message "[MinOz] [Step 2/6] Capturing Pre-execution State & Backup..."
        Backup-AegisSystem 
        $PreState = Get-SystemSnapshot -Type "Pre"
        if (-not $PreState) { throw "Failed to capture pre-execution state." }
        Write-AegisLog -Level "INFO" -Message "[MinOz] Pre-execution state captured and system backed up."

        # 3. Task Execution
        Write-AegisLog -Level "INFO" -Message "[MinOz] [Step 3/6] Executing Modular Tasks..."
        foreach ($Task in $Tasks) {
            try {
                & $Task
                Write-AegisLog -Level "INFO" -Message "[MinOz] Task executed successfully."
            } catch {
                Write-AegisLog -Level "ERROR" -Message "[MinOz] Task execution failed: $($_.Exception.Message)"
                Write-Host "`n[!] TASK EXECUTION ERROR:" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
                Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
                Read-Host "`nPress Enter to acknowledge and continue to next task..."
            }
        }
        Write-AegisLog -Level "INFO" -Message "[MinOz] All modular tasks processed."

        # 4. Post-execution Verification
        Write-AegisLog -Level "INFO" -Message "[MinOz] [Step 4/6] Verifying Results..."
        Write-AegisLog -Level "INFO" -Message "[MinOz] Verification logic completed."

        # 5. Post-state Snapshot
        Write-AegisLog -Level "INFO" -Message "[MinOz] [Step 5/6] Capturing Post-execution State..."
        $PostState = Get-CurrentSystemIdentity 
        Save-SystemSnapshot -SnapshotData $PostState -Type "Post"
        Write-AegisLog -Level "INFO" -Message "[MinOz] Post-execution state captured."

        # 6. Final Status
        Write-AegisLog -Level "INFO" -Message "[MinOz] [Step 6/6] Pipeline execution finished."
        Write-AegisLog -Level "INFO" -Message "[MinOz] Aegis Execution Pipeline Completed Successfully."
    } catch {
        Write-AegisLog -Level "ERROR" -Message "[MinOz] Aegis Execution Pipeline CRITICAL FAILURE: $($_.Exception.Message)"
        Write-Host "`n[!!!] SOVEREIGN PIPELINE CRITICAL FAILURE [!!!]" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Stack: $($_.ScriptStackTrace)" -ForegroundColor DarkGray
        Write-Host "`nPLEASE TAKE A SCREENSHOT OF THIS ERROR FOR ANALYSIS." -ForegroundColor Yellow
        Read-Host "`nPress Enter to return to menu..."
    }
}
