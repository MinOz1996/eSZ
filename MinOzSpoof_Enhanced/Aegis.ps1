# AegisShroud: Sovereign Edition - Silent Loader
# DEVELOPED BY: MinOz (Enhanced by Claude)

param(
    [switch]$ApplyProfile,
    [string]$ProfilePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:AegisRoot = $PSScriptRoot
if ([string]::IsNullOrEmpty($script:AegisRoot)) {
    $script:AegisRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
}
if ([string]::IsNullOrEmpty($script:AegisRoot)) {
    $script:AegisRoot = Get-Location
}

try {
    # Silent load - no banner, no messages
    . (Join-Path $script:AegisRoot "core\Logger.ps1")
    . (Join-Path $script:AegisRoot "core\ConfigManager.ps1")
    . (Join-Path $script:AegisRoot "core\StateManager.ps1")
    . (Join-Path $script:AegisRoot "core\Engine.ps1")
    . (Join-Path $script:AegisRoot "utils\Helpers.ps1")
    . (Join-Path $script:AegisRoot "modules\Identity.ps1")
    . (Join-Path $script:AegisRoot "modules\Cleaner.ps1")
    . (Join-Path $script:AegisRoot "cli\Interface.ps1")
}
catch {
    Write-Host ""
    Write-Host "[!] CRITICAL ERROR: Failed to load components!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Stack Trace:" -ForegroundColor DarkGray
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Press Enter to exit..." -ForegroundColor Yellow
    Read-Host
    exit 1
}

function Start-Aegis {
    if (-not (Test-IsAdministrator)) {
        Write-Host ""
        Write-Host "[!] ADMINISTRATOR PRIVILEGES REQUIRED!" -ForegroundColor Red
        Write-Host "    Please run as Administrator." -ForegroundColor Red
        Write-Host ""
        Write-AegisLog -Level "ERROR" -Message "[MinOz] Admin required"
        Write-Host "Press Enter to exit..." -ForegroundColor Yellow
        Read-Host
        exit 1
    }

    $config = Get-AegisConfig
    Write-AegisLog -Level "INFO" -Message "[MinOz] AegisShroud v2.0 Started" -Context @{
        Version = $config.Version
    }

    if ($ApplyProfile) {
        Write-AegisLog -Level "INFO" -Message "[MinOz] Persistence mode"
        try {
            $PostState = Get-SystemSnapshot -Type "Post"
            if ($PostState) {
                Apply-AegisIdentity -Identity $PostState
                Invoke-AegisCleaner
                Write-AegisLog -Level "INFO" -Message "[MinOz] Re-applied"
            }
        }
        catch {
            Write-AegisLog -Level "ERROR" -Message "[MinOz] Error: $($_.Exception.Message)"
        }
        exit 0
    }

    while ($true) {
        $choice = Show-AegisMenu
        
        switch ($choice) {
            "1" {
                Write-AegisLog -Level "INFO" -Message "[MinOz] FULL PROTECTION"
                
                Clear-Host
                Write-Host ""
                Write-Host "    ################################################################" -ForegroundColor Magenta
                Write-Host "    #                                                              #" -ForegroundColor Magenta
                Write-Host "    #                  FULL PROTECTION MODE                        #" -ForegroundColor Magenta
                Write-Host "    #                    Developed by MinOz                        #" -ForegroundColor Magenta
                Write-Host "    #                                                              #" -ForegroundColor Magenta
                Write-Host "    ################################################################" -ForegroundColor Magenta
                Write-Host ""
                Write-Host "    This operation will:" -ForegroundColor White
                Write-Host ""
                Write-Host "      [1] Backup your current system identity" -ForegroundColor White
                Write-Host "      [2] Generate and apply a new virtual identity" -ForegroundColor White
                Write-Host "      [3] Deep clean system traces" -ForegroundColor White
                Write-Host "      [4] Enable persistence (auto-reapply on logon)" -ForegroundColor White
                Write-Host ""
                Write-Host "    [!] WARNING: Reboot recommended after completion!" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "    Continue? (Y/N): " -NoNewline -ForegroundColor Cyan
                
                $confirm = Read-Host
                
                if ($confirm -eq "Y" -or $confirm -eq "y") {
                    Write-Host ""
                    $tasks = @(
                        { $id = New-AegisIdentity; Apply-AegisIdentity -Identity $id },
                        { Invoke-AegisCleaner },
                        { Enable-AegisPersistence }
                    )
                    
                    Invoke-AegisPipeline -Tasks $tasks
                    
                    Write-Host ""
                    Write-Host "    ################################################################" -ForegroundColor Green
                    Write-Host "    #                                                              #" -ForegroundColor Green
                    Write-Host "    #          FULL PROTECTION APPLIED SUCCESSFULLY!               #" -ForegroundColor Green
                    Write-Host "    #              MinOz Technology Activated                      #" -ForegroundColor Green
                    Write-Host "    #                                                              #" -ForegroundColor Green
                    Write-Host "    ################################################################" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "    [+] RECOMMENDATION: Reboot now!" -ForegroundColor Yellow
                    Write-Host ""
                }
                else {
                    Write-Host ""
                    Write-Host "    [-] Operation cancelled." -ForegroundColor Yellow
                }
                
                Write-Host ""
                Read-Host "    Press Enter to return to menu"
            }
            
            "2" {
                Write-AegisLog -Level "INFO" -Message "[MinOz] RESTORE"
                
                Clear-Host
                Write-Host ""
                Write-Host "    ################################################################" -ForegroundColor Yellow
                Write-Host "    #                                                              #" -ForegroundColor Yellow
                Write-Host "    #              RESTORE ORIGINAL IDENTITY                       #" -ForegroundColor Yellow
                Write-Host "    #                    Developed by MinOz                        #" -ForegroundColor Yellow
                Write-Host "    #                                                              #" -ForegroundColor Yellow
                Write-Host "    ################################################################" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "    This will restore your system to original state." -ForegroundColor White
                Write-Host ""
                Write-Host "    Continue? (Y/N): " -NoNewline -ForegroundColor Cyan
                
                $confirm = Read-Host
                
                if ($confirm -eq "Y" -or $confirm -eq "y") {
                    Write-Host ""
                    Restore-AegisSystem
                    Write-Host ""
                    Write-Host "    [+] System restored by MinOz Technology" -ForegroundColor Green
                    Write-Host ""
                }
                else {
                    Write-Host ""
                    Write-Host "    [-] Operation cancelled." -ForegroundColor Yellow
                }
                
                Write-Host ""
                Read-Host "    Press Enter to return to menu"
            }
            
            "3" {
                Write-AegisLog -Level "INFO" -Message "[MinOz] VIEW PROFILE"
                View-DetailedProfile
            }
            
            "4" {
                Write-AegisLog -Level "INFO" -Message "[MinOz] DEEP CLEAN"
                
                Clear-Host
                Write-Host ""
                Write-Host "    ################################################################" -ForegroundColor Magenta
                Write-Host "    #                                                              #" -ForegroundColor Magenta
                Write-Host "    #                 DEEP CLEAN TRACES ONLY                       #" -ForegroundColor Magenta
                Write-Host "    #                    Developed by MinOz                        #" -ForegroundColor Magenta
                Write-Host "    #                                                              #" -ForegroundColor Magenta
                Write-Host "    ################################################################" -ForegroundColor Magenta
                Write-Host ""
                Write-Host "    Continue? (Y/N): " -NoNewline -ForegroundColor Cyan
                
                $confirm = Read-Host
                
                if ($confirm -eq "Y" -or $confirm -eq "y") {
                    Write-Host ""
                    Invoke-AegisCleaner
                    Write-Host ""
                    Write-Host "    [+] Deep cleaning completed" -ForegroundColor Green
                    Write-Host ""
                }
                else {
                    Write-Host ""
                    Write-Host "    [-] Operation cancelled." -ForegroundColor Yellow
                }
                
                Write-Host ""
                Read-Host "    Press Enter to return to menu"
            }
            
            "5" {
                Write-AegisLog -Level "INFO" -Message "[MinOz] EXIT"
                Write-Host ""
                Write-Host "Exiting MinOz AegisShroud. Stay safe." -ForegroundColor Cyan
                Write-Host ""
                exit 0
            }
            
            default {
                Write-Host ""
                Write-Host "[!] Invalid option. Select 1-5." -ForegroundColor Red
                Write-AegisLog -Level "WARN" -Message "Invalid: $choice"
                Start-Sleep -Seconds 1
            }
        }
    }
}

try {
    Start-Aegis
}
catch {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host "                   CRITICAL ERROR                               " -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Stack Trace:" -ForegroundColor DarkGray
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    Write-Host ""
    Write-AegisLog -Level "FATAL" -Message "Critical: $($_.Exception.Message)"
    Write-Host "Press Enter to exit..." -ForegroundColor Yellow
    Read-Host
    exit 1
}
