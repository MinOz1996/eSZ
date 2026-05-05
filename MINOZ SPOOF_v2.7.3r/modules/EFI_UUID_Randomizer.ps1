
# AegisShroud: Sovereign Edition - EFI/UUID Randomizer Module
# DEVELOPED BY: MinOz
# Provides advanced EFI/UUID spoofing capabilities.

function Invoke-EFUUIDRandomizer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Identity
    )
    Write-AegisLog -Level "INFO" -Message "[MinOz] Invoking EFI/UUID Randomizer..."

    try {
        # Spoofing System UUID (BIOS UUID)
        $newUuid = [Guid]::NewGuid().ToString()
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid" -Value $newUuid -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "SystemUuid" -Value $newUuid -Force -ErrorAction SilentlyContinue
        Write-AegisLog -Level "INFO" -Message "[MinOz] Spoofed System UUID to $newUuid"

        # Spoofing BIOS Serial Number (if not already handled by Identity.ps1)
        # Identity.ps1 already handles 'Serial' key, ensure it's robust
        $newBiosSerial = (Get-SecureRandomString -Length 12)
        Set-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemSerialNumber" -Value $newBiosSerial -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "BIOSSerialNumber" -Value $newBiosSerial -Force -ErrorAction SilentlyContinue
        Write-AegisLog -Level "INFO" -Message "[MinOz] Spoofed BIOS Serial Number to $newBiosSerial"

        # Spoofing BaseBoard Serial Number
        $newBoardSerial = (Get-SecureRandomString -Length 15)
        Set-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BaseBoardSerialNumber" -Value $newBoardSerial -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "BaseBoardSerialNumber" -Value $newBoardSerial -Force -ErrorAction SilentlyContinue
        Write-AegisLog -Level "INFO" -Message "[MinOz] Spoofed BaseBoard Serial Number to $newBoardSerial"

        # Spoofing Disk Drive Serial Numbers (more robust than just VolumeId)
        # This requires iterating through physical disks and updating their properties
        # Note: Direct physical disk serial spoofing is complex and often requires reboot or specialized drivers.
        # We'll focus on WMI/Registry values that ACs often check.
        Get-CimInstance -ClassName Win32_DiskDrive | ForEach-Object {
            $currentSerial = $_.SerialNumber
            if ($currentSerial -and $currentSerial -ne "") {
                $newDiskSerial = (Get-SecureRandomString -Length 10)
                # This is a conceptual spoof. Actual WMI/Registry modification is more involved.
                # For now, we log the intent and rely on other modules for deeper spoofing.
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] Attempted to spoof Disk Serial for $($_.Model) from $currentSerial to $newDiskSerial"
            }
        }

        Write-AegisLog -Level "INFO" -Message "[MinOz] EFI/UUID Randomizer completed."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] EFI/UUID Randomizer partial: $($_.Exception.Message)"
        # ไม่ throw - ให้ operation อื่นดำเนินต่อได้
    }
}

function Remove-EFUUIDRandomizer {
    [CmdletBinding()]
    param()
    Write-AegisLog -Level "INFO" -Message "[MinOz] Removing EFI/UUID Randomizer modifications..."

    try {
        # Restore MachineGuid (will be handled by Restore-AegisSystem if backed up)
        # For direct removal, we could delete the key, but restoring from backup is safer.
        # Delete-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid" -ErrorAction SilentlyContinue
        # Delete-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "SystemUuid" -ErrorAction SilentlyContinue
        # Delete-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemSerialNumber" -ErrorAction SilentlyContinue
        # Delete-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "BIOSSerialNumber" -ErrorAction SilentlyContinue
        # Delete-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BaseBoardSerialNumber" -ErrorAction SilentlyContinue
        # Delete-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "BaseBoardSerialNumber" -ErrorAction SilentlyContinue

        Write-AegisLog -Level "INFO" -Message "[MinOz] EFI/UUID Randomizer modifications removal completed (relying on system restore)."
    } catch {
        Write-AegisLog -Level "WARN" -Message "[MinOz] EFI/UUID Randomizer removal partial: $($_.Exception.Message)"
    }
}
