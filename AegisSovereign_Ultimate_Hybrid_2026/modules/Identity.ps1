
# AegisShroud: Sovereign Edition - Brutal Identity Module (2026 APEX EDITION)
# DEVELOPED BY: MinOz (Enhanced by Manus AI)
# This module handles extreme-level hardware identity virtualization with 2026 Anti-Cheat bypass logic.

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
$RegTPM = "HKLM:\SYSTEM\CurrentControlSet\Control\Tpm\PlatformQuoteParameters"
$RegTPMConfig = "HKLM:\SYSTEM\CurrentControlSet\Services\TPM\WMI\Config"
#endregion

function New-AegisIdentity {
    Write-AegisLog -Level "INFO" -Message "[MinOz] Generating 2026 Apex Virtual Identity..."

    # Realistic Hardware DNA Profiles (2024-2026 Era)
    $Profiles = @(
        @{Manufacturer="ASUSTeK COMPUTER INC."; Product="ROG MAXIMUS Z790 DARK HERO"; CPU="Intel(R) Core(TM) i9-14900K"; GPU="NVIDIA GeForce RTX 4090"; BiosVendor="American Megatrends Inc."; BiosVersion="1503"; BiosDate="02/14/2024"; Chassis="Desktop"; DiskModel="Samsung SSD 990 PRO 4TB"; DiskSerial="S76PNE0W109876X"; MacPrefix="04:42:1A"},
        @{Manufacturer="Micro-Star International Co., Ltd."; Product="MEG Z790 ACE MAX"; CPU="Intel(R) Core(TM) i7-14700K"; GPU="NVIDIA GeForce RTX 4080 Super"; BiosVendor="American Megatrends Inc."; BiosVersion="M.40"; BiosDate="03/20/2024"; Chassis="Desktop"; DiskModel="WD_BLACK SN850X 2TB"; DiskSerial="24123R0N205432Y"; MacPrefix="00:D8:61"},
        @{Manufacturer="Gigabyte Technology Co., Ltd."; Product="X670E AORUS XTREME"; CPU="AMD Ryzen 9 7950X3D 16-Core Processor"; GPU="AMD Radeon RX 7900 XTX"; BiosVendor="American Megatrends Inc."; BiosVersion="F21"; BiosDate="01/10/2024"; Chassis="Desktop"; DiskModel="Crucial T700 2TB Gen5"; DiskSerial="23456R0N301234Z"; MacPrefix="E0:D5:5E"}
    )
    $SelectedProfile = $Profiles[(Get-SecureRandomNumber -Min 0 -Max ($Profiles.Length - 1))]

    $Identity = @{
        MachineGuid = [guid]::NewGuid().ToString().ToUpper();
        ProductId = "$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))";
        ComputerName = "DESKTOP-" + (Get-SecureRandomString -Length 7).ToUpper();
        MacAddress = $SelectedProfile.MacPrefix + (1..3 | ForEach-Object { (Get-SecureRandomNumber -Min 0 -Max 255).ToString("X2") }) -join "";
        HwProfileGuid = "{" + [guid]::NewGuid().ToString().ToUpper() + "}";
        Manufacturer = $SelectedProfile.Manufacturer;
        Product = $SelectedProfile.Product;
        CPU = $SelectedProfile.CPU;
        GPU = $SelectedProfile.GPU;
        BiosVendor = $SelectedProfile.BiosVendor;
        BiosVersion = $SelectedProfile.BiosVersion;
        BiosDate = $SelectedProfile.BiosDate;
        Serial = (Get-SecureRandomString -Length 14).ToUpper();
        Chassis = $SelectedProfile.Chassis;
        DiskModel = $SelectedProfile.DiskModel;
        DiskSerial = $SelectedProfile.DiskSerial;
        MonitorID = "MON" + (Get-SecureRandomString -Length 4).ToUpper();
        UUID = [guid]::NewGuid().ToString().ToUpper();
        TPM_EK = [guid]::NewGuid().ToString().ToUpper();
        TPM_SRK = [guid]::NewGuid().ToString().ToUpper();
    }
    return $Identity
}

function Apply-AegisIdentity {
    param([hashtable]$Identity)
    Write-AegisLog -Level "INFO" -Message "[MinOz] Applying 2026 Apex Identity Layers..."
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

        # 3. TPM & Secure Boot Masking (2026 Special)
        Write-AegisLog -Level "INFO" -Message "[MinOz] Masking TPM & Platform Security Identifiers..."
        $tpmPaths = @(
            "HKLM:\SYSTEM\CurrentControlSet\Control\Tpm\PlatformQuoteParameters",
            "HKLM:\SYSTEM\CurrentControlSet\Services\TPM\WMI\Config",
            "HKLM:\SOFTWARE\Microsoft\TPM"
        )
        foreach ($path in $tpmPaths) {
            if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
            try { Set-ItemProperty -Path $path -Name "EK_Pub_Hash" -Value $Identity.TPM_EK -Force -ErrorAction SilentlyContinue } catch {}
            try { Set-ItemProperty -Path $path -Name "SRK_Pub_Hash" -Value $Identity.TPM_SRK -Force -ErrorAction SilentlyContinue } catch {}
        }
        # Mask Secure Boot State in Registry
        $sbPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State"
        if (Test-Path $sbPath) { Set-ItemProperty -Path $sbPath -Name "UEFISecureBootEnabled" -Value 1 -Force -ErrorAction SilentlyContinue }

        # 4. Deep Disk & SCSI Geometry Masking
        Write-AegisLog -Level "INFO" -Message "[MinOz] Executing Deep Disk Geometry Masking..."
        if (Test-Path $RegDiskEnum) {
            Get-ChildItem $RegDiskEnum -ErrorAction SilentlyContinue | ForEach-Object {
                Get-ChildItem $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
                    try { Set-ItemProperty -Path $_.PSPath -Name "FriendlyName" -Value $Identity.DiskModel -Force -ErrorAction SilentlyContinue } catch {}
                    try { Set-ItemProperty -Path $_.PSPath -Name "SerialNumber" -Value $Identity.DiskSerial -Force -ErrorAction SilentlyContinue } catch {}
                    # Mask HardwareID to prevent direct geometry matching
                    try { Set-ItemProperty -Path $_.PSPath -Name "HardwareID" -Value "SCSI\DiskGenFake_$((Get-SecureRandomString -Length 8))" -Force -ErrorAction SilentlyContinue } catch {}
                }
            }
        }

        # 5. Network MAC Randomization (All Adapters)
        $adapters = Get-ChildItem $RegNetworkClass -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match "^\d{4}$" }
        foreach ($a in $adapters) {
            try { Set-ItemProperty -Path $a.PSPath -Name "NetworkAddress" -Value $Identity.MacAddress -Force -ErrorAction SilentlyContinue } catch {}
        }

        Write-AegisLog -Level "INFO" -Message "[MinOz] 2026 Apex Identity Layers Applied Successfully."
    } catch {
        Write-AegisLog -Level "ERROR" -Message "[MinOz] Failed to apply 2026 Apex identity: $($_.Exception.Message)"
        throw $_
    }
}
