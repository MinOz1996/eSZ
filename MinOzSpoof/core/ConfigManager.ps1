
# AegisShroud: Sovereign Edition - Config Manager Module
# DEVELOPED BY: MinOz (Enhanced by Manus AI)
# This module handles loading and managing the application configuration.

$script:AegisConfig = $null

function Get-AegisConfig {
    if ($script:AegisConfig -ne $null) {
        return $script:AegisConfig
    }

    # Use Global Root Path defined in Aegis.ps1
    $root = $script:AegisRoot
    if ([string]::IsNullOrEmpty($root)) {
        $root = $PSScriptRoot
    }
    if ([string]::IsNullOrEmpty($root)) {
        $root = Get-Location
    }

    $configDir = Join-Path $root "config"
    $configPath = Join-Path $configDir "settings.json"
    $logDir = Join-Path $root "logs"
    $logPath = Join-Path $logDir "AegisShroud.log"

    Write-AegisLog -Level "INFO" -Message "[MinOz] Initializing configuration..."

    try {
        if (-not (Test-Path $configDir)) { New-Item -Path $configDir -ItemType Directory -Force | Out-Null }
        
        if (Test-Path $configPath) {
            $script:AegisConfig = (Get-Content -Path $configPath | ConvertFrom-Json)
        } else {
            # Define default configuration
            $script:AegisConfig = @{
                Version = "Sovereign Edition 1.0";
                Environment = "Production";
                LogPath = $logPath;
                LogLevel = "INFO";
                Modules = @{
                    Identity = @{Enabled = $true};
                    Cleaner = @{Enabled = $true};
                }
            }
            $script:AegisConfig | ConvertTo-Json -Depth 100 | Set-Content -Path $configPath -Force
        }
    } catch {
        # Fallback to hardcoded defaults
        $script:AegisConfig = @{
            Version = "Sovereign Edition 1.0";
            Environment = "Production";
            LogPath = $logPath;
            LogLevel = "INFO";
            Modules = @{
                Identity = @{Enabled = $true};
                Cleaner = @{Enabled = $true};
            }
        }
    }
    return $script:AegisConfig
}
