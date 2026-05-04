
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
        @{
            Manufacturer="ASUSTeK COMPUTER INC."; 
            Product="ROG STRIX Z790-E GAMING WIFI"; 
            CPU="13th Gen Intel(R) Core(TM) i9-13900K"; 
            GPU="NVIDIA GeForce RTX 4090"; 
            BiosVendor="American Megatrends Inc."; 
            BiosVersion="1202"; 
            BiosDate="03/15/2023";
            Serial="M7N9P2Q4R6S8T1U3";  # ASUS format: 16 chars alphanumeric
            Chassis="Desktop"; 
            DiskModel="Samsung SSD 990 PRO 2TB"; 
            DiskSerial="S67PNE0N101234A";
            MacPrefix="04:42:1A";  # ASUS OUI
            MonitorManufacturer="ACI";  # ASUS
            MonitorModel="VG27A";
            MonitorSerial="M7LMQS123456"
        },
        @{
            Manufacturer="Micro-Star International Co., Ltd."; 
            Product="MPG Z690 CARBON WIFI (MS-7D32)"; 
            CPU="12th Gen Intel(R) Core(TM) i7-12700K"; 
            GPU="NVIDIA GeForce RTX 3080 Ti"; 
            BiosVendor="American Megatrends International, LLC."; 
            BiosVersion="1.80"; 
            BiosDate="11/08/2022";
            Serial="601-7D32-013B1234567";  # MSI format
            Chassis="Desktop"; 
            DiskModel="WD_BLACK SN850X 1TB"; 
            DiskSerial="23334R0N101234B";
            MacPrefix="00:D8:61";  # MSI OUI
            MonitorManufacturer="MSI";
            MonitorModel="MAG274QRF";
            MonitorSerial="WMAA012345678"
        },
        @{
            Manufacturer="Gigabyte Technology Co., Ltd."; 
            Product="X670E AORUS MASTER"; 
            CPU="AMD Ryzen 9 7950X 16-Core Processor"; 
            GPU="AMD Radeon RX 7900 XTX"; 
            BiosVendor="American Megatrends International, LLC."; 
            BiosVersion="F8a"; 
            BiosDate="01/20/2023";
            Serial="SN-GB1234567890AB";  # Gigabyte format
            Chassis="Desktop"; 
            DiskModel="Crucial P5 Plus 2TB"; 
            DiskSerial="22334R0N101234C";
            MacPrefix="E0:D5:5E";  # Gigabyte OUI
            MonitorManufacturer="GSM";  # LG
            MonitorModel="27GP850";
            MonitorSerial="207NTABCD123"
        },
        @{
            Manufacturer="ASRock"; 
            Product="B650 STEEL LEGEND WIFI"; 
            CPU="AMD Ryzen 7 7800X3D 8-Core Processor"; 
            GPU="NVIDIA GeForce RTX 4070 Ti"; 
            BiosVendor="American Megatrends Inc."; 
            BiosVersion="2.04"; 
            BiosDate="12/05/2022";
            Serial="A70B650SL123456789";  # ASRock format
            Chassis="Desktop"; 
            DiskModel="Kingston KC3000 1TB"; 
            DiskSerial="50026B7684FE123A";
            MacPrefix="70:85:C2";  # ASRock OUI
            MonitorManufacturer="DEL";  # Dell
            MonitorModel="S2722DGM";
            MonitorSerial="4KW8Y33A1234"
        },
        @{
            Manufacturer="ASUS"; 
            Product="TUF GAMING B550-PLUS"; 
            CPU="AMD Ryzen 5 5600X 6-Core Processor"; 
            GPU="NVIDIA GeForce RTX 3060"; 
            BiosVendor="American Megatrends Inc."; 
            BiosVersion="2403"; 
            BiosDate="06/22/2022";
            Serial="S9T1U3V5W7X9Y1Z3";  # ASUS format
            Chassis="Desktop"; 
            DiskModel="Samsung SSD 980 PRO 1TB"; 
            DiskSerial="S5GXNX0RA12345B";
            MacPrefix="04:42:1A";  # ASUS OUI
            MonitorManufacturer="ACI";
            MonitorModel="VG259QM";
            MonitorSerial="L5LMQS234567"
        },
        @{
            Manufacturer="EVGA Corporation";
            Product="Z790 DARK K|NGP|N";
            CPU="13th Gen Intel(R) Core(TM) i9-13900KS";
            GPU="NVIDIA GeForce RTX 4080";
            BiosVendor="American Megatrends Inc.";
            BiosVersion="1.05";
            BiosDate="02/10/2023";
            Serial="E79DARK1234567890";  # EVGA format
            Chassis="Desktop";
            DiskModel="Corsair MP600 PRO XT 2TB";
            DiskSerial="21373R0N202345C";
            MacPrefix="00:E0:4C";  # Realtek OUI (common in EVGA)
            MonitorManufacturer="SAM";  # Samsung
            MonitorModel="S28AG70";
            MonitorSerial="HTPK123456"
        },
        @{
            Manufacturer="NZXT";
            Product="N7 Z790";
            CPU="13th Gen Intel(R) Core(TM) i7-13700K";
            GPU="NVIDIA GeForce RTX 4070";
            BiosVendor="American Megatrends International, LLC.";
            BiosVersion="0603";
            BiosDate="09/15/2022";
            Serial="NZN7Z790AB123456";  # NZXT format
            Chassis="Desktop";
            DiskModel="Seagate FireCuda 530 2TB";
            DiskSerial="7VS0N3LD123456";
            MacPrefix="00:50:B6";  # Intel OUI
            MonitorManufacturer="BNQ";  # BenQ
            MonitorModel="XL2546K";
            MonitorSerial="B3H01234567"
        },
        @{
            Manufacturer="BIOSTAR";
            Product="B650MT";
            CPU="AMD Ryzen 5 7600X 6-Core Processor";
            GPU="AMD Radeon RX 6700 XT";
            BiosVendor="American Megatrends Inc.";
            BiosVersion="5.19";
            BiosDate="08/30/2022";
            Serial="BS650MT987654321";  # BIOSTAR format
            Chassis="Desktop";
            DiskModel="ADATA XPG SX8200 Pro 1TB";
            DiskSerial="2L072L123456";
            MacPrefix="00:01:80";  # BIOSTAR OUI
            MonitorManufacturer="AOC";
            MonitorModel="24G2";
            MonitorSerial="AULMA0012345"
        }
    )
    
    $SelectedProfile = $Profiles[(Get-SecureRandomNumber -Min 0 -Max ($Profiles.Length - 1))]
    
    # Generate realistic MAC address with manufacturer OUI
    $macBytes = $SelectedProfile.MacPrefix -split ':'
    $macBytes += (1..3 | ForEach-Object { (Get-SecureRandomNumber -Min 0 -Max 255).ToString("X2") })
    $generatedMac = ($macBytes -join '').ToUpper()

    $Identity = @{
        MachineGuid = [guid]::NewGuid().ToString().ToUpper();
        ProductId = "$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))";
        ComputerName = "DESKTOP-" + (Get-SecureRandomString -Length 7);
        MacAddress = $generatedMac;  # Realistic MAC with OUI
        HwProfileGuid = "{" + [guid]::NewGuid().ToString().ToUpper() + "}";
        
        # USE REALISTIC VALUES FROM SELECTED PROFILE
        Manufacturer = $SelectedProfile.Manufacturer;
        Product = $SelectedProfile.Product;
        CPU = $SelectedProfile.CPU;
        GPU = $SelectedProfile.GPU;
        BiosVendor = $SelectedProfile.BiosVendor;
        BiosVersion = $SelectedProfile.BiosVersion;
        BiosDate = $SelectedProfile.BiosDate;
        Serial = $SelectedProfile.Serial;
        Chassis = $SelectedProfile.Chassis;
        DiskModel = $SelectedProfile.DiskModel;
        DiskSerial = $SelectedProfile.DiskSerial;
        
        # Monitor EDID values
        MonitorManufacturer = $SelectedProfile.MonitorManufacturer;
        MonitorModel = $SelectedProfile.MonitorModel;
        MonitorSerial = $SelectedProfile.MonitorSerial;
        
        MonitorID = "MON" + (Get-SecureRandomString -Length 4).ToUpper();
        UUID = [guid]::NewGuid().ToString().ToUpper();
    }
    
    Write-AegisLog -Level "INFO" -Message "[MinOz] Generated identity: $($Identity.Manufacturer) $($Identity.Product)"
    return $Identity
}

function Apply-AegisIdentity {
    param([hashtable]$Identity)
    Write-AegisLog -Level "INFO" -Message "[MinOz] Applying Brutal Identity Layers..."
    
    $successCount = 0
    $failCount = 0
    
    try {
        # 1. Core Identifiers
        try {
            if (Test-Path $RegCrypto) { 
                Set-ItemProperty -Path $RegCrypto -Name "MachineGuid" -Value $Identity.MachineGuid -Force -ErrorAction Stop
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] MachineGuid spoofed successfully"
                $successCount++
            }
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to spoof MachineGuid: $($_.Exception.Message)"
            $failCount++
        }
        
        try {
            if (Test-Path $RegWinNT) { 
                Set-ItemProperty -Path $RegWinNT -Name "ProductId" -Value $Identity.ProductId -Force -ErrorAction Stop
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] ProductId spoofed successfully"
                $successCount++
            }
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to spoof ProductId: $($_.Exception.Message)"
            $failCount++
        }
        
        try {
            if (Test-Path $RegCompName) { 
                Set-ItemProperty -Path $RegCompName -Name "ComputerName" -Value $Identity.ComputerName -Force -ErrorAction Stop
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] ComputerName spoofed successfully"
                $successCount++
            }
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to spoof ComputerName: $($_.Exception.Message)"
            $failCount++
        }
        
        # 2. BIOS & SMBIOS (Brutal Mode - Volatile Keys)
        try {
            if (Test-Path $RegBios) {
                Set-ItemProperty -Path $RegBios -Name "SystemManufacturer" -Value $Identity.Manufacturer -Force -ErrorAction Stop
                Set-ItemProperty -Path $RegBios -Name "SystemProductName" -Value $Identity.Product -Force -ErrorAction Stop
                Set-ItemProperty -Path $RegBios -Name "BIOSSerialNumber" -Value $Identity.Serial -Force -ErrorAction Stop
                Set-ItemProperty -Path $RegBios -Name "BaseBoardSerialNumber" -Value $Identity.Serial -Force -ErrorAction Stop
                Set-ItemProperty -Path $RegBios -Name "SystemSerialNumber" -Value $Identity.Serial -Force -ErrorAction Stop
                Set-ItemProperty -Path $RegBios -Name "BIOSVendor" -Value $Identity.BiosVendor -Force -ErrorAction Stop
                Set-ItemProperty -Path $RegBios -Name "BIOSVersion" -Value $Identity.BiosVersion -Force -ErrorAction Stop
                Set-ItemProperty -Path $RegBios -Name "ReleaseDate" -Value $Identity.BiosDate -Force -ErrorAction Stop
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] BIOS info spoofed successfully"
                $successCount++
            }
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to spoof BIOS: $($_.Exception.Message)"
            $failCount++
        }
        
        # 2b. PERMANENT BIOS Keys
        try {
            $RegBiosPermanent = "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation"
            if (-not (Test-Path $RegBiosPermanent)) {
                New-Item -Path $RegBiosPermanent -Force -ErrorAction Stop | Out-Null
            }
            Set-ItemProperty -Path $RegBiosPermanent -Name "SystemManufacturer" -Value $Identity.Manufacturer -Force -ErrorAction Stop
            Set-ItemProperty -Path $RegBiosPermanent -Name "SystemProductName" -Value $Identity.Product -Force -ErrorAction Stop
            Set-ItemProperty -Path $RegBiosPermanent -Name "BIOSVendor" -Value $Identity.BiosVendor -Force -ErrorAction Stop
            Set-ItemProperty -Path $RegBiosPermanent -Name "BIOSVersion" -Value $Identity.BiosVersion -Force -ErrorAction Stop
            Set-ItemProperty -Path $RegBiosPermanent -Name "BIOSReleaseDate" -Value $Identity.BiosDate -Force -ErrorAction Stop
            Write-AegisLog -Level "DEBUG" -Message "[MinOz] Permanent BIOS keys spoofed successfully"
            $successCount++
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to spoof permanent BIOS: $($_.Exception.Message)"
            $failCount++
        }

        # 3. CPU Masking
        try {
            if (Test-Path $RegCpu) { 
                Set-ItemProperty -Path $RegCpu -Name "ProcessorNameString" -Value $Identity.CPU -Force -ErrorAction Stop
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] CPU spoofed successfully"
                $successCount++
            }
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to spoof CPU: $($_.Exception.Message)"
            $failCount++
        }

        # 3b. GPU Masking
        try {
            $RegGpu = "HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY"
            $gpuSpoofed = $false
            if (Test-Path $RegGpu) {
                Get-ChildItem $RegGpu -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                    try {
                        Set-ItemProperty -Path $_.PSPath -Name "DeviceDesc" -Value $Identity.GPU -Force -ErrorAction SilentlyContinue
                        Set-ItemProperty -Path $_.PSPath -Name "FriendlyName" -Value $Identity.GPU -Force -ErrorAction SilentlyContinue
                        $gpuSpoofed = $true
                    } catch {}
                }
            }
            if ($gpuSpoofed) {
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] GPU spoofed successfully"
                $successCount++
            } else {
                Write-AegisLog -Level "WARN" -Message "[MinOz] No GPU keys found to spoof"
            }
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to spoof GPU: $($_.Exception.Message)"
            $failCount++
        }

        # 4. Network MAC Randomization
        try {
            $macSpoofed = 0
            $adapters = Get-ChildItem $RegNetworkClass -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match "^\d{4}$" }
            foreach ($a in $adapters) {
                try { 
                    Set-ItemProperty -Path $a.PSPath -Name "NetworkAddress" -Value $Identity.MacAddress -Force -ErrorAction Stop
                    $macSpoofed++
                } catch {}
            }
            Write-AegisLog -Level "DEBUG" -Message "[MinOz] MAC spoofed on $macSpoofed adapters"
            if ($macSpoofed -gt 0) { $successCount++ } else { $failCount++ }
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to spoof MAC: $($_.Exception.Message)"
            $failCount++
        }

        # 5. Disk & Storage Spoofing
        try {
            $diskSpoofed = $false
            if (Test-Path $RegDiskEnum) {
                Get-ChildItem $RegDiskEnum -ErrorAction SilentlyContinue | ForEach-Object {
                    Get-ChildItem $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
                        try { 
                            Set-ItemProperty -Path $_.PSPath -Name "FriendlyName" -Value $Identity.DiskModel -Force -ErrorAction SilentlyContinue
                            Set-ItemProperty -Path $_.PSPath -Name "SerialNumber" -Value $Identity.DiskSerial -Force -ErrorAction SilentlyContinue
                            $diskSpoofed = $true
                        } catch {}
                    }
                }
            }
            if (Test-Path $RegStorageEnum) {
                Get-ChildItem $RegStorageEnum -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                    try { 
                        Set-ItemProperty -Path $_.PSPath -Name "FriendlyName" -Value $Identity.DiskModel -Force -ErrorAction SilentlyContinue
                        $diskSpoofed = $true
                    } catch {}
                }
            }
            if ($diskSpoofed) {
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] Disk info spoofed successfully"
                $successCount++
            } else {
                Write-AegisLog -Level "WARN" -Message "[MinOz] No disk keys found to spoof"
            }
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Failed to spoof disk: $($_.Exception.Message)"
            $failCount++
        }

        # 6. Monitor EDID Spoofing
        try {
            Write-AegisLog -Level "DEBUG" -Message "[MinOz] Spoofing Monitor EDID data..."
            $monitorPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\DISPLAY"
            
            if (Test-Path $monitorPath) {
                $edidSpoofed = $false
                Get-ChildItem $monitorPath -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                    try {
                        $deviceParams = Join-Path $_.PSPath "Device Parameters"
                        if (Test-Path $deviceParams) {
                            # Create realistic EDID (128 bytes)
                            $edid = New-Object byte[] 128
                            # Fixed header
                            $edid[0..7] = 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00
                            
                            # Manufacturer ID (3 bytes from profile)
                            $mfgId = $Identity.MonitorManufacturer
                            if ($mfgId.Length -ge 3) {
                                $edid[8] = [byte][char]$mfgId[0]
                                $edid[9] = [byte][char]$mfgId[1]
                                $edid[10] = [byte][char]$mfgId[2]
                            }
                            
                            # Product code
                            $edid[10] = 0x01
                            $edid[11] = 0x00
                            
                            # Serial (4 bytes)
                            $serial = [BitConverter]::GetBytes((Get-SecureRandomNumber -Min 1000 -Max 9999))
                            $edid[12..15] = $serial[0..3]
                            
                            # Week/Year
                            $edid[16] = 0x01  # Week 1
                            $edid[17] = 0x1D  # Year 2023 (offset from 1990)
                            
                            # Version 1.4
                            $edid[18] = 0x01
                            $edid[19] = 0x04
                            
                            # Calculate checksum
                            $sum = 0
                            for ($i = 0; $i -lt 127; $i++) {
                                $sum = ($sum + $edid[$i]) % 256
                            }
                            $edid[127] = (256 - $sum) % 256
                            
                            Set-ItemProperty -Path $deviceParams -Name "EDID" -Value $edid -Force -ErrorAction Stop
                            $edidSpoofed = $true
                        }
                    } catch {
                        Write-AegisLog -Level "DEBUG" -Message "[MinOz] EDID spoof attempt: $($_.Exception.Message)"
                    }
                }
                if ($edidSpoofed) {
                    Write-AegisLog -Level "DEBUG" -Message "[MinOz] Monitor EDID spoofed"
                    $successCount++
                }
            }
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] Monitor EDID spoofing failed: $($_.Exception.Message)"
            $failCount++
        }
        
        # 7. USB Device History Cleaning
        try {
            Write-AegisLog -Level "DEBUG" -Message "[MinOz] Cleaning USB device history..."
            $usbCleaned = $false
            
            # USB Storage
            $usbStgPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR"
            if (Test-Path $usbStgPath) {
                Remove-Item -Path $usbStgPath -Recurse -Force -ErrorAction SilentlyContinue
                $usbCleaned = $true
            }
            
            # Portable Devices
            $portablePath = "HKLM:\SOFTWARE\Microsoft\Windows Portable Devices\Devices"
            if (Test-Path $portablePath) {
                Remove-Item -Path $portablePath -Recurse -Force -ErrorAction SilentlyContinue
                $usbCleaned = $true
            }
            
            if ($usbCleaned) {
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] USB history cleaned"
                $successCount++
            }
        } catch {
            Write-AegisLog -Level "WARN" -Message "[MinOz] USB cleaning failed: $($_.Exception.Message)"
            $failCount++
        }
        
        # 8. TPM Virtual Values
        try {
            $tpmPath = "HKLM:\SYSTEM\CurrentControlSet\Services\TPM\WMI"
            if (-not (Test-Path $tpmPath)) {
                New-Item -Path $tpmPath -Force -ErrorAction SilentlyContinue | Out-Null
            }
            
            # Realistic TPM values (Infineon)
            Set-ItemProperty -Path $tpmPath -Name "ManufacturerId" -Value 0x49465800 -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $tpmPath -Name "ManufacturerVersion" -Value "7.85" -Force -ErrorAction SilentlyContinue
            
            Write-AegisLog -Level "DEBUG" -Message "[MinOz] TPM values set"
            $successCount++
        } catch {
            $failCount++
        }
        
        # 9. Enhanced Network Adapter Spoofing
        try {
            $netAdapters = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}" -ErrorAction SilentlyContinue | 
                Where-Object { $_.PSChildName -match "^\d{4}$" }
            
            $netSpoofed = $false
            foreach ($adapter in $netAdapters) {
                try {
                    # MAC Address
                    Set-ItemProperty -Path $adapter.PSPath -Name "NetworkAddress" -Value $Identity.MacAddress -Force -ErrorAction SilentlyContinue
                    
                    # Driver Description
                    $desc = "Intel(R) Ethernet Connection ($(Get-SecureRandomNumber -Min 10 -Max 20)) I219-V"
                    Set-ItemProperty -Path $adapter.PSPath -Name "DriverDesc" -Value $desc -Force -ErrorAction SilentlyContinue
                    
                    $netSpoofed = $true
                } catch {}
            }
            
            if ($netSpoofed) {
                Write-AegisLog -Level "DEBUG" -Message "[MinOz] Network adapters enhanced"
                $successCount++
            }
        } catch {
            $failCount++
        }
        
        # 10. Additional System Keys
        try {
            # OEM Information
            $oemPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
            if (-not (Test-Path $oemPath)) {
                New-Item -Path $oemPath -Force -ErrorAction SilentlyContinue | Out-Null
            }
            Set-ItemProperty -Path $oemPath -Name "Manufacturer" -Value $Identity.Manufacturer -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $oemPath -Name "Model" -Value $Identity.Product -Force -ErrorAction SilentlyContinue
            
            Write-AegisLog -Level "DEBUG" -Message "[MinOz] Additional system keys set"
            $successCount++
        } catch {
            $failCount++
        }

        Write-AegisLog -Level "INFO" -Message "[MinOz] Identity spoofing complete: $successCount succeeded, $failCount failed"
    } catch {
        Write-AegisLog -Level "ERROR" -Message "[MinOz] Fatal error during spoofing: $($_.Exception.Message)"
        throw $_
    }
}
