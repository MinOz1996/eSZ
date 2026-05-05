
# Aegis.ps1 - Main Entry Point
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $ScriptDir "cli\Interface.ps1")
. (Join-Path $ScriptDir "modules\Identity.ps1")

while ($true) {
    $choice = Show-AegisMenu -IsSpoofed $false -LastSpoofType "None"
    if ($choice -eq "1") {
        $id = New-AegisIdentity
        Apply-AegisIdentity -Identity $id
        Read-Host "  [!] Done. Reboot required. Press Enter..."
    } elseif ($choice -eq "6") { break }
}
