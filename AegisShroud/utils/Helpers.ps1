function Get-AegisEntropy {
    $Entropy = ""
    $Entropy += (Get-Date).Ticks.ToString()
    $Entropy += $PID.ToString()
    $Hasher = New-Object System.Security.Cryptography.SHA256Managed
    return $Hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Entropy))
}

function Get-AegisRandomString {
    param([int]$Length, [string]$Charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
    $Rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $Bytes = New-Object byte[] $Length
    $Rng.GetBytes($Bytes)
    $Res = New-Object System.Text.StringBuilder
    foreach ($B in $Bytes) {
        $Idx = $B % $Charset.Length
        [void]$Res.Append($Charset[$Idx])
    }
    return $Res.ToString()
}

function Set-AegisRegistryValue {
    param($Path, $Name, $Value)
    try {
        if (-not (Test-Path $Path)) { New-Item $Path -Force | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force
        Write-AegisLog -Level "DEBUG" -Message "Registry Set: $Path\$Name = $Value"
        return $true
    } catch {
        Write-AegisLog -Level "WARN" -Message "Failed to set registry $Path\$Name"
        return $false
    }
}
