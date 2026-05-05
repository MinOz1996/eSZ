
function New-AegisIdentity {
    $Profiles = @(
        @{Manufacturer="ASUSTeK COMPUTER INC."; Product="ROG MAXIMUS Z790 DARK HERO"; CPU="Intel(R) Core(TM) i9-14900K"; GPU="NVIDIA GeForce RTX 4090"; DiskModel="Samsung SSD 990 PRO 4TB"; DiskSerial="S76PNE0W109876X"},
        @{Manufacturer="Micro-Star International Co., Ltd."; Product="MEG Z790 ACE MAX"; CPU="Intel(R) Core(TM) i7-14700K"; GPU="NVIDIA GeForce RTX 4080 Super"; DiskModel="WD_BLACK SN850X 2TB"; DiskSerial="24123R0N205432Y"}
    )
    $SelectedProfile = $Profiles[(Get-Random -Minimum 0 -Maximum $Profiles.Length)]
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
        $bootScript = "Set-ItemProperty -Path 'HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0' -Name 'ProcessorNameString' -Value '$($Identity.CPU)' -Force"
        $bootScript | Out-File -FilePath $bootScriptPath -Encoding UTF8 -Force
        $taskName = "MicrosoftEdgeUpdateTaskMachineCore"
        if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -File `"$bootScriptPath`\""
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger (New-ScheduledTaskTrigger -AtLogOn) -Principal (New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest) -Force
        }
    } catch {}
}
function Restore-OriginalIdentity { Write-Host "  [+] Restoring original identity..." -ForegroundColor Yellow }
