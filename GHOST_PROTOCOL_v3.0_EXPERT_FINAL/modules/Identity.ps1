# MinOz GHOST PROTOCOL (2026) - Identity Module v3.0 Elite
# DEVELOPED BY: THE ARCHITECT ELITE SYSTEM

function New-EliteIdentity {
    $Profiles = @(
        @{Manufacturer="ASUSTeK COMPUTER INC."; Product="ROG MAXIMUS Z790 DARK HERO"; CPU="Intel(R) Core(TM) i9-14900K"; GPU="NVIDIA GeForce RTX 4090"; BiosVendor="American Megatrends Inc."; BiosVersion="1503"; BiosDate="02/14/2024"; MacPrefix="04421A"},
        @{Manufacturer="Micro-Star International Co., Ltd."; Product="MEG Z790 ACE MAX"; CPU="Intel(R) Core(TM) i7-14700K"; GPU="NVIDIA GeForce RTX 4080 Super"; BiosVendor="American Megatrends Inc."; BiosVersion="M.40"; BiosDate="03/20/2024"; MacPrefix="00D861"},
        @{Manufacturer="Gigabyte Technology Co., Ltd."; Product="X670E AORUS XTREME"; CPU="AMD Ryzen 9 7950X3D 16-Core Processor"; GPU="AMD Radeon RX 7900 XTX"; BiosVendor="American Megatrends Inc."; BiosVersion="F21"; BiosDate="01/10/2024"; MacPrefix="E0D55E"}
    )
    $p = $Profiles[(Get-SecureRandomNumber -Min 0 -Max ($Profiles.Length - 1))]
    $serial = (Get-SecureRandomString -Length 14).ToUpper()
    $macSuffix = (Get-SecureRandomString -Length 6 -Charset "0123456789ABCDEF").ToUpper()
    $macAddress = $p.MacPrefix + $macSuffix

    return @{
        MachineGuid  = [guid]::NewGuid().ToString().ToUpper()
        ProductId    = "$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))-$((Get-SecureRandomString -Length 5))"
        ComputerName = "DESKTOP-" + (Get-SecureRandomString -Length 7).ToUpper()
        Manufacturer = $p.Manufacturer
        Product      = $p.Product
        CPU          = $p.CPU
        GPU          = $p.GPU
        BiosVendor   = $p.BiosVendor
        BiosVersion  = $p.BiosVersion
        BiosDate     = $p.BiosDate
        Serial       = $serial
        Chassis      = "Desktop"
        MacAddress   = $macAddress
        DiskModel    = (Get-SecureRandomString -Length 8) + " SSD " + (Get-SecureRandomNumber -Min 1 -Max 4) + "TB"
        DiskSerial   = (Get-SecureRandomString -Length 20).ToUpper()
        VolumeId     = (Get-SecureRandomString -Length 8 -Charset "0123456789ABCDEF")
        UUID         = [guid]::NewGuid().ToString().ToUpper()
        TPM_EK       = "TPM-SPOOFED-" + (Get-SecureRandomString -Length 8).ToUpper()
    }
}

function Apply-AegisIdentity {
    param([hashtable]$Identity)
    Write-AegisLog -Level "INFO" -Message "Applying Global Identity Mutation..."
    
    # 1. Comprehensive Registry Backup
    $backupDir = Join-Path $script:AegisRoot "backup"
    if (!(Test-Path $backupDir)) { New-Item -Path $backupDir -ItemType Directory -Force }
    
    $backupKeys = @(
        @("HKLM\HARDWARE\DESCRIPTION\System\BIOS", "bios.reg"),
        @("HKLM\SYSTEM\CurrentControlSet\Control\SystemInformation", "sysinfo.reg"),
        @("HKLM\SOFTWARE\Microsoft\Cryptography", "crypto.reg"),
        @("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "winnt.reg"),
        @("HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName", "compname.reg"),
        @("HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}", "network.reg"),
        @("HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}", "gpu.reg")
    )

    foreach ($bk in $backupKeys) {
        $regPath = $bk[0]
        $fileName = $bk[1]
        $fullPath = Join-Path $backupDir $fileName
        if (!(Test-Path $fullPath)) {
            reg export "$regPath" "$fullPath" /y /reg:64 | Out-Null
        }
    }

    # 2. Core Identifiers (Deep)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid" -Value $Identity.MachineGuid -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductId" -Value $Identity.ProductId -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "BuildGUID" -Value ([guid]::NewGuid().ToString()) -Force -ErrorAction SilentlyContinue
    
    $compPaths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName",
        "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName",
        "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    )
    foreach ($cp in $compPaths) {
        Set-ItemProperty -Path $cp -Name "ComputerName" -Value $Identity.ComputerName -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cp -Name "Hostname" -Value $Identity.ComputerName -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cp -Name "NV Hostname" -Value $Identity.ComputerName -Force -ErrorAction SilentlyContinue
    }
    
    # 3. Hardware & BIOS (Deep Mutation - Expert Level)
    $paths = @(
        "HKLM:\HARDWARE\DESCRIPTION\System\BIOS", 
        "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation",
        "HKLM:\SYSTEM\HardwareConfig\Current"
    )
    foreach ($path in $paths) {
        if (!(Test-Path $path)) { New-Item -Path $path -Force -ErrorAction SilentlyContinue }
        Set-ItemProperty -Path $path -Name "SystemManufacturer" -Value $Identity.Manufacturer -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $path -Name "SystemProductName" -Value $Identity.Product -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $path -Name "BIOSVendor" -Value $Identity.BiosVendor -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $path -Name "BIOSVersion" -Value $Identity.BiosVersion -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $path -Name "BIOSReleaseDate" -Value $Identity.BiosDate -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $path -Name "SystemSerialNumber" -Value $Identity.Serial -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $path -Name "BaseBoardSerialNumber" -Value $Identity.Serial -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $path -Name "SystemUuid" -Value $Identity.UUID -Force -ErrorAction SilentlyContinue
        
        # Add Chassis Type (3 = Desktop, 9 = Laptop, 10 = Notebook)
        Set-ItemProperty -Path $path -Name "ChassisType" -Value "3" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $path -Name "EnclosureType" -Value "3" -Force -ErrorAction SilentlyContinue
    }
    
    # Extra deep keys for ACE/Anti-Cheat
    $extraPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation",
        "HKLM:\SYSTEM\CurrentControlSet\Control\IDConfigDB\Hardware Profiles\0001"
    )
    foreach ($p in $extraPaths) {
        if (!(Test-Path $p)) { New-Item -Path $p -Force -ErrorAction SilentlyContinue }
        Set-ItemProperty -Path $p -Name "Manufacturer" -Value $Identity.Manufacturer -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $p -Name "Model" -Value $Identity.Product -Force -ErrorAction SilentlyContinue
    }

    # 4. Task Manager Strings
    $cpuPath = "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor"
    Get-ChildItem $cpuPath -ErrorAction SilentlyContinue | ForEach-Object { 
        Set-ItemProperty -Path $_.PSPath -Name "ProcessorNameString" -Value $Identity.CPU -Force -ErrorAction SilentlyContinue 
    }
    
    $gpuPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
    Get-ChildItem $gpuPath -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match "^\d{4}$" } | ForEach-Object {
        Set-ItemProperty -Path $_.PSPath -Name "DriverDesc" -Value $Identity.GPU -Force -ErrorAction SilentlyContinue
    }

    # 5. Network Adapter
    $netPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"
    Get-ChildItem $netPath -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.PSChildName -match "^\d{4}$") {
            Set-ItemProperty -Path $_.PSPath -Name "NetworkAddress" -Value $Identity.MacAddress -Force -ErrorAction SilentlyContinue
        }
    }
}
