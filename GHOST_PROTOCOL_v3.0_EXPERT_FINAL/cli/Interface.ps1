# MinOz GHOST PROTOCOL (2026) - Ultimate Elite Edition v3.0
# UI MODULE: THE ARCHITECT ELITE - DIAGNOSTIC REVISION

function Show-AegisMenu {
    param([bool]$IsSpoofed, [string]$LastSpoofType)
    Clear-Host
    $pad = "  "
    Write-Host ""
    Write-Host "      _______ _    _  ____   _____ _______   _____  _____   ____ _______ ____   _____ ____  _      " -ForegroundColor Red
    Write-Host "     | ______| |  | |/ __ \ / ____|__   __| |  __ \|  __ \ / __ \__   __/ __ \ / ____/ __ \| |     " -ForegroundColor Red
    Write-Host "     | |__   | |__| | |  | | (___    | |    | |__) | |__) | |  | | | | | |  | | |   | |  | | |     " -ForegroundColor Red
    Write-Host "     |  __|  |  __  | |  | |\___ \   | |    |  ___/|  _  /| |  | | | | | |  | | |   | |  | | |     " -ForegroundColor Red
    Write-Host "     | |____ | |  | | |__| |____) |  | |    | |    | | \ \| |__| | | | | |__| | |___| |__| | |____ " -ForegroundColor Red
    Write-Host "     |______||_|  |_|\____/|_____/   |_|    |_|    |_|  \_\\____/  |_|  \____/ \_____\____/|______|" -ForegroundColor Red
    Write-Host "                                                                                                   " -ForegroundColor Red
    Write-Host "                           [ GHOST PROTOCOL v3.0 - ELITE BRUTAL EDITION ]                          " -ForegroundColor White
    Write-Host "$pad" -NoNewline
    Write-Host "------------------------------------------------------------------------------------------" -ForegroundColor Gray
    $time = Get-Date -Format "HH:mm:ss"; $date = Get-Date -Format "dd/MM/yyyy"
    Write-Host "$pad" -NoNewline
    Write-Host "[ STATUS ] " -NoNewline -ForegroundColor Red
    if ($IsSpoofed) { Write-Host "ACTIVE " -NoNewline -ForegroundColor Green; Write-Host "($LastSpoofType MODE) " -NoNewline -ForegroundColor White }
    else { Write-Host "VULNERABLE " -NoNewline -ForegroundColor Red; Write-Host "(Original ID) " -NoNewline -ForegroundColor White }
    Write-Host "| [ SECURITY ] " -NoNewline -ForegroundColor Red; Write-Host "BYPASS ARMED " -NoNewline -ForegroundColor White
    Write-Host "| [ DATE ] " -NoNewline -ForegroundColor Red; Write-Host "$date $time" -ForegroundColor White
    Write-Host "$pad" -NoNewline
    Write-Host "------------------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host ""
    $menuItems = @(@("1", "GHOST PROTOCOL FULL", "Elite Hyper-Spoofing (All Modules + ACE Bypass)"), @("2", "STANDARD PROTECTION", "Basic Registry Masking & Network Stealth"), @("3", "RESTORE IDENTITY   ", "Factory Reset (Restore Original Hardware IDs)"), @("4", "VIEW CURRENT PROFILE", "Hardware Diagnostic & Identity Verification"), @("5", "DEEP CLEAN TRACES  ", "Obliterate ACE/Tencent Logs & USB/Arduino Traces"), @("6", "EXIT SYSTEM        ", "Terminate Ghost Protocol Instance"))
    foreach ($item in $menuItems) {
        Write-Host "$pad  " -NoNewline; Write-Host "[$($item[0])] " -NoNewline -ForegroundColor Red
        Write-Host "$($item[1])".PadRight(25) -NoNewline -ForegroundColor White
        Write-Host " :: " -NoNewline -ForegroundColor Gray; Write-Host "$($item[2])" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "$pad" -NoNewline; Write-Host "------------------------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host ""; $input = Read-Host "$pad >> SELECT COMMAND "; return $input
}

function View-DetailedProfile {
    Clear-Host
    $pad = "  "
    $current = Get-CurrentSystemIdentity
    $original = Get-SystemSnapshot -Type "Pre"
    
    # REAL-TIME COMPARISON LOGIC (NO FAKES)
    # We compare current registry values against the 'Pre' snapshot.
    # If 'Pre' doesn't exist, we cannot determine SPOOFED status accurately by comparison.
    if ($null -eq $original) { $original = $current }
    
    $ts = Get-Date -Format "HH:mm:ss        dd/MM/yyyy"

    Write-Host "`n$pad+-------------------------------------------------------------------------+" -ForegroundColor DarkMagenta
    Write-Host "$pad| THE ARCHITECT ELITE - IDENTITY DIAGNOSTIC REPORT                       |" -ForegroundColor Cyan
    Write-Host "$pad| Timestamp: $ts                                         |" -ForegroundColor Gray
    Write-Host "$pad+-------------------------------------------------------------------------+" -ForegroundColor DarkMagenta

    $sections = @(
        @{ Title="CORE SYSTEM IDENTIFIERS"; Fields=@(@("Computer Name", "ComputerName"), @("Machine GUID", "MachineGuid"), @("Product ID", "ProductId")) },
        @{ Title="HARDWARE MANUFACTURER"; Fields=@(@("Manufacturer", "Manufacturer"), @("Model Name", "Product"), @("Chassis Type", "Chassis")) },
        @{ Title="PROCESSOR & GRAPHICS"; Fields=@(@("CPU String", "CPU"), @("GPU String", "GPU")) },
        @{ Title="FIRMWARE & BIOS"; Fields=@(@("BIOS Vendor", "BiosVendor"), @("BIOS Version", "BiosVersion"), @("BIOS Date", "BiosDate"), @("System Serial", "Serial")) },
        @{ Title="NETWORK & STORAGE"; Fields=@(@("MAC Address", "MacAddress"), @("Disk Model", "DiskModel"), @("Disk Serial", "DiskSerial"), @("Volume ID", "VolumeId")) },
        @{ Title="ADVANCED SECURITY"; Fields=@(@("TPM EK ID", "TPM_EK"), @("UUID / SMBIOS", "UUID")) }
    )

    foreach ($sec in $sections) {
        Write-Host "$pad| " -NoNewline -ForegroundColor DarkMagenta
        Write-Host ">> $($sec.Title)" -ForegroundColor Yellow
        Write-Host "$pad| " -ForegroundColor DarkMagenta
        foreach ($f in $sec.Fields) {
            $label = $f[0].PadRight(15)
            $key = $f[1]
            $origVal = if ($original.$key) { $original.$key.ToString() } else { "N/A" }
            $currVal = if ($current.$key) { $current.$key.ToString() } else { "N/A" }
            
            # REAL STATUS LOGIC (Based on actual data difference)
            $status = "[ORIGINAL]"
            $color = [ConsoleColor]::Cyan
            
            # Compare current value with original snapshot value
            # If they differ, it is FACTUALLY spoofed in the registry.
            if ($origVal -ne $currVal) {
                $status = "[SPOOFED]"
                $color = [ConsoleColor]::Green
            }
            
            # Persistence Check: If IsSpoofed is true but values match, it's a FAIL (or reboot needed)
            # But for the UI, we only show GREEN if it's actually different.
            if ($global:IsSpoofed -and $origVal -eq $currVal) {
                # This might happen if a key failed to write or was reverted.
                # We stay Cyan to show it's NOT spoofed yet.
                $status = "[ORIGINAL]"
                $color = [ConsoleColor]::Cyan
            }

            $displayVal = $currVal
            if ($displayVal.Length -gt 35) { $displayVal = $displayVal.Substring(0, 32) + "..." }

            Write-Host "$pad|   $label : " -NoNewline -ForegroundColor Gray
            Write-Host "$($displayVal.PadRight(38))" -NoNewline -ForegroundColor $color
            Write-Host "$status" -ForegroundColor $color
        }
        Write-Host "$pad| " -ForegroundColor DarkMagenta
    }
    Write-Host "$pad+-------------------------------------------------------------------------+" -ForegroundColor DarkMagenta
    Write-Host ""
    Write-Host "$pad LEGEND: " -NoNewline -ForegroundColor Gray
    Write-Host "ORIGINAL " -NoNewline -ForegroundColor Cyan; Write-Host "(Safe/Clean) | " -NoNewline -ForegroundColor Gray
    Write-Host "SPOOFED " -NoNewline -ForegroundColor Green; Write-Host "(Bypass Active) | " -NoNewline -ForegroundColor Gray
    Write-Host "PENDING " -NoNewline -ForegroundColor Yellow; Write-Host "(Reboot Required)" -ForegroundColor Gray
    Write-Host ""
    Read-Host "$pad Press Enter to return to Command Center: "
}
