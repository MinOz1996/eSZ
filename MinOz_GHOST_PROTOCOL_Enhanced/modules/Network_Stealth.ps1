
# AegisShroud: Sovereign Edition - Network Stealth Module
# DEVELOPED BY: Manus AI
# Provides advanced network stack spoofing and stealth capabilities.

function Invoke-NetworkStealth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Identity
    )
    Write-AegisLog -Level "INFO" -Message "[Manus AI] Invoking Network Stealth Module..."

    try {
        # --- MAC Address Spoofing (if not already handled by Identity.ps1) ---
        # Identity.ps1 already handles MAC address spoofing via NetworkAddress registry key.
        # This section ensures that if Identity.ps1 is bypassed or needs re-enforcement, it's done.
        Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Re-enforcing MAC Address Spoofing..."
        $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }
        foreach ($adapter in $adapters) {
            $originalMac = $adapter.MACAddress
            $newMac = (New-RealisticMacAddress)
            
            # Update registry for persistent MAC spoofing
            $nicKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
            $nicInstance = Get-ChildItem $nicKeyPath -Recurse | Where-Object { $_.PSChildName -match "^\d{4}$" -and (Get-ItemProperty -Path $_.PSPath -Name "NetCfgInstanceId" -ErrorAction SilentlyContinue).NetCfgInstanceId -eq $adapter.SettingID }
            
            if ($nicInstance) {
                Set-ItemProperty -Path $nicInstance.PSPath -Name "NetworkAddress" -Value ($newMac -replace ":", "") -Force -ErrorAction SilentlyContinue
                Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Spoofed MAC for $($adapter.Description) from $originalMac to $newMac (Registry)"
            } else {
                Write-AegisLog -Level "WARN" -Message "[Manus AI] Could not find registry key for $($adapter.Description) to spoof MAC."
            }
        }

        # --- Network Stack Obfuscation (ARP Cache, DNS Cache, Winsock Reset) ---
        Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Obfuscating Network Stack..."
        ipconfig /flushdns | Out-Null
        netsh winsock reset | Out-Null
        netsh int ip reset | Out-Null
        arp -d * 2>$null
        Write-AegisLog -Level "INFO" -Message "[Manus AI] DNS, Winsock, IP Stack, and ARP Cache reset."

        # --- Clear NSI Traces (Network Store Interface) ---
        Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Clearing NSI Traces..."
        $nsiPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Nsi\{eb004a03-9b1a-11d4-9123-0050047759bc}\26"
        if (Test-Path $nsiPath) {
            Remove-Item $nsiPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-AegisLog -Level "INFO" -Message "[Manus AI] NSI Traces cleared."
        } else {
            Write-AegisLog -Level "WARN" -Message "[Manus AI] NSI Traces path not found: $nsiPath"
        }

        Write-AegisLog -Level "INFO" -Message "[Manus AI] Network Stealth Module completed."
    } catch {
        Write-AegisLog -Level "ERROR" -Message "[Manus AI] Network Stealth Module failed: $($_.Exception.Message)"
        throw
    }
}

function Remove-NetworkStealth {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[Manus AI] Removing Network Stealth modifications (relying on system restore and network resets)."
    # MAC address changes are reverted by Restore-AegisSystem if the relevant registry keys are backed up.
    # Network resets are temporary and will be re-established by the OS.
}
