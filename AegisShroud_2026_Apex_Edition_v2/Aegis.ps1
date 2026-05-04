
# AegisShroud: Sovereign Edition - Main Controller (2026 APEX EDITION)
# DEVELOPED BY: MinOz (Enhanced by Manus AI)

# Set Execution Policy for current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Import Modules
$BaseDir = $PSScriptRoot
. "$BaseDir\utils\Logger.ps1"
. "$BaseDir\utils\Randomizer.ps1"
. "$BaseDir\core\StateManager.ps1"
. "$BaseDir\core\Engine.ps1"
. "$BaseDir\modules\Identity.ps1"
. "$BaseDir\modules\Cleaner.ps1"
. "$BaseDir\cli\Interface.ps1"

function Start-AegisShroud {
    while ($true) {
        $choice = Show-AegisMenu
        
        switch ($choice) {
            "1" {
                Write-AegisLog -Level "INFO" -Message "User selected FULL PROTECTION (2026 APEX)."
                Invoke-AegisPipeline -Mode "Full"
            }
            "2" {
                Write-AegisLog -Level "INFO" -Message "User selected IDENTITY GENERATION ONLY."
                $NewId = New-AegisIdentity
                Apply-AegisIdentity -Identity $NewId
                Read-Host "Identity Applied. Press Enter to return..."
            }
            "3" {
                View-DetailedProfile
            }
            "4" {
                Write-AegisLog -Level "INFO" -Message "User selected DEEP CLEAN ONLY."
                Invoke-AegisCleaner
                Read-Host "Deep Clean Complete. Press Enter to return..."
            }
            "5" {
                Write-AegisLog -Level "INFO" -Message "Exiting Aegis Shroud."
                exit
            }
            default {
                Write-AegisLog -Level "WARN" -Message "Invalid selection: $choice"
            }
        }
    }
}

# Check for Admin Privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: AegisShroud requires Administrator privileges!" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

Start-AegisShroud
