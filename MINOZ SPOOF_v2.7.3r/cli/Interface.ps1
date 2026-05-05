
function Show-AegisMenu {
    param(
        [Parameter(Mandatory=$true)]
        [bool]$IsSpoofed, 
        [Parameter(Mandatory=$true)]
        [string]$LastSpoofType
    )
    
    $W = 62
    $pad = "  "
    
    # PowerShell 5.1 compatible box characters
    $c_tl = [char]0x250C # ┌
    $c_tr = [char]0x2510 # ┐
    $c_bl = [char]0x2514 # └
    $c_br = [char]0x2518 # ┘
    $c_h  = [char]0x2500 # ─
    $c_v  = [char]0x2502 # │
    $c_ml = [char]0x251C # ├
    $c_mr = [char]0x2524 # ┤

    function BTop { Write-Host "  " -NoNewline; Write-Host ($c_tl + ($c_h * $W) + $c_tr) -ForegroundColor DarkMagenta }
    function BSep { Write-Host "  " -NoNewline; Write-Host ($c_ml + ($c_h * $W) + $c_mr) -ForegroundColor DarkMagenta }
    function BBot { Write-Host "  " -NoNewline; Write-Host ($c_bl + ($c_h * $W) + $c_br) -ForegroundColor DarkMagenta }
    function BLine { param($text, $color="White") 
        $t = $text.PadRight($W-2)
        Write-Host "  " -NoNewline; Write-Host $c_v -NoNewline -ForegroundColor DarkMagenta
        Write-Host " $t " -NoNewline -ForegroundColor $color
        Write-Host $c_v -ForegroundColor DarkMagenta
    }

    Clear-Host
    Write-Host ""
    $logo = @(
        'ICAgICAgICAgIOKWiOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKVlyAg4paI4paI4pWXICDilojilojilojilZcgIOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyAg4paI4paI4paI4paI4paI4paI4paI4pWX',
        'ICAgICAgICAgIOKWiOKWiOKWiOKWiOKVly DilojilojilojilojilZEgIOKWiOKWiOKVkSAg4paI4paI4paI4paI4pWXIOKWiOKWiOKVkSAg4paI4paI4pWU4pWQ4pWQ4pWQ4paI4paI4pWXICAgIOKWiOKWiOKWiOKVlOKVnQ==',
        'ICAgICAgICAgIOKWiOKWiOKVlOKWiOKWiOKWiOKWiOKVlOKWiOKWiOKVkSAg4paI4paI4pWRICDilojilojilZTilojilojilZfilojilojilZEgIOKWiOKWiOKVkSAgIOKWiOKWiOKVkSAgIOKWiOKWiOKWiOKVlOKVnQ==',
        'ICAgICAgICAgIOKWiOKWiOKVkeKVmuKWiOKWiOKVlOKVneKWiOKWiOKVkSAg4paI4paI4pWRICDilojilojilZHilZrilojilojilojilojilZEgIOKWiOKWiOKVkSAgIOKWiOKWiOKVkSAg4paI4paI4paI4pWU4pWd',
        'ICAgICAgICAgIOKWiOKWiOKVkSDilZrilZDilZ0g4paI4paI4pWRICDilojilojilZEgIOKWiOKWiOKVkSDilZrilojilojilojilZEgIOKVmuKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVnSAg4paI4paI4paI4paI4paI4paI4paI4pWX',
        'ICAgICAgICAgIOKVmuKVkOKVnSAgICAg4pWa4pWQ4pWdICDilZrilZDilZ0gIOKVmuKVkOKVnSAg4pWa4pWQ4pWQ4pWdICAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdICAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd'
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
    Write-Host "  [3.1] RESTORE IDENTITY      Remove All Mods & Restore Original" -ForegroundColor White
    Write-Host "  [4]  VIEW CURRENT PROFILE  Detailed Identity Report" -ForegroundColor White
    Write-Host "  [5]  DEEP CLEAN TRACES     Obliterate All Traces" -ForegroundColor White
    Write-Host "  [6]  EXIT                  Quit" -ForegroundColor White
    Write-Host ""
    Write-Host ("  " + ($c_h * 66)) -ForegroundColor DarkMagenta
    Write-Host ""
    Write-Host "  Select option [1-6] : " -NoNewline -ForegroundColor Cyan
    $input = Read-Host
    return $input
}

function Show-IdentityReport {
    param([hashtable]$Report)
    
    $c_tl = [char]0x250C
    $c_tr = [char]0x2510
    $c_bl = [char]0x2514
    $c_br = [char]0x2518
    $c_h  = [char]0x2500
    $c_v  = [char]0x2502

    Clear-Host
    Write-Host ""
    Write-Host ("  " + $c_tl + ($c_h * 70) + $c_tr) -ForegroundColor DarkMagenta
    Write-Host ("  " + $c_v + "  AEGIS SHROUD  --  IDENTITY REPORT".PadRight(70) + $c_v) -ForegroundColor DarkMagenta
    Write-Host ("  " + $c_v + "  $(Get-Date -Format 'HH:mm:ss    dd/MM/yyyy')".PadRight(70) + $c_v) -ForegroundColor DarkMagenta
    Write-Host ("  " + $c_bl + ($c_h * 70) + $c_br) -ForegroundColor DarkMagenta
    Write-Host ""
    
    if ($null -eq $Report -or $Report.Count -eq 0) {
        Write-Host "  [!] No identity data available." -ForegroundColor Red
    } else {
        foreach ($key in $Report.Keys) {
            $val = $Report[$key]
            Write-Host "  $($key.PadRight(20)) : $($val)" -ForegroundColor Gray
        }
    }
    Write-Host ""
    Read-Host "  Press Enter to return to menu"
}
