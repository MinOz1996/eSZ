function Write-AegisLog {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level,
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [switch]$ShowVerbose
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    $LogFile = Join-Path $PSScriptRoot "..\logs\aegis_$(Get-Date -Format 'yyyyMMdd').log"

    # Console Output
    $Color = switch ($Level) {
        "INFO"  { "Cyan" }
        "WARN"  { "Yellow" }
        "ERROR" { "Red" }
        "DEBUG" { "Gray" }
    }

    if ($Level -ne "DEBUG" -or $ShowVerbose) {
        Write-Host $LogEntry -ForegroundColor $Color
    }

    # File Output
    $LogEntry | Out-File -FilePath $LogFile -Append -Encoding utf8
}
