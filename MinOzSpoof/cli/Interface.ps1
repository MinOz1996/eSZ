
# AegisShroud: Sovereign Edition - CLI Interface Module
# DEVELOPED BY: MinOz (Enhanced by Manus AI)
# This module provides the command-line interface and visual dashboard.

function Show-AegisMenu {
    Clear-Host
    $W = 80 # Window Width for centering
    
    # ASCII Art - Centered
    $ascii = @(
        "  __  __   ___   _   _    ___    _____ ",
        " |  \/  | |_ _| | \ | |  / _ \  |__  / ",
        " | |\/| |  | |  |  \| | | | | |   / /  ",
        " | |  | |  | |  | |\  | | |_| |  / /_  ",
        " |_|  |_| |___| |_| \_|  \___/  /____| "
    )
    foreach ($line in $ascii) {
        $pad = [math]::Max(0, [int](($W - $line.Length) / 2))
        Write-Host (" " * $pad + $line) -ForegroundColor Green
    }
    
    Write-Host ""
    $border = "#" * 70
    $padBorder = [math]::Max(0, [int](($W - $border.Length) / 2))
    Write-Host (" " * $padBorder + $border) -ForegroundColor Magenta
    
    $lines = @(
        "#                                                                    #",
        "#             THE AEGIS SHROUD - SOVEREIGN EDITION                 #",
        "#                    DEVELOPED BY: MinOz                           #"
    )
    foreach ($line in $lines) {
        $pad = [math]::Max(0, [int](($W - $line.Length) / 2))
        Write-Host (" " * $pad + $line) -ForegroundColor Magenta
    }
    Write-Host (" " * $padBorder + $border) -ForegroundColor Magenta
    Write-Host ""

    $options = @(
        "[1] FULL PROTECTION (Backup + Randomize + Clean + Privacy + Persist)",
        "[2] RESTORE ORIGINAL IDENTITY (Remove Shroud & Persistence)",
        "[3] VIEW CURRENT VIRTUAL PROFILE (Full Detailed View)",
        "[4] DEEP CLEAN TRACES ONLY",
        "[5] EXIT"
    )
    foreach ($opt in $options) {
        $pad = [math]::Max(0, [int](($W - $opt.Length) / 2))
        Write-Host (" " * $pad + $opt) -ForegroundColor Magenta
    }
    
    Write-Host ""
    $prompt = "Select an option [1-5]: "
    $padPrompt = [math]::Max(0, [int](($W - 40) / 2)) # Adjust for prompt
    Write-Host (" " * $padPrompt + $prompt) -NoNewline -ForegroundColor Cyan
    return Read-Host
}

function View-DetailedProfile {
    Write-AegisLog -Level "INFO" -Message "[MinOz] Displaying Detailed Virtual Profile..."
    try {
        $PreState = Get-SystemSnapshot -Type "Pre"
        $PostState = Get-SystemSnapshot -Type "Post"
        $CurrentState = Get-CurrentSystemIdentity

        Clear-Host
        $W = 110
        Write-Host ("=" * $W) -ForegroundColor Yellow
        
        $title = "AEGIS SHROUD - SOVEREIGN EDITION: IDENTITY REPORT"
        $titlePad = [math]::Max(0, [int](($W - $title.Length) / 2))
        Write-Host (" " * $titlePad + $title) -ForegroundColor Yellow
        
        Write-Host ("=" * $W) -ForegroundColor Yellow
        
        # Header
        $header = "{0,-20} : {1,-35} | {2,-35} | {3}" -f "PROPERTY", "ORIGINAL (PRE)", "VIRTUAL (POST)", "STATUS"
        Write-Host $header -ForegroundColor Gray
        Write-Host ("-" * $W) -ForegroundColor Gray

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
                Write-Host "`n--- $($item.Category) ---" -ForegroundColor Cyan
                $currentCategory = $item.Category
            }
            
            $key = $item.Key
            
            # Current value is always live
            $valCurrent = if ($CurrentState -and $CurrentState.$key) { $CurrentState.$key } else { "N/A" }
            
            # If no spoofing has occurred, Pre and Post should reflect Current
            $valPre = if ($PreState -and $PreState.$key) { $PreState.$key } else { $valCurrent }
            $valPost = if ($PostState -and $PostState.$key) { $PostState.$key } else { $valCurrent }

            $status = "UNCHANGED"
            $color = "White"
            
            # Logic for status determination
            if ($valPre -ne $valPost) {
                # Spoofing has been attempted
                if ($valPost.ToString().Trim() -eq $valCurrent.ToString().Trim()) {
                    $status = "SUCCESS"
                    $color = "Green"
                } else {
                    $status = "PENDING REBOOT"
                    $color = "Yellow"
                }
            } elseif ($PreState -eq $null -and $PostState -eq $null) {
                # No spoofing session found
                $status = "LIVE/ORIGINAL"
                $color = "Cyan"
            }

            # Truncate long values for display
            $dispPre = if ($valPre.ToString().Length -gt 35) { $valPre.ToString().Substring(0, 32) + "..." } else { $valPre.ToString() }
            $dispPost = if ($valPost.ToString().Length -gt 35) { $valPost.ToString().Substring(0, 32) + "..." } else { $valPost.ToString() }

            # Manual padding for stability
            $line = "{0,-20} : {1,-35} | {2,-35} | " -f $item.Name, $dispPre, $dispPost
            Write-Host $line -NoNewline -ForegroundColor $color
            Write-Host "[$status]" -ForegroundColor $color
        }

        Write-Host "`n" + ("=" * $W) -ForegroundColor Yellow
        Write-Host " [!] SUCCESS: Value is active in current session." -ForegroundColor Green
        Write-Host " [!] PENDING REBOOT: Value written to registry but requires restart to load into Kernel." -ForegroundColor Yellow
        Write-Host " [!] LIVE/ORIGINAL: No spoofing session detected. Showing real hardware values." -ForegroundColor Cyan
    } catch {
        Write-Host "`n[!] CRITICAL ERROR DISPLAYING PROFILE: $($_.Exception.Message)" -ForegroundColor Red
    }
    Read-Host "`nPress Enter to return to menu..."
}
