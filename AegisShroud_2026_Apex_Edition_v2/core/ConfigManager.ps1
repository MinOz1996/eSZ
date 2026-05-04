# AegisShroud: Sovereign Edition - Enhanced Config Manager Module
# DEVELOPED BY: MinOz (Enhanced to Expert-Level by Claude)
# Enterprise-grade configuration management with validation and defaults

using namespace System.IO

#region Module Variables

$script:AegisConfig = $null
$script:ConfigSchema = @{
    Version     = @{ Type = "string"; Required = $true }
    Environment = @{ Type = "string"; Required = $true; ValidValues = @("Development", "Production") }
    LogLevel    = @{ Type = "string"; Required = $true; ValidValues = @("DEBUG", "INFO", "WARN", "ERROR") }
    Modules     = @{ Type = "hashtable"; Required = $true }
    Features    = @{ Type = "hashtable"; Required = $false }
}

#endregion

#region Configuration Loading

<#
.SYNOPSIS
    Loads and validates configuration from settings.json.
.DESCRIPTION
    - Loads config from file or creates default
    - Validates against schema
    - Returns singleton config instance
.OUTPUTS
    Configuration hashtable.
.EXAMPLE
    $config = Get-AegisConfig
#>
function Get-AegisConfig {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()
    
    # Return cached config if already loaded
    if ($null -ne $script:AegisConfig) {
        return $script:AegisConfig
    }
    
    Write-AegisLog -Level "INFO" -Message "Initializing configuration..."
    
    $configPath = Get-AegisConfigPath
    
    try {
        if (Test-Path $configPath) {
            # Load existing config
            $script:AegisConfig = Import-AegisConfig -Path $configPath
            Write-AegisLog -Level "INFO" -Message "Configuration loaded from: $configPath"
        }
        else {
            # Create default config
            $script:AegisConfig = New-DefaultConfig
            Export-AegisConfig -Config $script:AegisConfig -Path $configPath
            Write-AegisLog -Level "INFO" -Message "Default configuration created at: $configPath"
        }
        
        # Validate config
        $validation = Test-AegisConfig -Config $script:AegisConfig
        if (-not $validation.IsValid) {
            Write-AegisLog -Level "WARN" -Message "Configuration validation failed: $($validation.Errors -join ', ')"
            Write-AegisLog -Level "WARN" -Message "Using defaults for invalid fields"
            
            # Merge with defaults
            $script:AegisConfig = Merge-WithDefaults -Config $script:AegisConfig
        }
        
        return $script:AegisConfig
    }
    catch {
        Write-AegisLog -Level "ERROR" -Message "Failed to load configuration: $($_.Exception.Message)"
        Write-AegisLog -Level "WARN" -Message "Falling back to default configuration"
        
        # Fallback to defaults
        $script:AegisConfig = New-DefaultConfig
        return $script:AegisConfig
    }
}

<#
.SYNOPSIS
    Gets the configuration file path.
.OUTPUTS
    Full path to settings.json.
#>
function Get-AegisConfigPath {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    
    $root = $script:AegisRoot
    if ([string]::IsNullOrEmpty($root)) {
        $root = $PSScriptRoot
    }
    if ([string]::IsNullOrEmpty($root)) {
        $root = $PWD.Path
    }
    
    $configDir = Join-Path $root "config"
    
    # Ensure directory exists
    if (-not (Test-Path $configDir)) {
        try {
            $null = New-Item -Path $configDir -ItemType Directory -Force
        }
        catch {
            Write-AegisLog -Level "ERROR" -Message "Failed to create config directory: $($_.Exception.Message)"
        }
    }
    
    return Join-Path $configDir "settings.json"
}

<#
.SYNOPSIS
    Imports configuration from JSON file.
.PARAMETER Path
    Path to configuration file.
.OUTPUTS
    Configuration hashtable.
#>
function Import-AegisConfig {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    try {
        if (-not (Test-Path $Path)) {
            throw "Config file not found: $Path"
        }
        
        $json = Get-Content -Path $Path -Raw -ErrorAction Stop
        
        if ([string]::IsNullOrWhiteSpace($json)) {
            throw "Config file is empty"
        }
        
        $configObj = $json | ConvertFrom-Json -ErrorAction Stop
        
        if ($null -eq $configObj) {
            throw "Failed to parse JSON - result is null"
        }
        
        # Convert PSCustomObject to hashtable
        $hashtable = ConvertTo-Hashtable -InputObject $configObj
        
        if ($null -eq $hashtable) {
            throw "Conversion to hashtable returned null"
        }
        
        return $hashtable
    }
    catch {
        throw "Failed to import configuration from ${Path}: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Exports configuration to JSON file.
.PARAMETER Config
    Configuration hashtable.
.PARAMETER Path
    Path to configuration file.
#>
function Export-AegisConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Config,
        
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    try {
        $json = $Config | ConvertTo-Json -Depth 10
        Set-Content -Path $Path -Value $json -Encoding UTF8 -Force -ErrorAction Stop
    }
    catch {
        Write-AegisLog -Level "ERROR" -Message "Failed to export configuration: $($_.Exception.Message)"
    }
}

#endregion

#region Default Configuration

<#
.SYNOPSIS
    Creates default configuration.
.OUTPUTS
    Default configuration hashtable.
#>
function New-DefaultConfig {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()
    
    $root = $script:AegisRoot
    if ([string]::IsNullOrEmpty($root)) { $root = $PWD.Path }
    
    $logPath = Join-Path $root "logs\AegisShroud.log"
    
    return @{
        Version     = "Sovereign Edition 2.0 (Expert)"
        Environment = "Production"
        LogLevel    = "INFO"
        LogPath     = $logPath
        
        Modules     = @{
            Identity = @{
                Enabled         = $true
                ProfileDatabase = "default"
                RandomSeed      = $null
            }
            Cleaner  = @{
                Enabled       = $true
                DeepClean     = $true
                NetworkReset  = $true
                EventLogClear = $true
            }
        }
        
        Features    = @{
            DryRun          = $false
            Verification    = $true
            AutoRollback    = $true
            Persistence     = $true
            StealthMode     = $true
        }
        
        Safety      = @{
            RequireConfirmation  = $true
            BackupBeforeOperate  = $true
            MaxRollbackAttempts  = 3
        }
        
        Performance = @{
            BatchRegistryOps   = $true
            ParallelExecution  = $false
            MaxConcurrency     = 4
        }
    }
}

#endregion

#region Validation

<#
.SYNOPSIS
    Validates configuration against schema.
.PARAMETER Config
    Configuration to validate.
.OUTPUTS
    Validation result object with IsValid and Errors properties.
#>
function Test-AegisConfig {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Config
    )
    
    $errors = [System.Collections.ArrayList]::new()
    
    foreach ($key in $script:ConfigSchema.Keys) {
        $schema = $script:ConfigSchema[$key]
        
        # Check required fields
        if ($schema.Required -and -not $Config.ContainsKey($key)) {
            [void]$errors.Add("Missing required field: $key")
            continue
        }
        
        # Skip if field is optional and not present
        if (-not $Config.ContainsKey($key)) {
            continue
        }
        
        $value = $Config[$key]
        
        # Type validation
        $expectedType = $schema.Type
        $actualType = $value.GetType().Name.ToLower()
        
        if ($expectedType -eq "hashtable" -and $actualType -ne "hashtable") {
            [void]$errors.Add("Field '$key' must be hashtable, got: $actualType")
        }
        elseif ($expectedType -eq "string" -and $actualType -ne "string") {
            [void]$errors.Add("Field '$key' must be string, got: $actualType")
        }
        
        # Valid values check
        if ($schema.ContainsKey("ValidValues") -and $schema.ValidValues.Count -gt 0) {
            if ($value -notin $schema.ValidValues) {
                $validStr = $schema.ValidValues -join ", "
                [void]$errors.Add("Field '$key' has invalid value '$value'. Valid: [$validStr]")
            }
        }
    }
    
    return [PSCustomObject]@{
        IsValid = ($errors.Count -eq 0)
        Errors  = $errors.ToArray()
    }
}

<#
.SYNOPSIS
    Merges configuration with defaults for missing/invalid fields.
.PARAMETER Config
    Partial configuration.
.OUTPUTS
    Complete configuration with defaults filled in.
#>
function Merge-WithDefaults {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Config
    )
    
    $defaults = New-DefaultConfig
    $merged = $defaults.Clone()
    
    foreach ($key in $Config.Keys) {
        if ($Config[$key] -is [hashtable] -and $defaults[$key] -is [hashtable]) {
            # Deep merge for nested hashtables
            $merged[$key] = Merge-Hashtables -Base $defaults[$key] -Override $Config[$key]
        }
        else {
            $merged[$key] = $Config[$key]
        }
    }
    
    return $merged
}

<#
.SYNOPSIS
    Deep merges two hashtables.
.PARAMETER Base
    Base hashtable.
.PARAMETER Override
    Override hashtable.
.OUTPUTS
    Merged hashtable.
#>
function Merge-Hashtables {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Base,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$Override
    )
    
    $result = $Base.Clone()
    
    foreach ($key in $Override.Keys) {
        if ($Override[$key] -is [hashtable] -and $result[$key] -is [hashtable]) {
            $result[$key] = Merge-Hashtables -Base $result[$key] -Override $Override[$key]
        }
        else {
            $result[$key] = $Override[$key]
        }
    }
    
    return $result
}

#endregion

#region Helper Functions

<#
.SYNOPSIS
    Converts PSCustomObject to Hashtable recursively.
.PARAMETER InputObject
    Object to convert.
.OUTPUTS
    Hashtable.
#>
function ConvertTo-Hashtable {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$InputObject
    )
    
    process {
        if ($null -eq $InputObject) {
            return $null
        }
        
        if ($InputObject -is [hashtable]) {
            return $InputObject
        }
        
        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $collection = @()
            foreach ($item in $InputObject) {
                $collection += ConvertTo-Hashtable -InputObject $item
            }
            return $collection
        }
        
        if ($InputObject -is [PSCustomObject] -or $InputObject.GetType().Name -eq 'PSCustomObject') {
            $hash = @{}
            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
            }
            return $hash
        }
        
        return $InputObject
    }
}

#endregion

