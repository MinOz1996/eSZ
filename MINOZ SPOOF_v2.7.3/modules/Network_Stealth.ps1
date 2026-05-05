# MinOz GHOST PROTOCOL (2026) - Network Stealth Module

function Invoke-NetworkStealth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [hashtable]$Identity = @{}
    )
    Write-AegisLog -Level "INFO" -Message "[MinOz] Invoking Network Stealth Module..."

    # --- MAC Address Spoofing via Registry ---
    try {
        $nicKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
        
        # FIX: ใช้ -ErrorAction SilentlyContinue และกรอง -Depth ไม่ให้ลึก Properties subkey
        $nicKeys = Get-ChildItem $nicKeyPath -ErrorAction SilentlyContinue |
                   Where-Object { $_.PSChildName -match "^\d{4}$" }

        foreach ($nic in $nicKeys) {
            try {
                $newMac = New-RealisticMacAddress
                Set-ItemProperty -Path $nic.PSPath -Name "NetworkAddress" -Value ($newMac -replace ":", "") -Force -ErrorAction SilentlyContinue
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] Spoofed MAC at $($nic.PSChildName) to $newMac"
            } catch { }
        }
        Write-AegisLog -Level "INFO" -Message "[MinOz] MAC Address Spoofing complete."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] MAC spoofing partial: $($_.Exception.Message)"
    }

    # --- DNS / Winsock / ARP Reset ---
    try {
        & ipconfig /flushdns 2>&1 | Out-Null
        & netsh winsock reset 2>&1 | Out-Null
        & netsh int ip reset 2>&1 | Out-Null
        & arp -d * 2>&1 | Out-Null
        Write-AegisLog -Level "INFO" -Message "[MinOz] DNS, Winsock, IP Stack, and ARP Cache reset."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] Network reset partial: $($_.Exception.Message)"
    }

    # --- NSI Traces ---
    try {
        $nsiPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Nsi\{eb004a03-9b1a-11d4-9123-0050047759bc}\26"
        if (Test-Path $nsiPath) {
            Remove-Item $nsiPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-AegisLog -Level "INFO" -Message "[MinOz] NSI Traces cleared."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] NSI clear partial: $($_.Exception.Message)"
    }

    Write-AegisLog -Level "INFO" -Message "[MinOz] Network Stealth Module completed."
    # ไม่ throw - ให้ operation อื่นดำเนินต่อได้เสมอ
}

function Remove-NetworkStealth {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[MinOz] Network Stealth: relying on system restore."
}
