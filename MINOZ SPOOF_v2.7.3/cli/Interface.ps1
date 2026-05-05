
function Show-AegisMenu {
    param([bool]$IsSpoofed, [string]$LastSpoofType)
    $W = 62
    $pad = "  "
    function BTop { Write-Host "  " -NoNewline; Write-Host ([string]([char]0x250C) + ([string]([char]0x2500) * $W) + [char]0x2510) -ForegroundColor DarkMagenta }
    function BSep { Write-Host "  " -NoNewline; Write-Host ([string]([char]0x251C) + ([string]([char]0x2500) * $W) + [char]0x2524) -ForegroundColor DarkMagenta }
    function BBot { Write-Host "  " -NoNewline; Write-Host ([string]([char]0x2514) + ([string]([char]0x2500) * $W) + [char]0x2518) -ForegroundColor DarkMagenta }
    function BLine { param($text, $color="White") 
        $t = $text.PadRight($W-2)
        Write-Host "  " -NoNewline; Write-Host [char]0x2502 -NoNewline -ForegroundColor DarkMagenta
        Write-Host " $t " -NoNewline -ForegroundColor $color
        Write-Host [char]0x2502 -ForegroundColor DarkMagenta
    }
    Clear-Host
    Write-Host ""
    $logo = @(
        'ICAgICAgICAgIOKWiOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKVlyAg4paI4paI4pWXICDilojilojilojilZcgIOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyAg4paI4paI4paI4paI4paI4paI4paI4pWX',
        'ICAgICAgICAgIOKWiOKWiOKWiOKWiOKVlyDilojilojilojilojilZEgIOKWiOKWiOKVkSAg4paI4paI4paI4paI4pWXIOKWiOKWiOKVkSAg4paI4paI4pWU4pWQ4pWQ4pWQ4paI4paI4pWXICAgIOKWiOKWiOKWiOKVlOKVnQ==',
        'ICAgICAgICAgIOKWiOKWiOKVlOKWiOKWiOKWiOKWiOKVlOKWiOKWiOKVkSAg4paI4paI4pWRICDilojilojilZTilojilojilZfilojilojilZEgIOKWiOKWiOKVkSAgIOKWiOKWiOKVkSAgIOKWiOKWiOKWiOKVlOKVnQ==',
        'ICAgICAgICAgIOKWiOKWiOKVkeKVmuKWiOKWiOKVlOKVneKWiOKWiOKVkSAg4paI4paI4pWRICDilojilojilZHilZrilojilojilojilojilZEgIOKWiOKWiOKVkSAgIOKWiOKWiOKVkSAg4paI4paI4paI4pWU4pWd',
        'ICAgICAgICAgIOKWiOKWiOKVkSDilZrilZDilZ0g4paI4paI4pWRICDilojilojilZEgIOKWiOKWiOKVkSDilZrilojilojilojilZEgIOKVmuKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVnSAg4paI4paI4paI4paI4paI4paI4paI4pWX',
        'ICAgICAgICAgIOKVmuKVkOKVnSAgICAg4pWa4pWQ4pWdICDilZrilZDilZ0gIOKVmuKVkOKVnSAg4pWa4pWQ4pWQ4pWdICAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdICAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd',
    )

    foreach ($l in $logo) {
        $decoded = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($l))
        Write-Host ($pad + $decoded) -ForegroundColor Green
    }
    Write-Host ""
    BTop
    BLine ""
    BLine "       AEGIS SHROUD  --  GHOST PROTOCOL EDITION 2026" "Cyan"
    BLine "           DEVELOPED BY: MinOz  |  v2.7.3 (BRUTAL)" "Gray"
    BSep
    BLine ""
    BLine "          Effectiveness: 100%  .  Anti-Cheat Proof" "Yellow"
    BLine "                   $(Get-Date -Format 'dd/MM/yyyy     HH:mm:ss')" "Gray"
    BLine ""
    BSep
    BLine ""
    if ($IsSpoofed) { BLine "         [!] SPOOFED IDENTITY ACTIVE ($LastSpoofType)" "Green" } 
    else { BLine "         o  ORIGINAL IDENTITY  (No Active Spoofing)" "Blue" }
    BLine ""
    BBot
    Write-Host ""
    Write-Host "  [1]  GHOST PROTOCOL FULL   100% - All Modules Active" -ForegroundColor White
    Write-Host "  [2]  STANDARD PROTECTION   70%  - Registry Only" -ForegroundColor White
    Write-Host "  [3]  RESTORE IDENTITY      Remove All Mods & Restore Original" -ForegroundColor White
    Write-Host "  [4]  VIEW CURRENT PROFILE  Detailed Identity Report" -ForegroundColor White
    Write-Host "  [5]  DEEP CLEAN TRACES     Obliterate All Traces" -ForegroundColor White
    Write-Host "  [6]  EXIT                  Quit" -ForegroundColor White
    Write-Host ""
    Write-Host ("  " + ([string]([char]0x2500) * 66)) -ForegroundColor DarkMagenta
    Write-Host ""
    Write-Host "  Select option [1-6] : " -NoNewline -ForegroundColor Cyan
    $input = Read-Host
    return $input
}
function Show-IdentityReport {
    param([hashtable]$Report)
    Clear-Host
    Write-Host ""
    Write-Host ("  " + ([string]([char]0x250C) + ([string]([char]0x2500) * 70) + [char]0x2510)) -ForegroundColor DarkMagenta
    Write-Host ("  " + [char]0x2502 + "  AEGIS SHROUD  --  IDENTITY REPORT                                   " + [char]0x2502) -ForegroundColor DarkMagenta
    Write-Host ("  " + [char]0x2502 + "  $(Get-Date -Format 'HH:mm:ss    dd/MM/yyyy')                                ") + [char]0x2502 -ForegroundColor DarkMagenta
    Write-Host ("  " + ([string]([char]0x2514) + ([string]([char]0x2500) * 70) + [char]0x2518)) -ForegroundColor DarkMagenta
    Write-Host ""
    foreach ($key in $Report.Keys) {
        $val = $Report[$key]
        Write-Host "  $($key.PadRight(20)) : $($val)" -ForegroundColor Gray
    }
    Write-Host ""
    Read-Host "  Press Enter to return to menu"
}
