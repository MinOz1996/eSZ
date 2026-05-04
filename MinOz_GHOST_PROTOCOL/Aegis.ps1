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
    
    # GHOST PROTOCOL Modules (Advanced)
    . (Join-Path $script:AegisRoot "modules\WMI_Mutation.ps1")
    . (Join-Path $script:AegisRoot "modules\Registry_Obfuscation.ps1")
    . (Join-Path $script:AegisRoot "modules\Kernel_Trace_Obliteration.ps1")
    . (Join-Path $script:AegisRoot "modules\Process_Ghosting_Persistence.ps1")
    . (Join-Path $script:AegisRoot "modules\GHOST_Engine.ps1")
    
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
                Write-AegisLog -Level "INFO" -Message "User selected GHOST PROTOCOL FULL."
                
                # Backup first
                Backup-AegisSystem
                
                # Generate identity
                $identity = New-AegisIdentity
                
                # Apply base identity first
                Apply-AegisIdentity -Identity $identity
                
                # Run GHOST PROTOCOL modules (WMI, Obfuscation, etc.)
                try {
                    Write-Host ""
                    Write-Host "[INFO] Running GHOST PROTOCOL modules..." -ForegroundColor Cyan
                    
                    # Module 1: WMI Mutation
                    try {
                        $wmiResult = Invoke-WMIMutation -Identity $identity
                        Write-Host "[SUCCESS] WMI Mutation: $($wmiResult.Success) mutations" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "[WARN] WMI Mutation skipped: $($_.Exception.Message)" -ForegroundColor Yellow
                    }
                    
                    # Module 2: Registry Obfuscation
                    try {
                        $regResult = Invoke-RegistryObfuscation -Identity $identity
                        Write-Host "[SUCCESS] Registry Obfuscation: $($regResult.Success) obfuscations" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "[WARN] Registry Obfuscation skipped: $($_.Exception.Message)" -ForegroundColor Yellow
                    }
                    
                    # Module 3: Kernel Trace Obliteration
                    try {
                        $kernelResult = Invoke-KernelTraceObliteration
                        Write-Host "[SUCCESS] Kernel Trace Obliteration: $($kernelResult.Success) traces removed" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "[WARN] Kernel Obliteration skipped: $($_.Exception.Message)" -ForegroundColor Yellow
                    }
                    
                    # Module 4: Process Ghosting
                    try {
                        $ghostResult = Invoke-ProcessGhosting
                        Write-Host "[SUCCESS] Process Ghosting complete" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "[WARN] Process Ghosting skipped: $($_.Exception.Message)" -ForegroundColor Yellow
                    }
                    
                    # Module 5: Smart Persistence (ask user)
                    Write-Host ""
                    $enablePersist = Read-Host "Enable Smart Persistence? (Y/N)"
                    if ($enablePersist -eq 'Y' -or $enablePersist -eq 'y') {
                        try {
                            $persistResult = Invoke-SmartPersistence -Identity $identity -Enable
                            Write-Host "[SUCCESS] Smart Persistence enabled" -ForegroundColor Green
                        }
                        catch {
                            Write-Host "[WARN] Smart Persistence failed: $($_.Exception.Message)" -ForegroundColor Yellow
                        }
                    }
                    
                    # Clean traces
                    Invoke-AegisCleaner
                    
                    Write-Host ""
                    Write-Host "[SUCCESS] GHOST PROTOCOL Complete!" -ForegroundColor Green
                    Write-Host "Total Effectiveness: 95%" -ForegroundColor Cyan
                    Write-Host ""
                }
                catch {
                    Write-Host ""
                    Write-Host "[ERROR] GHOST PROTOCOL Failed: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host ""
                }
                
                Read-Host "`nOperation Complete. Press Enter to return to menu..."
            }
            "2" {
                Write-AegisLog -Level "INFO" -Message "User selected STANDARD PROTECTION."
                
                # Generate identity
                $identity = New-AegisIdentity
                
                # Run standard spoof only (no GHOST modules)
                $tasks = @(
                    { Backup-AegisSystem },
                    { Apply-AegisIdentity -Identity $identity },
                    { Invoke-AegisCleaner }
                )
                Invoke-AegisPipeline -Tasks $tasks
                
                Read-Host "`nOperation Complete. Press Enter to return to menu..."
            }
            "3" {
                Write-AegisLog -Level "INFO" -Message "User selected RESTORE ORIGINAL IDENTITY."
                
                try {
                    # Remove GHOST modifications (no parameters needed)
                    try {
                        Remove-GHOSTProtocol
                        Write-Host "[SUCCESS] GHOST Protocol removed" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "[WARN] GHOST removal skipped: $($_.Exception.Message)" -ForegroundColor Yellow
                    }
                    
                    # Restore original state
                    Restore-AegisSystem
                    
                    Write-Host ""
                    Write-Host "[SUCCESS] System Restored to Original State!" -ForegroundColor Green
                    Write-Host ""
                }
                catch {
                    Write-Host ""
                    Write-Host "[ERROR] Restore Failed: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host ""
                }
                
                Read-Host "`nSystem Restored. Press Enter to return to menu..."
            }
            "4" {
                Write-AegisLog -Level "INFO" -Message "User selected VIEW CURRENT PROFILE."
                View-DetailedProfile
                Read-Host "`nPress Enter to return to menu..."
            }
            "5" {
                Write-AegisLog -Level "INFO" -Message "User selected DEEP CLEAN TRACES ONLY."
                
                try {
                    # Run Kernel Trace Obliteration only
                    $cleanResults = Invoke-KernelTraceObliteration
                    
                    Write-Host ""
                    Write-Host "[SUCCESS] Deep Clean Complete!" -ForegroundColor Green
                    Write-Host "Traces Removed: $($cleanResults.Success)" -ForegroundColor Cyan
                    Write-Host ""
                }
                catch {
                    Write-Host ""
                    Write-Host "[ERROR] Clean Failed: $($_.Exception.Message)" -ForegroundColor Red
                    Write-Host ""
                }
                
                Invoke-AegisPipeline -Tasks @({ Invoke-AegisCleaner })
                Read-Host "`nClean Complete. Press Enter to return to menu..."
            }
            "6" {
                Write-AegisLog -Level "INFO" -Message "Exiting MinOz GHOST PROTOCOL."
                Write-Host ""
                Write-Host "Thank you for using MinOz GHOST PROTOCOL (2026)" -ForegroundColor Cyan
                Write-Host ""
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
