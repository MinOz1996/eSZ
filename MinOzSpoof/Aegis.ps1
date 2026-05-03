
# AegisShroud: Sovereign Edition - Main Entry Point
# DEVELOPED BY: MinOz (Enhanced by Manus AI)
# The Most Advanced System Hardening, Identity Virtualization & Trace Cleaning Suite

#region Parameters
param(
    [switch]$ApplyProfile,
    [string]$ProfilePath
)
#endregion

#region Strict Mode and Error Handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
#endregion

#region Path Initialization (Expert Level)
# Use a more robust way to get the script root that works in ISE and standard shell
$script:AegisRoot = $PSScriptRoot
if ([string]::IsNullOrEmpty($script:AegisRoot)) {
    $script:AegisRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
}
if ([string]::IsNullOrEmpty($script:AegisRoot)) {
    $script:AegisRoot = Get-Location
}
#endregion

#region Load Core Components
# Load Logger first so other components can use it
. (Join-Path $script:AegisRoot "core\Logger.ps1")
. (Join-Path $script:AegisRoot "core\ConfigManager.ps1")
. (Join-Path $script:AegisRoot "core\StateManager.ps1")
. (Join-Path $script:AegisRoot "core\Engine.ps1")

# Load Utilities
. (Join-Path $script:AegisRoot "utils\Helpers.ps1")

# Load Modules
. (Join-Path $script:AegisRoot "modules\Identity.ps1")
. (Join-Path $script:AegisRoot "modules\Cleaner.ps1")

# Load CLI
. (Join-Path $script:AegisRoot "cli\Interface.ps1")
#endregion

#region Main Logic
function Start-Aegis {
    # Check for Administrator privileges at entry point
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] ADMINISTRATOR PRIVILEGES REQUIRED! Please run PowerShell as Administrator." -ForegroundColor Red
        Write-AegisLog -Level "ERROR" -Message "Administrator privileges required. Exiting."
        exit 1
    }

    # Initialize Config
    Get-AegisConfig
    Write-AegisLog -Level "INFO" -Message "[MinOz] AegisShroud Sovereign Edition Started."

    # Handle -ApplyProfile switch for persistence
    if ($ApplyProfile) {
        Write-AegisLog -Level "INFO" -Message "[MinOz] Running in persistence mode (-ApplyProfile)."
        try {
            $PostState = Get-SystemSnapshot -Type "Post"
            if ($PostState) {
                Apply-AegisIdentity -Identity $PostState # Re-apply the last known spoofed identity
                Invoke-AegisCleaner # Re-clean traces
                Write-AegisLog -Level "INFO" -Message "[MinOz] Persistent identity re-applied and traces re-cleaned."
            } else {
                Write-AegisLog -Level "WARN" -Message "[MinOz] No previous Post-state found for persistence. Skipping identity re-application."
            }
        } catch {
            Write-AegisLog -Level "ERROR" -Message "[MinOz] Error during persistence application: $($_.Exception.Message)"
        }
        exit 0
    }

    while ($true) {
        $choice = Show-AegisMenu
        switch ($choice) {
            "1" { # FULL PROTECTION
                Write-AegisLog -Level "INFO" -Message "[MinOz] User selected FULL PROTECTION."
                $tasks = @(
                    { $id = New-AegisIdentity; Apply-AegisIdentity -Identity $id },
                    { Invoke-AegisCleaner },
                    { Enable-AegisPersistence }
                )
                Invoke-AegisPipeline -Tasks $tasks
                Write-Host "`n[!!!] ULTIMATE PROTECTION APPLIED BY MINOZ. REBOOT RECOMMENDED." -ForegroundColor Yellow
                Read-Host "Press Enter to return to menu..."
            }
            "2" { # RESTORE ORIGINAL IDENTITY
                Write-AegisLog -Level "INFO" -Message "[MinOz] User selected RESTORE ORIGINAL IDENTITY."
                Restore-AegisSystem
                Read-Host "`nRestore Complete. Press Enter to return to menu..."
            }
            "3" { # VIEW CURRENT VIRTUAL PROFILE
                Write-AegisLog -Level "INFO" -Message "[MinOz] User selected VIEW CURRENT VIRTUAL PROFILE."
                View-DetailedProfile
            }
            "4" { # DEEP CLEAN TRACES ONLY
                Write-AegisLog -Level "INFO" -Message "[MinOz] User selected DEEP CLEAN TRACES ONLY."
                Invoke-AegisCleaner
                Read-Host "`nDeep Cleaning Complete. Press Enter to return to menu..."
            }
            "5" { # EXIT
                Write-AegisLog -Level "INFO" -Message "[MinOz] User selected EXIT. Exiting AegisShroud."
                exit 0
            }
            default {
                Write-Host "[!] Invalid option. Please select a number between 1-5." -ForegroundColor Red
                Write-AegisLog -Level "WARN" -Message "Invalid menu option selected: $choice."
                Read-Host "Press Enter to continue..."
            }
        }
    }
}

# Execute the main function
Start-Aegis
#endregion
