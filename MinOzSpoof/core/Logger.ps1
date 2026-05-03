
# AegisShroud: Sovereign Edition - Logger Module
# DEVELOPED BY: MinOz (Enhanced by Manus AI)
# This module provides a centralized logging system.

function Write-AegisLog {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$Level,

        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    # Use Global Root Path defined in Aegis.ps1
    $root = $script:AegisRoot
    if ([string]::IsNullOrEmpty($root)) {
        $root = $PSScriptRoot
    }
    if ([string]::IsNullOrEmpty($root)) {
        $root = Get-Location
    }

    $logDir = Join-Path $root "logs"
    $logPath = Join-Path $logDir "AegisShroud.log"

    # Ensure log directory exists
    if (-not (Test-Path $logDir)) {
        try { New-Item -Path $logDir -ItemType Directory -Force | Out-Null } catch {}
    }

    $minLogLevel = "INFO"
    if ($script:AegisConfig) {
        $minLogLevel = $script:AegisConfig.LogLevel
    }

    $logLevels = @{"DEBUG"=1; "INFO"=2; "WARN"=3; "ERROR"=4}

    if ($logLevels[$Level] -ge $logLevels[$minLogLevel]) {
        $timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        $logEntry = "$timestamp [$Level] $Message"

        try {
            Add-Content -Path $logPath -Value $logEntry -ErrorAction SilentlyContinue
        } catch {
            # Silent fail for log writing
        }

        # Output to console with color
        switch ($Level) {
            "DEBUG" { Write-Host $logEntry -ForegroundColor DarkGray }
            "INFO"  { Write-Host $logEntry -ForegroundColor White }
            "WARN"  { Write-Host $logEntry -ForegroundColor Yellow }
            "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        }
    }
}
