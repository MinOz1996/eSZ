
function New-AegisIdentity {
    $Profiles = @(
        @{Manufacturer="ASUSTeK COMPUTER INC."; Product="ROG MAXIMUS Z790 DARK HERO"; CPU="Intel(R) Core(TM) i9-14900K"; GPU="NVIDIA GeForce RTX 4090"; DiskModel="Samsung SSD 990 PRO 4TB"; DiskSerial="S76PNE0W109876X"; BiosVendor="American Megatrends International, LLC."; BiosVersion="3001"; BiosDate="01/01/2026"},
        @{Manufacturer="Micro-Star International Co., Ltd."; Product="MEG Z790 ACE MAX"; CPU="Intel(R) Core(TM) i7-14700K"; GPU="NVIDIA GeForce RTX 4080 Super"; DiskModel="WD_BLACK SN850X 2TB"; DiskSerial="24123R0N205432Y"; BiosVendor="American Megatrends International, LLC."; BiosVersion="E7D89IMS.100"; BiosDate="01/01/2026"}
    )
    $SelectedProfile = $Profiles[(Get-Random -Minimum 0 -Maximum $Profiles.Length)]
    
    $genericSerial = (-join ((65..90) + (48..57) | Get-Random -Count 12 | ForEach-Object {[char]$_}))

    $Identity = @{
        MachineGuid = [guid]::NewGuid().ToString().ToUpper();
        ProductId = "$((Get-Random -Minimum 10000 -Maximum 99999))-$((Get-Random -Minimum 10000 -Maximum 99999))-$((Get-Random -Minimum 10000 -Maximum 99999))-$((Get-Random -Minimum 10000 -Maximum 99999))";
        ComputerName = "DESKTOP-" + (-join ((65..90) + (48..57) | Get-Random -Count 7 | ForEach-Object {[char]$_}));
        MacAddress = "00:D8:61" + (1..3 | ForEach-Object { (Get-Random -Minimum 0 -Maximum 255).ToString("X2") }) -join "";
        Manufacturer = $SelectedProfile.Manufacturer;
        Product = $SelectedProfile.Product;
        CPU = $SelectedProfile.CPU;
        GPU = $SelectedProfile.GPU;
        DiskModel = $SelectedProfile.DiskModel;
        DiskSerial = $SelectedProfile.DiskSerial;
        
        # Additional fields for WMI Mutation and other modules
        UUID = [guid]::NewGuid().ToString().ToUpper();
        Serial = $genericSerial; # Generic serial for BaseBoard/BIOS
        BiosVendor = $SelectedProfile.BiosVendor;
        BiosVersion = $SelectedProfile.BiosVersion;
        BiosDate = $SelectedProfile.BiosDate;
    }
    return $Identity
}

function Apply-AegisIdentity {
    param([hashtable]$Identity)
    $registryMaps = @(
        @{ Path = "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName"; Name = "ComputerName"; Value = $Identity.ComputerName },
        @{ Path = "HKLM:\SOFTWARE\Microsoft\Cryptography"; Name = "MachineGuid"; Value = $Identity.MachineGuid },
        @{ Path = "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation"; Name = "SystemManufacturer"; Value = $Identity.Manufacturer },
        @{ Path = "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation"; Name = "SystemProductName"; Value = $Identity.Product },
        @{ Path = "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0"; Name = "ProcessorNameString"; Value = $Identity.CPU }
    )
    foreach ($reg in $registryMaps) {
        try { Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Force } catch {}
    }
    # Boot Persistence
    try {
        $bootScriptPath = Join-Path $env:APPDATA "aegis_boot.ps1"
        $bootScript = "Set-ItemProperty -Path \'HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0\' -Name \'ProcessorNameString\' -Value \'$($Identity.CPU)\' -Force"
        $bootScript | Out-File -FilePath $bootScriptPath -Encoding UTF8 -Force
        $taskName = "MicrosoftEdgeUpdateTaskMachineCore"
        if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -File `"$bootScriptPath`""
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger (New-ScheduledTaskTrigger -AtLogOn) -Principal (New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest) -Force
        }
    } catch { Write-Host "  [!] Error during boot persistence setup: $($_.Exception.Message)" -ForegroundColor Red }
}

function Restore-OriginalIdentity {
    Write-AegisLog -Level "INFO" -Message "[Identity] Restoring original system identity..."
    
    # Remove boot persistence task
    try {
        $taskName = "MicrosoftEdgeUpdateTaskMachineCore"
        if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
            Remove-Item (Join-Path $env:APPDATA "aegis_boot.ps1") -Force -ErrorAction SilentlyContinue
            Write-AegisLog -Level "INFO" -Message "[Identity] Removed boot persistence task."
        }
    } catch { Write-AegisLog -Level "WARN" -Message "[Identity] Failed to remove boot persistence: $($_.Exception.Message)" }

    # Direct registry changes by Apply-AegisIdentity are not automatically restored here.
    # For a full system restore, rely on Remove-GHOSTProtocol and potentially a system restore point.
    Write-AegisLog -Level "WARN" -Message "[Identity] Direct registry changes by Apply-AegisIdentity are not automatically restored here. Consider system restore."
}
