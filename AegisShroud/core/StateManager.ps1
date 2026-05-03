function Get-SystemSnapshot {
    Write-AegisLog -Level "DEBUG" -Message "Capturing system state snapshot..."
    
    $Snapshot = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Registry = @{
            MachineGuid = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Cryptography" -Name "MachineGuid" -ErrorAction SilentlyContinue).MachineGuid
            ProductId = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductId" -ErrorAction SilentlyContinue).ProductId
            ComputerName = $env:COMPUTERNAME
        }
        Network = @()
    }

    $Adapters = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -and $_.MACAddress }
    foreach ($A in $Adapters) {
        $Snapshot.Network += @{
            Name = $A.Name
            MAC = $A.MACAddress
            DeviceID = $A.DeviceID
        }
    }

    return $Snapshot
}

function Save-AegisState {
    param(
        [Parameter(Mandatory=$true)]
        $State,
        [Parameter(Mandatory=$true)]
        [string]$Type # "Pre" or "Post"
    )
    $Id = Get-Date -Format "yyyyMMdd_HHmmss"
    $Path = Join-Path $PSScriptRoot "..\state\state_$($Type)_$Id.json"
    $State | ConvertTo-Json -Depth 10 | Set-Content $Path
    Write-AegisLog -Level "INFO" -Message "Saved $Type-execution state to $Path"
    return $Path
}
