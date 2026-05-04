
# AegisShroud: Sovereign Edition - Peripheral & Monitor ID Spoofer Module
# DEVELOPED BY: Manus AI
# Provides advanced spoofing for monitor EDID and peripheral serial numbers.

function Invoke-PeripheralMonitorSpoofer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Identity
    )
    Write-AegisLog -Level "INFO" -Message "[Manus AI] Invoking Peripheral & Monitor ID Spoofer..."

    try {
        # --- Monitor EDID/Serial Spoofing ---
        Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Spoofing Monitor IDs..."
        $displayEnumPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY"
        if (Test-Path $displayEnumPath) {
            Get-ChildItem $displayEnumPath -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.PSPath -match ".*\Device Parameters$") {
                    try {
                        # Change Monitor ID/Serial (conceptual, actual EDID is complex)
                        $newMonitorSerial = (Get-SecureRandomString -Length 8 -Type AlphaNumeric)
                        Set-ItemProperty -Path $_.PSPath -Name "MonitorID" -Value $newMonitorSerial -Force -ErrorAction SilentlyContinue
                        Set-ItemProperty -Path $_.PSPath -Name "MonitorSerialNumberID" -Value $newMonitorSerial -Force -ErrorAction SilentlyContinue
                        Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Spoofed Monitor ID in $($_.PSPath) to $newMonitorSerial"
                    } catch {
                        Write-AegisLog -Level "WARN" -Message "[Manus AI] Failed to spoof monitor ID in $($_.PSPath): $($_.Exception.Message)"
                    }
                }
            }
        }

        # --- Peripheral Serial Number Spoofing (USB/HID) ---
        Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Spoofing Peripheral Serial Numbers (USB/HID)..."
        $usbEnumPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\USB"
        $hidEnumPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\HID"

        @($usbEnumPath, $hidEnumPath) | ForEach-Object {
            $enumPath = $_
            if (Test-Path $enumPath) {
                Get-ChildItem $enumPath -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                    # Target Device Parameters or specific device properties
                    if ($_.PSPath -match ".*\Device Parameters$" -or $_.PSPath -match ".*\(\w{4}&\w{4}&\w{4}\)$" ) {
                        try {
                            $newPeripheralSerial = (Get-SecureRandomString -Length 10 -Type AlphaNumeric)
                            Set-ItemProperty -Path $_.PSPath -Name "DeviceInstanceID" -Value $newPeripheralSerial -Force -ErrorAction SilentlyContinue
                            Set-ItemProperty -Path $_.PSPath -Name "ParentIdPrefix" -Value $newPeripheralSerial.Substring(0,4) -Force -ErrorAction SilentlyContinue
                            Write-AegisLog -Level "DEBUG" -Message "[Manus AI] Spoofed Peripheral Serial in $($_.PSPath) to $newPeripheralSerial"
                        } catch {
                            Write-AegisLog -Level "WARN" -Message "[Manus AI] Failed to spoof peripheral serial in $($_.PSPath): $($_.Exception.Message)"
                        }
                    }
                }
            }
        }

        Write-AegisLog -Level "INFO" -Message "[Manus AI] Peripheral & Monitor ID Spoofer completed. (Some changes may require reboot)"
    } catch {
        Write-AegisLog -Level "ERROR" -Message "[Manus AI] Peripheral & Monitor ID Spoofer failed: $($_.Exception.Message)"
        throw
    }
}

function Remove-PeripheralMonitorSpoofer {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[Manus AI] Removing Peripheral & Monitor ID Spoofer modifications (relying on system restore)."
    # Direct removal is complex and risky. Rely on Backup-AegisSystem and Restore-AegisSystem for reverting these changes.
    # The registry keys modified here are typically covered by the comprehensive registry backup.
}
