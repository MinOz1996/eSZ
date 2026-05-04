# AegisShroud: Sovereign Edition - Enhanced Logger Module
# DEVELOPED BY: MinOz (Enhanced to Expert-Level by Claude)
# Enterprise-grade structured logging with rotation and context tracking

using namespace System.IO

#region Module Variables

$script:LogSessionId = $null
$script:LogContext = @{}
$script:MaxLogSizeMB = 10
$script:MaxLogFiles = 5

#endregion

#region Core Logging Functions

<#
.SYNOPSIS
    Writes structured log entry with context tracking.
.DESCRIPTION
    Enterprise-grade logging with:
    - Log rotation when size exceeds limit
    - Session tracking
    - Context enrichment
    - Thread-safe file operations
.PARAMETER Level
    Log level (DEBUG, INFO, WARN, ERROR).
.PARAMETER Message
    Log message.
.PARAMETER Context
    Additional context data (hashtable).
.EXAMPLE
    Write-AegisLog -Level "INFO" -Message "Operation started" -Context @{Operation="Spoof"; Target="Registry"}
#>
function Write-AegisLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR", "FATAL")]
        [string]$Level,

        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Context = @{}
    )
    
    # Initialize session ID if not exists
    if (-not $script:LogSessionId) {
        $script:LogSessionId = [Guid]::NewGuid().ToString("N").Substring(0, 8)
    }
    
    # Get log path
    $logPath = Get-AegisLogPath
    
    # Check and rotate logs if needed
    if (Test-Path $logPath) {
        $logSize = (Get-Item $logPath).Length / 1MB
        if ($logSize -gt $script:MaxLogSizeMB) {
            Invoke-LogRotation -LogPath $logPath
        }
    }
    
    # Get minimum log level from config
    $minLogLevel = "INFO"
    if ($script:AegisConfig -and $script:AegisConfig.LogLevel) {
        $minLogLevel = $script:AegisConfig.LogLevel
    }
    
    # Check if should log this level
    $logLevels = @{
        "DEBUG" = 1
        "INFO"  = 2
        "WARN"  = 3
        "ERROR" = 4
        "FATAL" = 5
    }
    
    if ($logLevels[$Level] -lt $logLevels[$minLogLevel]) {
        return
    }
    
    # Build structured log entry
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $thread = [Threading.Thread]::CurrentThread.ManagedThreadId
    
    # Merge global context with message context
    $fullContext = $script:LogContext.Clone()
    foreach ($key in $Context.Keys) {
        $fullContext[$key] = $Context[$key]
    }
    
    # Build context string
    $contextStr = ""
    if ($fullContext.Count -gt 0) {
        $contextPairs = $fullContext.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }
        $contextStr = " [{0}]" -f ($contextPairs -join ", ")
    }
    
    # Format log entry
    $logEntry = "{0} [{1}] [Session:{2}] [Thread:{3}] {4}{5}" -f `
        $timestamp, $Level, $script:LogSessionId, $thread, $Message, $contextStr
    
    # Write to file (thread-safe)
    try {
        $mutex = [Threading.Mutex]::new($false, "AegisShroudLogMutex")
        try {
            $null = $mutex.WaitOne()
            Add-Content -Path $logPath -Value $logEntry -Encoding UTF8 -ErrorAction Stop
        }
        finally {
            $mutex.ReleaseMutex()
            $mutex.Dispose()
        }
    }
    catch {
        # Fallback to non-mutex write
        try {
            Add-Content -Path $logPath -Value $logEntry -Encoding UTF8 -ErrorAction SilentlyContinue
        }
        catch {
            # Silent fail - cannot log about logging failure
        }
    }
    
    # Console output with colors
    Write-LogToConsole -Level $Level -Message $Message -Context $fullContext
}

<#
.SYNOPSIS
    Gets the log file path.
.OUTPUTS
    Full path to log file.
#>
function Get-AegisLogPath {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    
    # Determine root path
    $root = $script:AegisRoot
    if ([string]::IsNullOrEmpty($root)) {
        $root = $PSScriptRoot
    }
    if ([string]::IsNullOrEmpty($root)) {
        $root = $PWD.Path
    }
    
    $logDir = Join-Path $root "logs"
    
    # Ensure directory exists
    if (-not (Test-Path $logDir)) {
        try {
            $null = New-Item -Path $logDir -ItemType Directory -Force
        }
        catch {
            # Fallback to temp
            $logDir = $env:TEMP
        }
    }
    
    return Join-Path $logDir "AegisShroud.log"
}

<#
.SYNOPSIS
    Rotates log files when size limit is reached.
.PARAMETER LogPath
    Path to current log file.
#>
function Invoke-LogRotation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogPath
    )
    
    try {
        $logDir = Split-Path $LogPath -Parent
        $logName = Split-Path $LogPath -Leaf
        $baseName = [Path]::GetFileNameWithoutExtension($logName)
        $extension = [Path]::GetExtension($logName)
        
        # Remove oldest log if we have max files
        $existingLogs = Get-ChildItem -Path $logDir -Filter "${baseName}_*${extension}" |
            Sort-Object Name -Descending
        
        if ($existingLogs.Count -ge $script:MaxLogFiles) {
            $existingLogs | Select-Object -Last 1 | Remove-Item -Force -ErrorAction SilentlyContinue
        }
        
        # Rotate current log
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $rotatedName = "${baseName}_${timestamp}${extension}"
        $rotatedPath = Join-Path $logDir $rotatedName
        
        Move-Item -Path $LogPath -Destination $rotatedPath -Force -ErrorAction Stop
    }
    catch {
        # If rotation fails, try to truncate instead
        try {
            $content = Get-Content -Path $LogPath -Tail 1000
            Set-Content -Path $LogPath -Value $content -Force
        }
        catch {
            # Silent fail
        }
    }
}

<#
.SYNOPSIS
    Writes log to console with appropriate colors.
.PARAMETER Level
    Log level.
.PARAMETER Message
    Log message.
.PARAMETER Context
    Context data.
#>
function Write-LogToConsole {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Level,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Context = @{}
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $prefix = "[$timestamp] [$Level]"
    
    # Build context string for console
    $contextStr = ""
    if ($Context.Count -gt 0) {
        $contextPairs = $Context.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }
        $contextStr = " ({0})" -f ($contextPairs -join ", ")
    }
    
    $fullMessage = "$prefix $Message$contextStr"
    
    # Color mapping
    $color = switch ($Level) {
        "DEBUG" { "DarkGray" }
        "INFO"  { "White" }
        "WARN"  { "Yellow" }
        "ERROR" { "Red" }
        "FATAL" { "Magenta" }
        default { "Gray" }
    }
    
    Write-Host $fullMessage -ForegroundColor $color
}

#endregion

#region Context Management

<#
.SYNOPSIS
    Sets global log context that will be included in all log entries.
.PARAMETER Context
    Hashtable of context key-value pairs.
.EXAMPLE
    Set-AegisLogContext -Context @{User="Admin"; Operation="FullProtection"}
#>
function Set-AegisLogContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Context
    )
    
    $script:LogContext = $Context
}

<#
.SYNOPSIS
    Adds key-value pair to global log context.
.PARAMETER Key
    Context key.
.PARAMETER Value
    Context value.
.EXAMPLE
    Add-AegisLogContext -Key "Phase" -Value "Backup"
#>
function Add-AegisLogContext {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key,
        
        [Parameter(Mandatory = $true)]
        [object]$Value
    )
    
    $script:LogContext[$Key] = $Value
}

<#
.SYNOPSIS
    Clears global log context.
#>
function Clear-AegisLogContext {
    [CmdletBinding()]
    param()
    
    $script:LogContext = @{}
}

#endregion

#region Utility Functions

<#
.SYNOPSIS
    Creates a new log session (new session ID).
#>
function New-AegisLogSession {
    [CmdletBinding()]
    param()
    
    $script:LogSessionId = [Guid]::NewGuid().ToString("N").Substring(0, 8)
    Write-AegisLog -Level "INFO" -Message "=== New Log Session Started ==="
}

<#
.SYNOPSIS
    Exports recent log entries.
.PARAMETER Last
    Number of recent entries to export.
.OUTPUTS
    Array of log entry strings.
#>
function Get-AegisLogEntries {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory = $false)]
        [int]$Last = 100
    )
    
    $logPath = Get-AegisLogPath
    
    if (-not (Test-Path $logPath)) {
        return @()
    }
    
    try {
        return Get-Content -Path $logPath -Tail $Last
    }
    catch {
        return @()
    }
}

#endregion

