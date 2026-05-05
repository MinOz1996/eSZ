# Aegis Shroud: GHOST PROTOCOL - Re-Architected by The Architect and Zero-Day Researcher
# This is the master entry point. It initializes and orchestrates all modules.

# --- ARCHITECTURAL SETUP ---
$script:AegisRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ScriptDir = $script:AegisRoot

# Core Systems Integration
. (Join-Path $ScriptDir "core/Logger.ps1")
. (Join-Path $ScriptDir "core/ConfigManager.ps1")
. (Join-Path $ScriptDir "core/StateManager.ps1")
. (Join-Path $ScriptDir "utils/Helpers.ps1")

# Module Integration (The Arsenal)
. (Join-Path $ScriptDir "modules/Identity.ps1")
. (Join-Path $ScriptDir "modules/Cleaner.ps1")
. (Join-Path $ScriptDir "modules/WMI_Mutation.ps1")
. (Join-Path $ScriptDir "modules/Registry_Obfuscation.ps1")
. (Join-Path $ScriptDir "modules/Peripheral_Monitor_Spoofer.ps1")
. (Join-Path $ScriptDir "modules/Anti_Kernel_Driver_Stealth.ps1")
. (Join-Path $ScriptDir "modules/Process_Ghosting_Persistence.ps1")
. (Join-Path $ScriptDir "modules/Kernel_Trace_Obliteration.ps1")
. (Join-Path $ScriptDir "modules/EFI_UUID_Randomizer.ps1")
. (Join-Path $ScriptDir "modules/Network_Stealth.ps1")
. (Join-Path $ScriptDir "modules/USN_Journal_Purger.ps1")
. (Join-Path $ScriptDir "modules/GHOST_Engine.ps1") # The core orchestrator

# UI Layer
. (Join-Path $ScriptDir "cli/Interface.ps1")

# --- INITIALIZATION ---
New-AegisLogSession
Initialize-State # Initialize state manager (creates default state if not found)
Get-AegisConfig # Get configuration (creates default config if not found and imports it)

# --- MAIN EXECUTION LOOP (THE BRIDGE) ---
while ($true) {
    $currentState = Get-AegisState
    $choice = Show-AegisMenu -IsSpoofed $currentState.IsSpoofed -LastSpoofType $currentState.LastSpoofType

    switch ($choice) {
        "1" { # GHOST PROTOCOL FULL
            Write-Host "  [+] Initializing GHOST Protocol... Stand by." -ForegroundColor Yellow
            $identity = New-AegisIdentity
            Invoke-GHOSTProtocol -Identity $identity -EnablePersistence
            Set-AegisState -IsSpoofed $true -LastSpoofType "GHOST"
            Write-Host "  [SUCCESS] GHOST Protocol complete. A reboot is required to finalize." -ForegroundColor Green
            Read-Host "  Press Enter to continue..."
        }
        "2" { # STANDARD PROTECTION (Registry Only)
            Write-Host "  [+] Initializing Standard Protection..." -ForegroundColor Yellow
            $identity = New-AegisIdentity
            Apply-AegisIdentity -Identity $identity
            Set-AegisState -IsSpoofed $true -LastSpoofType "Standard"
            Write-Host "  [SUCCESS] Standard Protection applied. A reboot is required." -ForegroundColor Green
            Read-Host "  Press Enter to continue..."
        }
        "3", "3.1" { # RESTORE IDENTITY
            Write-Host "  [+] Restoring original system identity..." -ForegroundColor Yellow
            Restore-AegisSystem
            Set-AegisState -IsSpoofed $false -LastSpoofType "None"
            Write-Host "  [SUCCESS] System identity restored. A reboot is required." -ForegroundColor Green
            Read-Host "  Press Enter to continue..."
        }
        "4" { # VIEW CURRENT PROFILE
            $report = Get-CurrentSystemIdentity
            Show-IdentityReport -Report $report
        }
        "5" { # DEEP CLEAN TRACES
            Write-Host "  [+] Obliterating system traces..." -ForegroundColor Yellow
            Invoke-AegisCleaner -DeepClean $true
            Write-Host "  [SUCCESS] System traces have been cleaned." -ForegroundColor Green
            Read-Host "  Press Enter to continue..."
        }
        "6" { # EXIT
            Write-Host "  [+] Shutting down Aegis Shroud. Stay hidden." -ForegroundColor Gray
            break
        }
        default {
            Write-Host "  [!] Invalid selection. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}
