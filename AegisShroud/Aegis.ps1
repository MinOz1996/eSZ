# AegisShroud Professional Framework Entry Point
# Refactored for Modular Architecture, Reliability, and Visibility

$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# 1. Load Core Components
. (Join-Path $PSScriptRoot "core\Logger.ps1")
. (Join-Path $PSScriptRoot "core\ConfigManager.ps1")
. (Join-Path $PSScriptRoot "core\StateManager.ps1")
. (Join-Path $PSScriptRoot "core\Engine.ps1")

# 2. Load Utilities
. (Join-Path $PSScriptRoot "utils\Helpers.ps1")

# 3. Load Modules
. (Join-Path $PSScriptRoot "modules\Identity.ps1")
. (Join-Path $PSScriptRoot "modules\Cleaner.ps1")

# 4. Load CLI
. (Join-Path $PSScriptRoot "cli\Interface.ps1")

# Main Logic
function Start-Aegis {
    $Config = Get-AegisConfig
    
    while ($true) {
        $Choice = Show-AegisMenu
        switch ($Choice) {
            "1" {
                $Tasks = @(
                    { 
                        $Id = New-AegisIdentity
                        Apply-AegisIdentity -Identity $Id 
                    },
                    { Invoke-AegisCleaner }
                )
                Invoke-AegisPipeline -Tasks $Tasks
                Read-Host "`nPress Enter to continue..."
            }
            "2" {
                Write-Host "`n--- Recent Snapshots ---" -ForegroundColor Yellow
                Get-ChildItem (Join-Path $PSScriptRoot "state") | Select-Object Name, LastWriteTime
                Read-Host "`nPress Enter to continue..."
            }
            "4" {
                $LogFile = Join-Path $PSScriptRoot "logs\aegis_$(Get-Date -Format 'yyyyMMdd').log"
                if (Test-Path $LogFile) { Get-Content $LogFile -Tail 20 }
                Read-Host "`nPress Enter to continue..."
            }
            "5" { exit }
        }
    }
}

# Start the application
Start-Aegis
