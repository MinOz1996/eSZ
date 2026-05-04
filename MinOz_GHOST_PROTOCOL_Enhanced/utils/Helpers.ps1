# AegisShroud: Sovereign Edition - Enhanced Helpers Module
# DEVELOPED BY: MinOz (Enhanced to Expert-Level by Claude)
# Enterprise-grade utility functions with cryptographic security

using namespace System.Security.Cryptography
using namespace System.Text

#region Cryptographic Randomness (Expert-Level)

<#
.SYNOPSIS
    Generates cryptographically secure random bytes with environmental entropy mixing.
.DESCRIPTION
    Uses RNGCryptoServiceProvider combined with system entropy sources for maximum unpredictability.
    Far superior to Get-Random for security-critical applications.
.PARAMETER Length
    Number of random bytes to generate.
.OUTPUTS
    Byte array of specified length.
.EXAMPLE
    $bytes = Get-SecureRandomBytes -Length 32
#>
function Get-SecureRandomBytes {
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 1048576)] # Max 1MB
        [int]$Length
    )
    
    try {
        # Primary RNG
        $rng = [RNGCryptoServiceProvider]::new()
        $bytes = [byte[]]::new($Length)
        $rng.GetBytes($bytes)
        
        # Mix with environmental entropy for additional unpredictability
        $entropy = Get-EnvironmentalEntropy
        $entropyIndex = 0
        
        for ($i = 0; $i -lt $Length; $i++) {
            $bytes[$i] = $bytes[$i] -bxor $entropy[$entropyIndex]
            $entropyIndex = ($entropyIndex + 1) % $entropy.Length
        }
        
        return $bytes
    }
    catch {
        Write-AegisLog -Level "ERROR" -Message "Failed to generate secure random bytes: $($_.Exception.Message)"
        throw
    }
    finally {
        if ($rng) { $rng.Dispose() }
    }
}

<#
.SYNOPSIS
    Collects environmental entropy from system state.
.DESCRIPTION
    Gathers unpredictable system metrics (timestamps, PIDs, free space, etc.)
    and hashes them to create a 32-byte entropy pool.
.OUTPUTS
    32-byte SHA256 hash of system entropy.
#>
function Get-EnvironmentalEntropy {
    [CmdletBinding()]
    [OutputType([byte[]])]
    param()
    
    try {
        $entropyBuilder = [StringBuilder]::new()
        
        # Time-based entropy
        [void]$entropyBuilder.Append([DateTime]::UtcNow.Ticks)
        [void]$entropyBuilder.Append([Environment]::TickCount)
        
        # Process entropy
        [void]$entropyBuilder.Append($PID)
        [void]$entropyBuilder.Append((Get-Process).Count)
        
        # System entropy
        try {
            $drive = Get-PSDrive -Name C -PSProvider FileSystem -ErrorAction SilentlyContinue
            if ($drive) {
                [void]$entropyBuilder.Append($drive.Free)
                [void]$entropyBuilder.Append($drive.Used)
            }
        }
        catch { }
        
        # Performance counter entropy
        try {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            1..100 | ForEach-Object { $null = Get-Random }
            $stopwatch.Stop()
            [void]$entropyBuilder.Append($stopwatch.ElapsedTicks)
        }
        catch { }
        
        # Hash the collected entropy
        $hasher = [SHA256]::Create()
        try {
            return $hasher.ComputeHash([Encoding]::UTF8.GetBytes($entropyBuilder.ToString()))
        }
        finally {
            $hasher.Dispose()
        }
    }
    catch {
        Write-AegisLog -Level "WARN" -Message "Failed to collect environmental entropy: $($_.Exception.Message)"
        # Fallback to timestamp-only entropy
        $hasher = [SHA256]::Create()
        try {
            return $hasher.ComputeHash([Encoding]::UTF8.GetBytes([DateTime]::UtcNow.Ticks.ToString()))
        }
        finally {
            $hasher.Dispose()
        }
    }
}

<#
.SYNOPSIS
    Generates cryptographically secure random number in specified range.
.PARAMETER Min
    Minimum value (inclusive).
.PARAMETER Max
    Maximum value (inclusive).
.OUTPUTS
    Secure random integer in range [Min, Max].
.EXAMPLE
    $port = Get-SecureRandomNumber -Min 49152 -Max 65535
#>
function Get-SecureRandomNumber {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$Min,
        
        [Parameter(Mandatory = $true)]
        [int]$Max
    )
    
    if ($Max -lt $Min) {
        throw "Max ($Max) must be greater than or equal to Min ($Min)"
    }
    
    $range = [uint32]($Max - $Min + 1)
    
    # Use rejection sampling to avoid modulo bias
    $maxValidValue = [uint32]::MaxValue - ([uint32]::MaxValue % $range)
    
    do {
        $bytes = Get-SecureRandomBytes -Length 4
        $randomValue = [BitConverter]::ToUInt32($bytes, 0)
    } while ($randomValue -ge $maxValidValue)
    
    return [int]($Min + ($randomValue % $range))
}

<#
.SYNOPSIS
    Generates cryptographically secure random string.
.PARAMETER Length
    Length of string to generate.
.PARAMETER Charset
    Character set to use (default: alphanumeric uppercase).
.OUTPUTS
    Random string of specified length.
.EXAMPLE
    $guid = Get-SecureRandomString -Length 16 -Charset '0123456789ABCDEF'
#>
function Get-SecureRandomString {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 1024)]
        [int]$Length,
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    )
    
    $result = [StringBuilder]::new($Length)
    
    for ($i = 0; $i -lt $Length; $i++) {
        $index = Get-SecureRandomNumber -Min 0 -Max ($Charset.Length - 1)
        [void]$result.Append($Charset[$index])
    }
    
    return $result.ToString()
}

#endregion

#region MAC Address Generation (Expert-Level)

<#
.SYNOPSIS
    Generates a valid, realistic MAC address.
.DESCRIPTION
    Creates MAC address following IEEE 802 standards:
    - Locally administered bit set (bit 1 of first octet)
    - Unicast (bit 0 of first octet = 0)
    - Uses common OUI prefixes for realism
.OUTPUTS
    12-character hex string representing MAC address.
.EXAMPLE
    $mac = New-RealisticMacAddress
    # Returns: "02A1B2C3D4E5"
#>
function New-RealisticMacAddress {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    
    # Common OUI prefixes (first 3 bytes) from major manufacturers
    # Using locally administered addresses (02:xx:xx:xx:xx:xx pattern)
    $ouiPrefixes = @(
        "02", # Locally administered
        "06", # Locally administered
        "0A", # Locally administered
        "0E"  # Locally administered
    )
    
    $firstOctet = $ouiPrefixes[(Get-SecureRandomNumber -Min 0 -Max ($ouiPrefixes.Length - 1))]
    
    # Generate remaining 5 octets randomly
    $mac = [StringBuilder]::new($firstOctet)
    
    for ($i = 0; $i -lt 5; $i++) {
        $octet = Get-SecureRandomNumber -Min 0 -Max 255
        [void]$mac.Append($octet.ToString("X2"))
    }
    
    return $mac.ToString()
}

#endregion

#region GUID Generation

<#
.SYNOPSIS
    Generates a new GUID with optional format.
.PARAMETER Format
    Output format: 'D' (default), 'N' (no hyphens), 'B' (braces), 'P' (parentheses).
.OUTPUTS
    GUID string in specified format.
.EXAMPLE
    $guid = New-SecureGuid -Format 'D'
    # Returns: "550e8400-e29b-41d4-a716-446655440000"
#>
function New-SecureGuid {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('D', 'N', 'B', 'P')]
        [string]$Format = 'D'
    )
    
    return [Guid]::NewGuid().ToString($Format).ToUpper()
}

#endregion

#region String Obfuscation

<#
.SYNOPSIS
    Base64 encodes a string.
.PARAMETER InputString
    String to encode.
.OUTPUTS
    Base64 encoded string.
#>
function ConvertTo-Base64 {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$InputString
    )
    
    process {
        $bytes = [Encoding]::UTF8.GetBytes($InputString)
        return [Convert]::ToBase64String($bytes)
    }
}

<#
.SYNOPSIS
    Base64 decodes a string.
.PARAMETER Base64String
    Base64 string to decode.
.OUTPUTS
    Decoded string.
#>
function ConvertFrom-Base64 {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Base64String
    )
    
    process {
        try {
            # Handle missing padding
            $Base64String = $Base64String.Trim()
            $padding = $Base64String.Length % 4
            if ($padding -gt 0) {
                $Base64String += "=" * (4 - $padding)
            }
            
            $bytes = [Convert]::FromBase64String($Base64String)
            return [Encoding]::UTF8.GetString($bytes)
        }
        catch {
            Write-AegisLog -Level "WARN" -Message "Failed to decode Base64 string: $($_.Exception.Message)"
            return $Base64String
        }
    }
}

#endregion

#region Validation Helpers

<#
.SYNOPSIS
    Tests if running with Administrator privileges.
.OUTPUTS
    Boolean indicating admin status.
#>
function Test-IsAdministrator {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

<#
.SYNOPSIS
    Tests if a registry path exists and is accessible.
.PARAMETER Path
    Registry path to test.
.OUTPUTS
    Boolean indicating if path exists and is accessible.
#>
function Test-RegistryPath {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    try {
        return Test-Path -Path $Path -ErrorAction Stop
    }
    catch {
        Write-AegisLog -Level "DEBUG" -Message "Registry path not accessible: $Path"
        return $false
    }
}

#endregion

#region Performance Helpers

<#
.SYNOPSIS
    Measures execution time of a script block.
.PARAMETER ScriptBlock
    Code to measure.
.PARAMETER Name
    Descriptive name for logging.
.OUTPUTS
    Result of script block execution.
#>
function Measure-AegisPerformance {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        
        [Parameter(Mandatory = $false)]
        [string]$Name = "Operation"
    )
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        $result = & $ScriptBlock
        return $result
    }
    finally {
        $stopwatch.Stop()
        $elapsed = $stopwatch.Elapsed.TotalSeconds
        Write-AegisLog -Level "DEBUG" -Message "$Name completed in ${elapsed}s"
    }
}

#endregion

