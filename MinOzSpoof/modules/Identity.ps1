
# AegisShroud: Sovereign Edition - Brutal Identity Module
# DEVELOPED BY: MinOz (Enhanced by Manus AI)
# This module handles extreme-level hardware identity virtualization.

#region Registry Paths (Standardized)
$RegCrypto = "HKLM:\SOFTWARE\Microsoft\Cryptography"
$RegWinNT = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
$RegCompName = "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName"
$RegTcpip = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
$RegBios = "HKLM:\HARDWARE\DESCRIPTION\System\BIOS"
$RegCpu = "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0"
$RegDiskEnum = "HKLM:\SYSTEM\CurrentControlSet\Enum\DISK"
$RegStorageEnum = "HKLM:\SYSTEM\CurrentControlSet\Enum\STORAGE"
$RegDisplayEnum = "HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY"
$RegNetworkClass = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
#endregion

function New-AegisIdentity {
    Write-AegisLog -Level "INFO" -Message "[MinOz] Generating Brutal Virtual Identity..."

    $Profiles = @(
        @{Manufacturer="ASUSTeK COMPUTER INC."; Product="ROG STRIX Z790-E GAMING"; CPU="13th Gen Intel(R) Core(TM) i9-13900K"; GPU="NVIDIA GeForce RTX 4090"; BiosVendor="American Megatrends Inc."; BiosVersion="1202"; Chassis="Desktop"; DiskModel="Samsung SSD 990 PRO 2TB"; DiskSerial="S67PNE0N101234A"},
        @{Manufacturer="Micro-Star International"; Product="MPG Z690 CARBON WIFI"; CPU="12th Gen Intel(R) Core(TM) i7-12700K"; GPU="NVIDIA GeForce RTX 3080 Ti"; BiosVendor="American Megatrends Inc."; BiosVersion="E7D32IMS"; Chassis="Desktop"; DiskModel="Western Digital SN850X 1TB"; DiskSerial="23334R0N101234B"},
        @{Manufacturer="Gigabyte Technology"; Product="X670E AORUS MASTER"; CPU="AMD Ryzen 9 7950X 16-Core"; GPU="AMD Radeon RX 7900 XTX"; BiosVendor="American Megatrends Inc."; BiosVersion="F8"; Chassis="Desktop"; DiskModel="Crucial P5 Plus 2TB"; DiskSerial="22334R0N101234C"}
    )
    $SelectedProfile = $Profiles[(Get-SecureRandomNumber -Min 0 -Max ($Profiles.Length - 1))]

    $Identity = @{
        MachineGuid = [guid]::NewGuid().ToString().ToUpper();
        ProductId = "$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))";
        ComputerName = "DESKTOP-" + (Get-SecureRandomString -Length 7);
        MacAddress = (1..6 | ForEach-Object { (Get-SecureRandomNumber -Min 0 -Max 255).ToString("X2") }) -join "";
        HwProfileGuid = "{" + [guid]::NewGuid().ToString().ToUpper() + "}";
        Manufacturer = $SelectedProfile.Manufacturer;
        Product = $SelectedProfile.Product;
        CPU = $SelectedProfile.CPU;
        GPU = $SelectedProfile.GPU;
        BiosVendor = $SelectedProfile.BiosVendor;
        BiosVersion = $SelectedProfile.BiosVersion;
        BiosDate = "$((Get-SecureRandomNumber -Min 2020 -Max 2023))/0$((Get-SecureRandomNumber -Min 1 -Max 9))/1$((Get-SecureRandomNumber -Min 0 -Max 9))";
        Serial = (Get-SecureRandomString -Length 12);
        Chassis = $SelectedProfile.Chassis;
        DiskModel = $SelectedProfile.DiskModel;
        DiskSerial = $SelectedProfile.DiskSerial;
        MonitorID = "MON" + (Get-SecureRandomString -Length 4).ToUpper();
        UUID = [guid]::NewGuid().ToString().ToUpper();
    }
    return $Identity
}

function Apply-AegisIdentity {
    param([hashtable]$Identity)
    Write-AegisLog -Level "INFO" -Message "[MinOz] Applying Brutal Identity Layers..."
    try {
        # 1. Core Identifiers
        if (Test-Path $RegCrypto) { Set-ItemProperty -Path $RegCrypto -Name "MachineGuid" -Value $Identity.MachineGuid -Force }
        if (Test-Path $RegWinNT) { Set-ItemProperty -Path $RegWinNT -Name "ProductId" -Value $Identity.ProductId -Force }
        if (Test-Path $RegCompName) { Set-ItemProperty -Path $RegCompName -Name "ComputerName" -Value $Identity.ComputerName -Force }
        
        # 2. BIOS & SMBIOS (Brutal Mode)
        if (Test-Path $RegBios) {
            Set-ItemProperty -Path $RegBios -Name "SystemManufacturer" -Value $Identity.Manufacturer -Force
            Set-ItemProperty -Path $RegBios -Name "SystemProductName" -Value $Identity.Product -Force
            Set-ItemProperty -Path $RegBios -Name "BIOSSerialNumber" -Value $Identity.Serial -Force
            Set-ItemProperty -Path $RegBios -Name "BaseBoardSerialNumber" -Value $Identity.Serial -Force
            Set-ItemProperty -Path $RegBios -Name "SystemSerialNumber" -Value $Identity.Serial -Force
            Set-ItemProperty -Path $RegBios -Name "BIOSVendor" -Value $Identity.BiosVendor -Force
            Set-ItemProperty -Path $RegBios -Name "BIOSVersion" -Value $Identity.BiosVersion -Force
            Set-ItemProperty -Path $RegBios -Name "ReleaseDate" -Value $Identity.BiosDate -Force
        }
        # UUID Virtualization
        $uuidPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OneSettings\WCM\Config"
        if (Test-Path $uuidPath) { Set-ItemProperty -Path $uuidPath -Name "UUID" -Value $Identity.UUID -Force -ErrorAction SilentlyContinue }

        # 3. CPU Masking
        if (Test-Path $RegCpu) { Set-ItemProperty -Path $RegCpu -Name "ProcessorNameString" -Value $Identity.CPU -Force }

        # 4. Network MAC Randomization (All Adapters)
        $adapters = Get-ChildItem $RegNetworkClass -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match "^\d{4}$" }
        foreach ($a in $adapters) {
            try { Set-ItemProperty -Path $a.PSPath -Name "NetworkAddress" -Value $Identity.MacAddress -Force -ErrorAction SilentlyContinue } catch {}
        }

        # 5. Brutal Disk & Storage Spoofing
        if (Test-Path $RegDiskEnum) {
            Get-ChildItem $RegDiskEnum -ErrorAction SilentlyContinue | ForEach-Object {
                Get-ChildItem $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
                    try { Set-ItemProperty -Path $_.PSPath -Name "FriendlyName" -Value $Identity.DiskModel -Force -ErrorAction SilentlyContinue } catch {}
                    try { Set-ItemProperty -Path $_.PSPath -Name "SerialNumber" -Value $Identity.DiskSerial -Force -ErrorAction SilentlyContinue } catch {}
                }
            }
        }
        if (Test-Path $RegStorageEnum) {
            Get-ChildItem $RegStorageEnum -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                try { Set-ItemProperty -Path $_.PSPath -Name "FriendlyName" -Value $Identity.DiskModel -Force -ErrorAction SilentlyContinue } catch {}
            }
        }

        # 6. Monitor EDID / Display Spoofing
        if (Test-Path $RegDisplayEnum) {
            Get-ChildItem $RegDisplayEnum -ErrorAction SilentlyContinue | ForEach-Object {
                Get-ChildItem $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
                    try { Set-ItemProperty -Path $_.PSPath -Name "DeviceDesc" -Value "Generic PnP Monitor" -Force -ErrorAction SilentlyContinue } catch {}
                    try { Set-ItemProperty -Path $_.PSPath -Name "HardwareID" -Value "MONITOR\$($Identity.MonitorID)" -Force -ErrorAction SilentlyContinue } catch {}
                }
            }
        }

        Write-AegisLog -Level "INFO" -Message "[MinOz] All Brutal Identity Layers Applied Successfully."
    } catch {
        Write-AegisLog -Level "ERROR" -Message "[MinOz] Failed to apply brutal identity: $($_.Exception.Message)"
        throw $_
    }
}
