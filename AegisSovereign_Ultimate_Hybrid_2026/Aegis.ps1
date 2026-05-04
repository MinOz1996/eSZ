# AegisShroud Sovereign: Ultimate Hybrid Edition (2026)
# DEVELOPED BY: MinOz (Enhanced to Expert-Level by Manus AI)
# COMBINED: Aegis Security + MinOz Interface

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Root Path Initialization (Professional Way) ---
$script:AegisRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
if (-not $script:AegisRoot) { $script:AegisRoot = $PWD.Path }

# --- Module Loading ---
try {
    . (Join-Path $script:AegisRoot "core\Logger.ps1")
    . (Join-Path $script:AegisRoot "core\ConfigManager.ps1")
    . (Join-Path $script:AegisRoot "core\StateManager.ps1")
    . (Join-Path $script:AegisRoot "core\Engine.ps1")
    . (Join-Path $script:AegisRoot "utils\Helpers.ps1")
    . (Join-Path $script:AegisRoot "modules\Identity.ps1")
    . (Join-Path $script:AegisRoot "modules\Cleaner.ps1")
    . (Join-Path $script:AegisRoot "cli\Interface.ps1")
} catch {
    Write-Host "[!] CRITICAL ERROR: Failed to load core components." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

function Start-AegisSovereign {
    # 1. Admin Check (Using Helpers)
    if (-not (Test-IsAdministrator)) {
        Write-Host "    ################################################################" -ForegroundColor Red
        Write-Host "    # ERROR: AegisShroud requires Administrator privileges!        #" -ForegroundColor Red
        Write-Host "    ################################################################" -ForegroundColor Red
        Read-Host "    Press Enter to exit..."
        exit 1
    }

    # 2. Load Config
    $script:AegisConfig = Get-AegisConfig
    Write-AegisLog -Level "INFO" -Message "AegisShroud Sovereign Edition Started."

    # 3. Main Menu Loop
    while ($true) {
        $choice = Show-AegisMenu
        
        switch ($choice) {
            "1" {
                Write-AegisLog -Level "INFO" -Message "User selected FULL PROTECTION."
                $tasks = @(
                    { Backup-AegisSystem },
                    { 
                        $id = New-AegisIdentity
                        Apply-AegisIdentity -Identity $id 
                    },
                    { Invoke-AegisCleaner },
                    { if ($script:AegisConfig.Features.Persistence) { Enable-AegisPersistence } }
                )
                Invoke-AegisPipeline -Tasks $tasks
                Read-Host "`nOperation Complete. Press Enter to return to menu..."
            }
            "2" {
                Write-AegisLog -Level "INFO" -Message "User selected RESTORE ORIGINAL IDENTITY."
                Restore-AegisSystem
                Read-Host "`nSystem Restored. Press Enter to return to menu..."
            }
            "3" {
                View-DetailedProfile
            }
            "4" {
                Write-AegisLog -Level "INFO" -Message "User selected DEEP CLEAN ONLY."
                Invoke-AegisPipeline -Tasks @({ Invoke-AegisCleaner })
                Read-Host "`nClean Complete. Press Enter to return to menu..."
            }
            "5" {
                Write-AegisLog -Level "INFO" -Message "Exiting Aegis Shroud."
                exit
            }
            default {
                # Silent return to loop
            }
        }
    }
}

# Run the controller
Start-AegisSovereign
