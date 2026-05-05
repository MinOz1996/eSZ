# MinOz GHOST PROTOCOL (2026) - Master Elite Edition v3.0
# DEVELOPED BY: THE ARCHITECT ELITE SYSTEM

$script:AegisRoot = $PSScriptRoot
$global:IsSpoofed = $false
$global:LastMode = "None"

# --- 1. SOURCING ---
try {
    $paths = @("utils\Helpers.ps1", "core\Logger.ps1", "core\ConfigManager.ps1", "core\StateManager.ps1", "core\Engine.ps1", "cli\Interface.ps1")
    foreach ($p in $paths) { . (Join-Path $script:AegisRoot $p) }
    Get-ChildItem (Join-Path $script:AegisRoot "modules") -Filter "*.ps1" | ForEach-Object { . $_.FullName }
} catch {
    Write-Host "[!] LOAD ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# --- 2. LOGIC ---
function Request-Reboot {
    Write-Host "`n  [?] OPERATION COMPLETE. REBOOT REQUIRED FOR FULL PERSISTENCE." -ForegroundColor Yellow
    $ans = Read-Host "  >> RESTART SYSTEM NOW? (Y/N) "
    if ($ans -eq "Y" -or $ans -eq "y") { Restart-Computer -Force }
}

function Start-AegisConsole {
    Initialize-StateDirectories
    
    # Load Initial State from File
    $global:IsSpoofed = Get-AegisState -Key "IsSpoofed" -Default $false
    $global:LastMode = Get-AegisState -Key "LastMode" -Default "None"

    while ($true) {
        $choice = Show-AegisMenu -IsSpoofed $global:IsSpoofed -LastSpoofType $global:LastMode
        if ([string]::IsNullOrWhiteSpace($choice)) { continue }
        
        switch ($choice.Trim()) {
            "1" {
                if ($global:IsSpoofed) { 
                    Write-Host "`n [!] SYSTEM LOCKED: ALREADY SPOOFED ($global:LastMode)." -ForegroundColor Red
                    Write-Host " [!] PLEASE RESTORE ORIGINAL IDENTITY (3) FIRST." -ForegroundColor Yellow
                    Start-Sleep -Seconds 3 
                }
                else {
                    Write-Host "`n [INFO] Initiating Elite Identity Mutation..." -ForegroundColor Cyan
                    Save-SystemSnapshot -Type "Pre"
                    Invoke-EliteSpoof
                    $global:IsSpoofed = $true
                    $global:LastMode = "ELITE"
                    Set-AegisState -Key "IsSpoofed" -Value $true
                    Set-AegisState -Key "LastMode" -Value "ELITE"
                    Request-Reboot
                }
            }
            "2" {
                if ($global:IsSpoofed) { 
                    Write-Host "`n [!] SYSTEM LOCKED: ALREADY SPOOFED ($global:LastMode)." -ForegroundColor Red
                    Write-Host " [!] PLEASE RESTORE ORIGINAL IDENTITY (3) FIRST." -ForegroundColor Yellow
                    Start-Sleep -Seconds 3 
                }
                else {
                    Write-Host "`n [INFO] Initiating Standard Identity Mutation..." -ForegroundColor Cyan
                    Save-SystemSnapshot -Type "Pre"
                    Invoke-StandardSpoof
                    $global:IsSpoofed = $true
                    $global:LastMode = "STANDARD"
                    Set-AegisState -Key "IsSpoofed" -Value $true
                    Set-AegisState -Key "LastMode" -Value "STANDARD"
                    Request-Reboot
                }
            }
            "3" {
                if (!$global:IsSpoofed) {
                    Write-Host "`n [!] SYSTEM ALREADY IN ORIGINAL STATE." -ForegroundColor Cyan
                    Start-Sleep -Seconds 2
                } else {
                    Write-Host "`n [INFO] Restoring Original Factory Identity..." -ForegroundColor Cyan
                    Restore-AegisSystem
                    # State is reset inside Restore-AegisSystem
                    Write-Host "`n [SUCCESS] SYSTEM RESTORED TO FACTORY STATE." -ForegroundColor Green
                    Request-Reboot
                }
            }
            "4" { View-DetailedProfile }
            "5" { 
                Write-Host "`n [INFO] Obliterating All System Traces..." -ForegroundColor Cyan
                Invoke-AegisCleaner
                Invoke-USNJournalPurger
                Write-Host "`n [SUCCESS] TRACES OBLITERATED." -ForegroundColor Green
                Start-Sleep -Seconds 2 
            }
            "6" { exit }
            default {
                Write-Host " [!] Invalid Selection: $choice" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) { Start-AegisConsole } else { Write-Host "[!] ADMINISTRATOR PRIVILEGES REQUIRED." -ForegroundColor Red; Read-Host "Press Enter to exit..." }
