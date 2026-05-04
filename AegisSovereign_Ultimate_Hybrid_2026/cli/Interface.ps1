# AegisShroud Sovereign: Ultimate Hybrid Edition - Interface Module
# DEVELOPED BY: MinOz

function Show-AegisMenu {
    Clear-Host
    
    Write-Host ""
    Write-Host ""
    Write-Host "                  __  __   ___   _   _    ___    _____ " -ForegroundColor Green
    Write-Host "                 |  \/  | |_ _| | \ | |  / _ \  |__  / " -ForegroundColor Green
    Write-Host "                 | |\/| |  | |  |  \| | | | | |   / /  " -ForegroundColor Green
    Write-Host "                 | |  | |  | |  | |\  | | |_| |  / /_  " -ForegroundColor Green
    Write-Host "                 |_|  |_| |___| |_| \_|  \___/  /____| " -ForegroundColor Green
    Write-Host ""
    Write-Host "    ################################################################" -ForegroundColor Magenta
    Write-Host "    #                                                              #" -ForegroundColor Magenta
    Write-Host "    #           THE AEGIS SHROUD - SOVEREIGN EDITION               #" -ForegroundColor Magenta
    Write-Host "    #                  DEVELOPED BY: MinOz                         #" -ForegroundColor Magenta
    Write-Host "    #          Sovereign Hybrid Edition v2026.1                   #" -ForegroundColor Magenta
    Write-Host "    #                                                              #" -ForegroundColor Magenta
    Write-Host "    ################################################################" -ForegroundColor Magenta
    Write-Host ""
    
    Write-Host "    " -NoNewline
    Write-Host "[1] " -ForegroundColor Cyan -NoNewline
    Write-Host "FULL PROTECTION " -ForegroundColor Yellow -NoNewline
    Write-Host "(Backup + Randomize + Clean + Privacy + Persist)" -ForegroundColor DarkGray
    
    Write-Host "    " -NoNewline
    Write-Host "[2] " -ForegroundColor Green -NoNewline
    Write-Host "RESTORE ORIGINAL IDENTITY " -ForegroundColor Yellow -NoNewline
    Write-Host "(Remove Shroud & Persistence)" -ForegroundColor DarkGray
    
    Write-Host "    " -NoNewline
    Write-Host "[3] " -ForegroundColor Magenta -NoNewline
    Write-Host "VIEW CURRENT VIRTUAL PROFILE " -ForegroundColor Yellow -NoNewline
    Write-Host "(Full Detailed View)" -ForegroundColor DarkGray
    
    Write-Host "    " -NoNewline
    Write-Host "[4] " -ForegroundColor Red -NoNewline
    Write-Host "DEEP CLEAN TRACES ONLY" -ForegroundColor Yellow
    
    Write-Host "    " -NoNewline
    Write-Host "[5] " -ForegroundColor White -NoNewline
    Write-Host "EXIT" -ForegroundColor Red
    
    Write-Host ""
    Write-Host "    " -NoNewline
    Write-Host "Select an option [1-5]: " -ForegroundColor Cyan -NoNewline
    
    return Read-Host
}

function View-DetailedProfile {
    Write-AegisLog -Level "INFO" -Message "[MinOz] Displaying Profile..."
    
    try {
        $PreState = Get-SystemSnapshot -Type "Pre"
        $PostState = Get-SystemSnapshot -Type "Post"
        $CurrentState = Get-CurrentSystemIdentity

        Clear-Host
        
        # MinOz Header
        Write-Host ""
        Write-Host ""
        Write-Host "                  __  __   ___   _   _    ___    _____ " -ForegroundColor Green
        Write-Host "                 |  \/  | |_ _| | \ | |  / _ \  |__  / " -ForegroundColor Green
        Write-Host "                 | |\/| |  | |  |  \| | | | | |   / /  " -ForegroundColor Green
        Write-Host "                 | |  | |  | |  | |\  | | |_| |  / /_  " -ForegroundColor Green
        Write-Host "                 |_|  |_| |___| |_| \_|  \___/  /____| " -ForegroundColor Green
        Write-Host ""
        
        Write-Host "===============================================================================" -ForegroundColor Yellow
        Write-Host "           AEGIS SHROUD - SOVEREIGN EDITION: IDENTITY REPORT" -ForegroundColor Yellow
        Write-Host "===============================================================================" -ForegroundColor Yellow
        Write-Host ""

        $displayItems = @(
            @{Category="SYSTEM IDENTIFIERS"; Name="ComputerName"; Key="ComputerName"},
            @{Category="SYSTEM IDENTIFIERS"; Name="MachineGuid"; Key="MachineGuid"},
            @{Category="SYSTEM IDENTIFIERS"; Name="ProductId"; Key="ProductId"},
            @{Category="HARDWARE PROFILE"; Name="Manufacturer"; Key="Manufacturer"},
            @{Category="HARDWARE PROFILE"; Name="ProductName"; Key="Product"},
            @{Category="CPU & GPU"; Name="Processor"; Key="CPU"},
            @{Category="CPU & GPU"; Name="Graphics"; Key="GPU"},
            @{Category="FIRMWARE / BIOS"; Name="BiosVendor"; Key="BiosVendor"},
            @{Category="FIRMWARE / BIOS"; Name="SerialNumber"; Key="Serial"},
            @{Category="NETWORK & STORAGE"; Name="MacAddress"; Key="MacAddress"},
            @{Category="NETWORK & STORAGE"; Name="DiskModel"; Key="DiskModel"}
        )

        $currentCategory = ""
        foreach ($item in $displayItems) {
            if ($item.Category -ne $currentCategory) {
                Write-Host ""
                Write-Host "--- $($item.Category) ---" -ForegroundColor Magenta
                $currentCategory = $item.Category
            }
            
            $key = $item.Key
            
            $valCurrent = if ($CurrentState -and $CurrentState.$key) { $CurrentState.$key } else { "N/A" }
            $valPre = if ($PreState -and $PreState.$key) { $PreState.$key } else { $valCurrent }
            $valPost = if ($PostState -and $PostState.$key) { $PostState.$key } else { $valCurrent }

            $status = "UNCHANGED"
            $color = "White"
            
            if ($valPre -ne $valPost) {
                if ($valPost.ToString().Trim() -eq $valCurrent.ToString().Trim()) {
                    $status = "SUCCESS"
                    $color = "Green"
                } else {
                    $status = "PENDING REBOOT"
                    $color = "Yellow"
                }
            } elseif ($PreState -eq $null -and $PostState -eq $null) {
                $status = "LIVE/ORIGINAL"
                $color = "Cyan"
            }

            # ??????????????? (?????????)
            Write-Host ""
            Write-Host "  $($item.Name):" -ForegroundColor White
            
            # ???? Original
            Write-Host "    ORIGINAL : " -NoNewline -ForegroundColor Gray
            if ($valPre.ToString().Length -gt 60) {
                Write-Host $valPre.ToString().Substring(0, 57) -NoNewline -ForegroundColor $color
                Write-Host "..." -ForegroundColor $color
            } else {
                Write-Host $valPre.ToString() -ForegroundColor $color
            }
            
            # ???? Virtual
            Write-Host "    VIRTUAL  : " -NoNewline -ForegroundColor Gray
            if ($valPost.ToString().Length -gt 60) {
                Write-Host $valPost.ToString().Substring(0, 57) -NoNewline -ForegroundColor $color
                Write-Host "..." -ForegroundColor $color
            } else {
                Write-Host $valPost.ToString() -ForegroundColor $color
            }
            
            # ???? Status
            Write-Host "    STATUS   : [$status]" -ForegroundColor $color
        }

        Write-Host ""
        Write-Host "===============================================================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host " [" -NoNewline
        Write-Host "SUCCESS" -ForegroundColor Green -NoNewline
        Write-Host "] Value is active in current session." -ForegroundColor White
        
        Write-Host " [" -NoNewline
        Write-Host "PENDING REBOOT" -ForegroundColor Yellow -NoNewline
        Write-Host "] Value written but requires restart." -ForegroundColor White
        
        Write-Host " [" -NoNewline
        Write-Host "LIVE/ORIGINAL" -ForegroundColor Cyan -NoNewline
        Write-Host "] No spoofing detected. Real hardware." -ForegroundColor White
        
        Write-Host ""
        Write-Host "                      Powered by MinOz Technology" -ForegroundColor DarkGray
        Write-Host ""
    }
    catch {
        Write-Host ""
        Write-Host "[!] ERROR: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
    
    Read-Host "Press Enter to return to menu"
}
