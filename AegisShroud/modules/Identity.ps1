function New-AegisIdentity {
    Write-AegisLog -Level "INFO" -Message "Generating Ultimate Virtual Identity..."
    
    $Profiles = @(
        @{Manufacturer="ASUSTeK COMPUTER INC."; Product="ROG STRIX Z790-E GAMING"; CPU="13th Gen Intel(R) Core(TM) i9-13900K"; GPU="NVIDIA GeForce RTX 4090"; BiosVendor="American Megatrends Inc."; BiosVersion="1202"; Chassis="Desktop"; Monitor="ASUS ROG Swift PG279Q"},
        @{Manufacturer="Micro-Star International"; Product="MPG Z690 CARBON WIFI"; CPU="12th Gen Intel(R) Core(TM) i7-12700K"; GPU="NVIDIA GeForce RTX 3080 Ti"; BiosVendor="American Megatrends Inc."; BiosVersion="E7D32IMS"; Chassis="Desktop"; Monitor="MSI Optix MAG274QRF-QD"},
        @{Manufacturer="Gigabyte Technology"; Product="X670E AORUS MASTER"; CPU="AMD Ryzen 9 7950X 16-Core"; GPU="AMD Radeon RX 7900 XTX"; BiosVendor="American Megatrends Inc."; BiosVersion="F8"; Chassis="Desktop"; Monitor="Gigabyte M27Q"}
    )
    $Selected = $Profiles[(Get-Random -Min 0 -Max $Profiles.Count)]
    
    $Identity = @{
        MachineGuid = [guid]::NewGuid().ToString().ToUpper()
        ProductId = "$(Get-AegisRandomString 5)-$(Get-AegisRandomString 5)-$(Get-AegisRandomString 5)-$(Get-AegisRandomString 5)"
        ComputerName = "DESKTOP-$(Get-AegisRandomString 7)"
        MacAddress = ((1..6 | ForEach-Object { "{0:X2}" -f (Get-Random -Min 0 -Max 255) }) -join "")
        Manufacturer = $Selected.Manufacturer
        Product = $Selected.Product
        CPU = $Selected.CPU
        GPU = $Selected.GPU
        BiosVendor = $Selected.BiosVendor
        BiosVersion = $Selected.BiosVersion
        BiosDate = "2023/$((Get-Random -Min 1 -Max 12).ToString('D2'))/$((Get-Random -Min 1 -Max 28).ToString('D2'))"
        Serial = Get-AegisRandomString 12
        Chassis = $Selected.Chassis
        AssetTag = "Asset-$(Get-AegisRandomString 8)"
        Monitor = $Selected.Monitor
    }
    return $Identity
}

function Apply-AegisIdentity {
    param($Identity)
    Write-AegisLog -Level "INFO" -Message "Applying Ultimate Identity Layers..."

    $RegCrypto = "HKLM:\SOFTWARE\Microsoft\Cryptography"
    $RegWinNT = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $RegBios = "HKLM:\HARDWARE\DESCRIPTION\System\BIOS"
    $RegCpu = "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0"

    Set-AegisRegistryValue -Path $RegCrypto -Name "MachineGuid" -Value $Identity.MachineGuid
    Set-AegisRegistryValue -Path $RegWinNT -Name "ProductId" -Value $Identity.ProductId
    
    Set-AegisRegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" -Name "ComputerName" -Value $Identity.ComputerName
    Set-AegisRegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" -Name "ComputerName" -Value $Identity.ComputerName
    Set-AegisRegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "Hostname" -Value $Identity.ComputerName
    Set-AegisRegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "NV Hostname" -Value $Identity.ComputerName

    Set-AegisRegistryValue -Path $RegBios -Name "SystemManufacturer" -Value $Identity.Manufacturer
    Set-AegisRegistryValue -Path $RegBios -Name "SystemProductName" -Value $Identity.Product
    Set-AegisRegistryValue -Path $RegBios -Name "BIOSSerialNumber" -Value $Identity.Serial
    Set-AegisRegistryValue -Path $RegBios -Name "BIOSVendor" -Value $Identity.BiosVendor
    Set-AegisRegistryValue -Path $RegBios -Name "BIOSVersion" -Value $Identity.BiosVersion
    Set-AegisRegistryValue -Path $RegBios -Name "ReleaseDate" -Value $Identity.BiosDate
    Set-AegisRegistryValue -Path $RegBios -Name "ChassisType" -Value $Identity.Chassis
    Set-AegisRegistryValue -Path $RegBios -Name "ChassisAssetTag" -Value $Identity.AssetTag
    Set-AegisRegistryValue -Path $RegCpu -Name "ProcessorNameString" -Value $Identity.CPU

    $Adapters = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -and $_.MACAddress }
    foreach ($a in $Adapters) {
        $path = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\$($a.DeviceID.PadLeft(4, '0'))"
        Set-AegisRegistryValue -Path $path -Name "NetworkAddress" -Value $Identity.MacAddress
    }
}
