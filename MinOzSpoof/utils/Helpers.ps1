
# AegisShroud: Sovereign Edition - Helpers Module
# DEVELOPED BY: MinOz (Enhanced by Manus AI)
# This module provides common utility functions.

#region Randomness and Obfuscation Helpers

function Get-EnvironmentalEntropy {
    $entropy = ""
    $entropy += (Get-Date).Ticks.ToString()
    $entropy += $PID.ToString()
    $entropy += (Get-Process).Count.ToString()
    $systemDrive = Get-PSDrive -Name C -ErrorAction SilentlyContinue
    if ($systemDrive) { $entropy += $systemDrive.Free.ToString() }
    try { $entropy += (Get-CimInstance Win32_LogonSession | Where-Object {$_.LogonType -eq 2}).Count.ToString() } catch { $entropy += "0" }
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    (Get-Random -Minimum 0 -Maximum 1000 | Out-Null)
    $stopwatch.Stop()
    $entropy += $stopwatch.ElapsedTicks.ToString()

    $hasher = New-Object System.Security.Cryptography.SHA256Managed
    return $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($entropy))
}

function Get-SecureRandomBytes {
    param([int]$Length)
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[] $Length
    $entropy = Get-EnvironmentalEntropy
    $temp = New-Object byte[] $entropy.Length
    $rng.GetBytes($temp)
    for ($i = 0; $i -lt $entropy.Length; $i++) { $temp[$i] = $temp[$i] -bxor $entropy[$i] }
    $rng.GetBytes($bytes)
    return $bytes
}

function Get-SecureRandomNumber {
    param([int]$Min, [int]$Max)
    $bytes = Get-SecureRandomBytes -Length 4
    $num = [math]::Abs([System.BitConverter]::ToInt32($bytes, 0))
    return ($num % ($Max - $Min + 1)) + $Min
}

function Get-SecureRandomString {
    param([int]$Length, [string]$Charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789')
    $res = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $Length; $i++) {
        $idx = Get-SecureRandomNumber -Min 0 -Max ($Charset.Length - 1)
        [void]$res.Append($Charset[$idx])
    }
    return $res.ToString()
}

function Get-DeobfuscatedString {
    param([string]$Base64String)
    $Base64String = $Base64String.Trim()
    $padding = $Base64String.Length % 4
    if ($padding -gt 0) { $Base64String += "=" * (4 - $padding) }
    try { return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Base64String)) }
    catch { return $Base64String }
}

#endregion
