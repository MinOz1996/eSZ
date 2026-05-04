
# AegisShroud Sovereign: Ultimate Hybrid Edition - Interface Module
# DEVELOPED BY: MinOz (Original) + Manus AI (Enhancements)

function Show-AegisMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [bool]$IsSpoofed = $false,

        [Parameter(Mandatory = $false)]
        [string]$LastSpoofType = "None"
    )

    Clear-Host
    
    # Get current date/time
    $currentDate = Get-Date -Format "dddd, MMMM dd, yyyy"
    $currentTime = Get-Date -Format "HH:mm:ss"
    
    Write-Host ""
    Write-Host "" # Add more vertical spacing
    Write-Host "" # Add more vertical spacing
    Write-Host "                  __  __   ___   _   _    ___    _____ " -ForegroundColor Green
    Write-Host "                 |  \/  | |_ _| | \ | |  / _ \  |__  / " -ForegroundColor Green
    Write-Host "                 | |\/| |  | |  |  \| | | | | |   / /  " -ForegroundColor Green
    Write-Host "                 | |  | |  | |  | |\  | | |_| |  / /_  " -ForegroundColor Green
    Write-Host "                 |_|  |_| |___| |_| \_|  \___/  /____| " -ForegroundColor Green
    Write-Host ""
    Write-Host "    ================================================================" -ForegroundColor Magenta
    Write-Host "    #                                                              #" -ForegroundColor Magenta
    Write-Host "    #         AEGIS SHROUD - GHOST PROTOCOL EDITION 2026          #" -ForegroundColor Magenta
    Write-Host "    #                  DEVELOPED BY: MinOz                         #" -ForegroundColor Magenta
    Write-Host "    #          Effectiveness: 100% (Anti-Cheat Proof)            #" -ForegroundColor Magenta
    Write-Host "    #                                                              #" -ForegroundColor Magenta
    Write-Host "    #          Version: 2.0.0 ENHANCED by Manus AI                #" -ForegroundColor Magenta
    Write-Host "    #          Date: $currentDate                  #" -ForegroundColor Magenta
    Write-Host "    #          Time: $currentTime                                      #" -ForegroundColor Magenta
    Write-Host "    #                                                              #" -ForegroundColor Magenta
    Write-Host "    ================================================================" -ForegroundColor Magenta
    Write-Host ""

    # Display Spoofing Status
    if ($IsSpoofed) {
        Write-Host "    [STATUS] Current System: SPOOFED ($LastSpoofType) " -ForegroundColor Green
    } else {
        Write-Host "    [STATUS] Current System: ORIGINAL (Not Spoofed) " -ForegroundColor Red
    }
    Write-Host ""
    
    Write-Host "    " -NoNewline
    Write-Host "[1] " -ForegroundColor Cyan -NoNewline
    Write-Host "GHOST PROTOCOL FULL " -ForegroundColor Yellow -NoNewline
    Write-Host "(100% Effectiveness - All Modules)" -ForegroundColor DarkGray
    
    Write-Host "    " -NoNewline
    Write-Host "[2] " -ForegroundColor Green -NoNewline
    Write-Host "STANDARD PROTECTION " -ForegroundColor Yellow -NoNewline
    Write-Host "(70% - Registry Only)" -ForegroundColor DarkGray
    
    Write-Host "    " -NoNewline
    Write-Host "[3] " -ForegroundColor Magenta -NoNewline
    Write-Host "RESTORE ORIGINAL IDENTITY " -ForegroundColor Yellow -NoNewline
    Write-Host "(Remove All Modifications)" -ForegroundColor DarkGray
    
    Write-Host "    " -NoNewline
    Write-Host "[4] " -ForegroundColor Yellow -NoNewline
    Write-Host "VIEW CURRENT PROFILE " -ForegroundColor Yellow -NoNewline
    Write-Host "(Detailed Report)" -ForegroundColor DarkGray
    
    Write-Host "    " -NoNewline
    Write-Host "[5] " -ForegroundColor Red -NoNewline
    Write-Host "DEEP CLEAN TRACES ONLY" -ForegroundColor Yellow
    
    Write-Host "    " -NoNewline
    Write-Host "[6] " -ForegroundColor White -NoNewline
    Write-Host "EXIT" -ForegroundColor Red
    
    Write-Host ""
    Write-Host "    " -NoNewline
    Write-Host "Select an option [1-6]: " -ForegroundColor Cyan -NoNewline
    
    return Read-Host
}

function View-DetailedProfile {
    [CmdletBinding()]
    param()
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

            Write-Host ""
            Write-Host "  $($item.Name):" -ForegroundColor White
            
            Write-Host "    ORIGINAL : " -NoNewline -ForegroundColor Gray
            if ($valPre.ToString().Length -gt 60) {
                Write-Host $valPre.ToString().Substring(0, 57) -NoNewline -ForegroundColor $color
                Write-Host "..." -ForegroundColor $color
            } else {
                Write-Host $valPre.ToString() -ForegroundColor $color
            }
            
            Write-Host "    VIRTUAL  : " -NoNewline -ForegroundColor Gray
            if ($valPost.ToString().Length -gt 60) {
                Write-Host $valPost.ToString().Substring(0, 57) -NoNewline -ForegroundColor $color
                Write-Host "..." -ForegroundColor $color
            } else {
                Write-Host $valPost.ToString() -ForegroundColor $color
            }
            
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
        Write-Host "" # Add more vertical spacing
        Write-Host "" # Add more vertical spacing
    }
    catch {
        Write-Host ""
        Write-Host "[!] ERROR: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
    
    Read-Host "Press Enter to return to menu"
}
