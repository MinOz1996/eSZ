
# AegisShroud: Sovereign Edition - User Interface Module (2026 APEX EDITION)
# DEVELOPED BY: MinOz (Enhanced by Manus AI)

function Show-AegisMenu {
    Clear-Host
    Write-Host ""
    Write-Host "                  __  __   ___   _   _    ___    _____ " -ForegroundColor Green
    Write-Host "                 |  \/  | |_ _| | \ | |  / _ \  |__  / " -ForegroundColor Green
    Write-Host "                 | |\/| |  | |  |  \| | | | | |   / /  " -ForegroundColor Green
    Write-Host "                 | |  | |  | |  | |\  | | |_| |  / /_  " -ForegroundColor Green
    Write-Host "                 |_|  |_| |___| |_| \_|  \___/  /____| " -ForegroundColor Green
    Write-Host ""
    Write-Host "====================================================================================================" -ForegroundColor Cyan
    Write-Host "                AEGIS SHROUD: BRUTAL SOVEREIGN - 2026 APEX EDITION (v2.0)" -ForegroundColor Cyan
    Write-Host "                            DEVELOPED BY: MinOz & Manus AI" -ForegroundColor Cyan
    Write-Host "====================================================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " [1] FULL PROTECTION (Spoof Identity + Deep Clean + Persistence)" -ForegroundColor Green
    Write-Host " [2] GENERATE NEW IDENTITY ONLY" -ForegroundColor Yellow
    Write-Host " [3] VIEW IDENTITY REPORT (PRE vs POST)" -ForegroundColor White
    Write-Host " [4] DEEP CLEAN TRACES ONLY" -ForegroundColor Magenta
    Write-Host " [5] EXIT" -ForegroundColor Red
    Write-Host ""
    Write-Host "====================================================================================================" -ForegroundColor Cyan
    $choice = Read-Host " Select an option [1-5]"
    return $choice
}

function View-DetailedProfile {
    $Pre = Get-SystemSnapshot -Type "Pre"
    $Post = Get-SystemSnapshot -Type "Post"
    
    Clear-Host
    Write-Host "====================================================================================================" -ForegroundColor Cyan
    Write-Host "                          AEGIS SHROUD - 2026 APEX EDITION: IDENTITY REPORT" -ForegroundColor Cyan
    Write-Host "====================================================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $FormatStr = "{0,-25} | {1,-35} | {2,-35}"
    Write-Host ($FormatStr -f "IDENTIFIER", "ORIGINAL (PRE)", "VIRTUAL (POST)") -ForegroundColor Yellow
    Write-Host ("-" * 100)

    $Keys = @("Manufacturer", "Product", "Serial", "MacAddress", "DiskSerial", "ComputerName", "MachineGuid", "TPM_EK")
    
    foreach ($Key in $Keys) {
        $PreVal = if ($Pre -and $Pre.ContainsKey($Key)) { $Pre[$Key] } else { "N/A" }
        $PostVal = if ($Post -and $Post.ContainsKey($Key)) { $Post[$Key] } else { "N/A" }
        
        # Truncate long GUIDs for display
        $PreDisp = if ($PreVal.Length -gt 32) { $PreVal.Substring(0, 29) + "..." } else { $PreVal }
        $PostDisp = if ($PostVal.Length -gt 32) { $PostVal.Substring(0, 29) + "..." } else { $PostVal }

        $Color = if ($PreVal -eq $PostVal) { "Gray" } else { "Green" }
        Write-Host ($FormatStr -f $Key, $PreDisp, $PostDisp) -ForegroundColor $Color
    }

    Write-Host ""
    Write-Host "====================================================================================================" -ForegroundColor Cyan
    Write-Host " [!] STATUS: $(if ($Pre -and $Post -and $Pre.Serial -ne $Post.Serial) { 'PROTECTION ACTIVE (REBOOT RECOMMENDED)' } else { 'SYSTEM ORIGINAL' })" -ForegroundColor $(if ($Pre -and $Post -and $Pre.Serial -ne $Post.Serial) { 'Green' } else { 'Yellow' })
    Read-Host " Press Enter to return to menu..."
}
