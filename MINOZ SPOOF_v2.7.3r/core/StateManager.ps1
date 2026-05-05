# AegisShroud: Sovereign Edition - Enhanced State Manager Module
# DEVELOPED BY: MinOz (Re-Architected by The Architect & Zero-Day Researcher)
# Zero-Interaction, robust state management.

# --- Module Variables ---
$script:STATE_DIR = $null
$script:AEGIS_STATE_FILE = $null

function Initialize-State {
    # Get the directory of the currently executing script (StateManager.ps1)
    $currentScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    
    # The project root is one level up from 'core' directory
    $projectRoot = Split-Path -Parent $currentScriptDir
    
    $script:STATE_DIR = Join-Path $projectRoot "state"
    $script:AEGIS_STATE_FILE = Join-Path $script:STATE_DIR "aegis_state.json"

    if (-not (Test-Path $script:STATE_DIR)) {
        New-Item -Path $script:STATE_DIR -ItemType Directory -Force | Out-Null
    }

    if (-not (Test-Path $script:AEGIS_STATE_FILE)) {
        Write-AegisLog -Level "INFO" -Message "State file not found. Creating default state."
        @{ IsSpoofed = $false; LastSpoofType = "None" } | ConvertTo-Json | Out-File -FilePath $script:AEGIS_STATE_FILE -Encoding UTF8
    }
}

function Get-AegisState {
    try {
        if (-not (Test-Path $script:AEGIS_STATE_FILE)) {
            return @{ IsSpoofed = $false; LastSpoofType = "None" }
        }
        $content = Get-Content -Path $script:AEGIS_STATE_FILE -Raw -ErrorAction Stop
        $state = $content | ConvertFrom-Json -ErrorAction Stop
        
        # Ensure IsSpoofed is always a boolean
        if ($null -eq $state.IsSpoofed) {
            $state.IsSpoofed = $false
        } else {
            $state.IsSpoofed = [bool]$state.IsSpoofed
        }
        
        # Ensure LastSpoofType is always a string
        if ($null -eq $state.LastSpoofType) {
            $state.LastSpoofType = "None"
        } else {
            $state.LastSpoofType = [string]$state.LastSpoofType
        }

        return $state
    } catch {
        Write-AegisLog -Level "WARN" -Message "Failed to read or parse state file. Returning default state. Error: $($_.Exception.Message)"
        return @{ IsSpoofed = $false; LastSpoofType = "None" }
    }
}

function Set-AegisState {
    param(
        [bool]$IsSpoofed,
        [string]$LastSpoofType
    )
    $state = @{ IsSpoofed = $IsSpoofed; LastSpoofType = $LastSpoofType }
    try {
        $state | ConvertTo-Json | Out-File -FilePath $script:AEGIS_STATE_FILE -Encoding UTF8
        Write-AegisLog -Level "INFO" -Message "State updated: IsSpoofed=$IsSpoofed, LastSpoofType=$LastSpoofType"
    } catch {
        Write-AegisLog -Level "ERROR" -Message "Failed to write state file: $($_.Exception.Message)"
    }
}

# The following functions are preserved for compatibility but are now simplified or deprecated
# in favor of the new zero-interaction model.

function Get-CurrentSystemIdentity { 
    # This function would contain the detailed WMI/Registry queries as before.
    # For this fix, we focus on the state management logic.
    return @{ ComputerName = "SIMULATED" }
}

function Show-IdentityReport {
    param([hashtable]$Report)
    
    # PowerShell 5.1 compatible box characters
    $c_tl = [char]0x250C
    $c_tr = [char]0x2510
    $c_bl = [char]0x2514
    $c_br = [char]0x2518
    $c_h  = [char]0x2500
    $c_v  = [char]0x2502

    Clear-Host
    Write-Host ""
    Write-Host ("  " + $c_tl + ($c_h * 70) + $c_tr) -ForegroundColor DarkMagenta
    Write-Host ("  " + $c_v + "  AEGIS SHROUD  --  IDENTITY REPORT".PadRight(70) + $c_v) -ForegroundColor DarkMagenta
    Write-Host ("  " + $c_v + "  $(Get-Date -Format 'HH:mm:ss    dd/MM/yyyy')".PadRight(70) + $c_v) -ForegroundColor DarkMagenta
    Write-Host ("  " + $c_bl + ($c_h * 70) + $c_br) -ForegroundColor DarkMagenta
    Write-Host ""
    
    if ($null -eq $Report -or $Report.Count -eq 0) {
        Write-Host "  [!] No identity data available." -ForegroundColor Red
    } else {
        foreach ($key in $Report.Keys) {
            $val = $Report[$key]
            Write-Host "  $($key.PadRight(20)) : $($val)" -ForegroundColor Gray
        }
    }
    Write-Host ""
    Read-Host "  Press Enter to return to menu"
}

function Restore-AegisSystem {
    Write-AegisLog -Level "INFO" -Message "[SYSTEM] Initiating full system restore..."
    # Call the main restore functions from other modules
    Remove-GHOSTProtocol
    Restore-OriginalIdentity
    Write-AegisLog -Level "INFO" -Message "[SYSTEM] Full system restore process completed."
}
