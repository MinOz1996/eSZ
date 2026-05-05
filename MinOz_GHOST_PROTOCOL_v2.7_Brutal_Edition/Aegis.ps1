
# AegisShroud Sovereign: Ultimate Hybrid Edition (2026) - 
# DEVELOPED BY: MinOz (Original)
# COMBINED: Aegis Security + MinOz Interface + MinOz Advanced Spoofing

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'  # Changed from Stop to prevent WARN from crashing

# --- Root Path Initialization ---
$script:AegisRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
if (-not $script:AegisRoot) { $script:AegisRoot = $PWD.Path }

# --- Global State Variables (Managed by StateManager) ---
# These will be loaded/saved by StateManager functions
$script:IsSpoofed = $false # Tracks if any spoofing (Option 1 or 2) is active
$script:LastSpoofType = "None" # "Full" or "Standard"

# --- Module Loading ---
try {
    . (Join-Path $script:AegisRoot "core\Logger.ps1")
    . (Join-Path $script:AegisRoot "core\ConfigManager.ps1")
    . (Join-Path $script:AegisRoot "core\StateManager.ps1")
    . (Join-Path $script:AegisRoot "core\Engine.ps1")
    . (Join-Path $script:AegisRoot "utils\Helpers.ps1")
    
    # Core Modules
    . (Join-Path $script:AegisRoot "modules\Identity.ps1")
    . (Join-Path $script:AegisRoot "modules\Cleaner.ps1")
    
    # GHOST PROTOCOL Modules (Original & Enhanced)
    . (Join-Path $script:AegisRoot "modules\WMI_Mutation.ps1")
    . (Join-Path $script:AegisRoot "modules\Registry_Obfuscation.ps1")
    . (Join-Path $script:AegisRoot "modules\Kernel_Trace_Obliteration.ps1")
    . (Join-Path $script:AegisRoot "modules\Process_Ghosting_Persistence.ps1")
    . (Join-Path $script:AegisRoot "modules\GHOST_Engine.ps1") # Original GHOST Engine
    
    # Advanced Spoofing Modules (New Features)
    . (Join-Path $script:AegisRoot "modules\EFI_UUID_Randomizer.ps1")
    . (Join-Path $script:AegisRoot "modules\USN_Journal_Purger.ps1")
    . (Join-Path $script:AegisRoot "modules\Peripheral_Monitor_Spoofer.ps1")
    . (Join-Path $script:AegisRoot "modules\Network_Stealth.ps1")
    . (Join-Path $script:AegisRoot "modules\Anti_Kernel_Driver_Stealth.ps1")
    
    # CLI Interface
    . (Join-Path $script:AegisRoot "cli\Interface.ps1")

} catch {
    Write-Host "[!] CRITICAL ERROR: Failed to load core components." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

function Start-AegisSovereign {
    # 1. Admin Check
    if (-not (Test-IsAdministrator)) {
        Write-Host "    ################################################################" -ForegroundColor Red
        Write-Host "    # ERROR: AegisShroud requires Administrator privileges!        #" -ForegroundColor Red
        Write-Host "    ################################################################" -ForegroundColor Red
        Read-Host "    Press Enter to exit..."
        exit 1
    }

    # 2. Load Config and Initial State
    $script:AegisConfig = Get-AegisConfig
    $script:IsSpoofed = (Get-AegisState -Key "IsSpoofed" -Default $false)
    $script:LastSpoofType = (Get-AegisState -Key "LastSpoofType" -Default "None")
    Write-AegisLog -Level "INFO" -Message "AegisShroud Sovereign Edition Started. IsSpoofed: $($script:IsSpoofed)"

    # 3. Main Menu Loop
    while ($true) {
        $choice = Show-AegisMenu -IsSpoofed $script:IsSpoofed -LastSpoofType $script:LastSpoofType
        
        switch ($choice) {
            "1" {
                # GHOST PROTOCOL FULL
                if ($script:IsSpoofed) {
                    Write-Host ""
                    Write-Host "  [LOCKED] GHOST PROTOCOL FULL is locked." -ForegroundColor DarkGray
                    Write-Host "           System is already spoofed ($($script:LastSpoofType))." -ForegroundColor DarkGray
                    Write-Host "           Run [3] RESTORE IDENTITY first." -ForegroundColor DarkGray
                    Write-Host ""
                    Read-Host "  Press Enter to return to menu"
                    continue
                }
                Write-AegisLog -Level "INFO" -Message "User selected GHOST PROTOCOL FULL."
                
                try {
                    Write-Host "[INFO] Running GHOST PROTOCOL FULL (Enhanced)..." -ForegroundColor Cyan
                    
                    # Backup first
                    Backup-AegisSystem
                    
                    # Generate identity
                    $identity = New-AegisIdentity
                    
                    # Apply base identity first
                    Apply-AegisIdentity -Identity $identity
                    
                    # Run GHOST PROTOCOL modules (Original & Enhanced)
                    Invoke-WMIMutation -Identity $identity
                    Invoke-RegistryObfuscation -Identity $identity
                    Invoke-KernelTraceObliteration
                    Invoke-ProcessGhosting
                    
                    # --- Advanced Spoofing --- 
                    Invoke-EFUUIDRandomizer -Identity $identity
                    Invoke-PeripheralMonitorSpoofer -Identity $identity
                    Invoke-NetworkStealth -Identity $identity
                    Invoke-AntiKernelDriverStealth
                    
                    # Deep Clean Traces (Enhanced Cleaner)
                    Invoke-AegisCleaner
                    Invoke-USNJournalPurger

                    Write-Host ""
                    Write-Host ""
                    Write-Host "  +----------------------------------------------+" -ForegroundColor Green
                    Write-Host "  |  SUCCESS  GHOST PROTOCOL FULL Complete!       |" -ForegroundColor Green
                    Write-Host "  |  Effectiveness: 100% - Anti-Cheat Proof       |" -ForegroundColor Green
                    Write-Host "  +----------------------------------------------+" -ForegroundColor Green
                    Write-Host ""

                    $script:IsSpoofed = $true
                    $script:LastSpoofType = "Full"
                    try { Set-AegisState -Key "IsSpoofed" -Value $true } catch {}
                    try { Set-AegisState -Key "LastSpoofType" -Value "Full" } catch {}

                    # Reboot prompt
                    Write-Host ""
                    Write-Host "  -------------------------------------------------" -ForegroundColor DarkMagenta
                    Write-Host "  Reboot is required for all changes to take effect." -ForegroundColor Yellow
                    Write-Host "  Restart computer now?" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "  " -NoNewline
                    Write-Host '[Y]' -NoNewline -ForegroundColor Green
                    Write-Host " Yes - Restart now   " -NoNewline -ForegroundColor White
                    Write-Host '[N]' -NoNewline -ForegroundColor Red
                    Write-Host " No - Restart later" -ForegroundColor White
                    Write-Host "  -------------------------------------------------" -ForegroundColor DarkMagenta
                    Write-Host ""
                    $reboot = Read-Host '  Enter choice [Y/N]'
                    if ($reboot -match "^[Yy]$") {
                        Write-Host ""
                        Write-Host "  Restarting in 5 seconds..." -ForegroundColor Yellow
                        Start-Sleep -Seconds 5
                        Restart-Computer -Force
                    }

                } catch {
                    Write-Host ""
                    Write-Host "[ERROR] GHOST PROTOCOL FULL Failed: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host ""
                    $script:IsSpoofed = $false
                    $script:LastSpoofType = "None"
                    try { Set-AegisState -Key "IsSpoofed" -Value $false } catch {}
                    try { Set-AegisState -Key "LastSpoofType" -Value "None" } catch {}
                }
                Read-Host "`nOperation Complete. Press Enter to return to menu..."
            }
            "2" {
                # STANDARD PROTECTION
                if ($script:IsSpoofed) {
                    Write-Host ""
                    Write-Host "  [LOCKED] STANDARD PROTECTION is locked." -ForegroundColor DarkGray
                    Write-Host "           System is already spoofed ($($script:LastSpoofType))." -ForegroundColor DarkGray
                    Write-Host "           Run [3] RESTORE IDENTITY first." -ForegroundColor DarkGray
                    Write-Host ""
                    Read-Host "  Press Enter to return to menu"
                    continue
                }
                Write-AegisLog -Level "INFO" -Message "User selected STANDARD PROTECTION."
                
                try {
                    Write-Host "[INFO] Running STANDARD PROTECTION..." -ForegroundColor Cyan
                    
                    # Backup first
                    Backup-AegisSystem

                    # Generate identity
                    $identity = New-AegisIdentity
                    
                    # Apply base identity (Registry Only)
                    Apply-AegisIdentity -Identity $identity -RegistryOnly $true

                    # Clean traces (Standard Cleaner)
                    Invoke-AegisCleaner -StandardClean

                    Write-Host ""
                    Write-Host "  [SUCCESS] STANDARD PROTECTION Complete!" -ForegroundColor Green
                    Write-Host "  Effectiveness: 70% (Registry Only)" -ForegroundColor Cyan
                    Write-Host ""

                    $script:IsSpoofed = $true
                    $script:LastSpoofType = "Standard"
                    try { Set-AegisState -Key "IsSpoofed" -Value $true } catch {}
                    try { Set-AegisState -Key "LastSpoofType" -Value "Standard" } catch {}

                } catch {
                    Write-Host ""
                    Write-Host "[ERROR] STANDARD PROTECTION Failed: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host ""
                    $script:IsSpoofed = $false
                    $script:LastSpoofType = "None"
                    try { Set-AegisState -Key "IsSpoofed" -Value $false } catch {}
                    try { Set-AegisState -Key "LastSpoofType" -Value "None" } catch {}
                }
                Read-Host "`nOperation Complete. Press Enter to return to menu..."
            }
            "3" {
                # RESTORE ORIGINAL IDENTITY
                Write-AegisLog -Level "INFO" -Message "User selected RESTORE ORIGINAL IDENTITY."
                
                $backupDir = Join-Path $script:AegisRoot "backup"
                if (-not $script:IsSpoofed) {
                    $hasBackup = (Test-Path $backupDir) -and ((Get-ChildItem $backupDir -Filter "*.reg" -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0)
                    if (-not $hasBackup) {
                        Write-Host ""
                        Write-Host "  +------------------------------------------------------+" -ForegroundColor DarkMagenta
                        Write-Host "  |  NOTICE: Nothing to restore                         |" -ForegroundColor Yellow
                        Write-Host "  |                                                     |" -ForegroundColor DarkMagenta
                        Write-Host "  |  System has not been spoofed yet.                   |" -ForegroundColor White
                        Write-Host "  |  Your identity values are already original.         |" -ForegroundColor White
                        Write-Host "  |                                                     |" -ForegroundColor DarkMagenta
                        Write-Host "  |  Use [1] GHOST FULL or [2] STANDARD to spoof first. |" -ForegroundColor Cyan
                        Write-Host "  +------------------------------------------------------+" -ForegroundColor DarkMagenta
                        Write-Host ""
                        Read-Host "  Press Enter to return to menu"
                        continue
                    }
                }
                
                try {
                    # Remove GHOST modifications
                    Remove-GHOSTProtocol
                    Remove-EFUUIDRandomizer
                    Remove-PeripheralMonitorSpoofer
                    Remove-NetworkStealth
                    Remove-AntiKernelDriverStealth
                    Remove-USNJournalPurger

                    # Restore original state
                    Restore-AegisSystem
                    
                    # Finalize State
                    $script:IsSpoofed = $false
                    $script:LastSpoofType = "None"
                    try { Set-AegisState -Key "IsSpoofed" -Value $false } catch {}
                    try { Set-AegisState -Key "LastSpoofType" -Value "None" } catch {}
                    
                    # Delete Backup (User Request)
                    Write-Host "  [INFO] Cleaning up backup files..." -ForegroundColor Cyan
                    if (Test-Path $backupDir) {
                        Remove-Item -Path $backupDir -Recurse -Force -ErrorAction SilentlyContinue
                        Write-Host "  [SUCCESS] Backup folder deleted." -ForegroundColor Green
                    }

                    Write-Host ""
                    Write-Host "  [SUCCESS] Identity Restored!" -ForegroundColor Green
                    Write-Host "  Please reboot to complete restoration." -ForegroundColor Yellow
                    Write-Host ""
                } catch {
                    Write-Host ""
                    Write-Host "[ERROR] RESTORE Failed: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host ""
                }
                Read-Host "`nOperation Complete. Press Enter to return to menu..."
            }
            "4" {
                # VIEW CURRENT PROFILE
                Write-AegisLog -Level "INFO" -Message "User selected VIEW CURRENT PROFILE."
                View-DetailedProfile
            }
            "5" {
                # DEEP CLEAN TRACES ONLY
                Write-AegisLog -Level "INFO" -Message "User selected DEEP CLEAN TRACES ONLY."
                try {
                    Write-Host "[INFO] Running DEEP CLEAN TRACES ONLY (Enhanced)..." -ForegroundColor Cyan
                    Invoke-KernelTraceObliteration
                    Invoke-USNJournalPurger
                    Invoke-AntiKernelDriverStealth -CleanOnly
                    Invoke-AegisCleaner
                    Write-Host ""
                    Write-Host "  [SUCCESS] Deep Clean Complete!" -ForegroundColor Green
                    Write-Host ""
                } catch {
                    Write-Host ""
                    Write-Host "[ERROR] CLEAN Failed: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host ""
                }
                Read-Host "`nOperation Complete. Press Enter to return to menu..."
            }
            "6" {
                Write-AegisLog -Level "INFO" -Message "User exited."
                exit 0
            }
            default {
                Write-Host "  [!] Invalid choice. Please select 1-6." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

# Entry Point
Start-AegisSovereign
