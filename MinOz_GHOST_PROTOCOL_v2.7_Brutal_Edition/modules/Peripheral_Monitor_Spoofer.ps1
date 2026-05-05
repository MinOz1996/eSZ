# AegisShroud: Sovereign Edition - Peripheral & Monitor ID Spoofer Module

function Invoke-PeripheralMonitorSpoofer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [hashtable]$Identity = @{}
    )
    Write-AegisLog -Level "INFO" -Message "[MinOz] Invoking Peripheral & Monitor ID Spoofer..."

    try {
        # --- Monitor EDID/Serial Spoofing ---
        $displayEnumPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY"
        if (Test-Path $displayEnumPath) {
            $items = Get-ChildItem $displayEnumPath -Recurse -ErrorAction SilentlyContinue
            foreach ($item in $items) {
                # ตรวจสอบว่า item มี PSPath ก่อนใช้
                if ($item -and $item.PSPath -and $item.PSPath -match "Device Parameters$") {
                    try {
                        $newSerial = Get-SecureRandomString -Length 8
                        Set-ItemProperty -Path $item.PSPath -Name "MonitorID" -Value $newSerial -Force -ErrorAction SilentlyContinue
                        Set-ItemProperty -Path $item.PSPath -Name "MonitorSerialNumberID" -Value $newSerial -Force -ErrorAction SilentlyContinue
                        Write-AegisLog -Level "DEBUG" -Message "[MinOz] Spoofed Monitor ID to $newSerial"
                    } catch { }
                }
            }
        }

        # --- USB/HID Peripheral Spoofing ---
        foreach ($enumPath in @("HKLM:\SYSTEM\CurrentControlSet\Enum\USB", "HKLM:\SYSTEM\CurrentControlSet\Enum\HID")) {
            if (Test-Path $enumPath) {
                $items = Get-ChildItem $enumPath -Recurse -ErrorAction SilentlyContinue
                foreach ($item in $items) {
                    if ($item -and $item.PSPath -and ($item.PSPath -match "Device Parameters$")) {
                        try {
                            $newSerial = Get-SecureRandomString -Length 10
                            Set-ItemProperty -Path $item.PSPath -Name "ParentIdPrefix" -Value $newSerial.Substring(0,4) -Force -ErrorAction SilentlyContinue
                            Write-AegisLog -Level "DEBUG" -Message "[MinOz] Spoofed Peripheral in $($item.PSChildName)"
                        } catch { }
                    }
                }
            }
        }

        Write-AegisLog -Level "INFO" -Message "[MinOz] Peripheral & Monitor ID Spoofer completed."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] Peripheral Spoofer partial: $($_.Exception.Message)"
        # ไม่ throw - ให้ operation อื่นดำเนินต่อ
    }
}

function Remove-PeripheralMonitorSpoofer {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[MinOz] Peripheral Spoofer: relying on system restore."
}
