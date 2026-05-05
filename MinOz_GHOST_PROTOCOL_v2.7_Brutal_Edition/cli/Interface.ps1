# MinOz GHOST PROTOCOL (2026) - Interface Module v2.7

function Show-AegisMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)] [bool]$IsSpoofed = $false,
        [Parameter(Mandatory = $false)] [string]$LastSpoofType = "None"
    )

    Clear-Host
    $dt   = Get-Date -Format "dd/MM/yyyy"
    $time = Get-Date -Format "HH:mm:ss"
    $W    = 62   # inner width

    # Box helpers: เส้น ─ │ ┌ ┐ └ ┘ ├ ┤
    function BLine {
        param([string]$T = "", [ConsoleColor]$C = "White")
        $l = [Math]::Max(0, [int](($W - $T.Length) / 2))
        $r = $W - $l - $T.Length
        Write-Host "  " -NoNewline
        Write-Host "│" -NoNewline -ForegroundColor DarkMagenta
        Write-Host (" "*$l + $T + " "*$r) -NoNewline -ForegroundColor $C
        Write-Host "│" -ForegroundColor DarkMagenta
    }
    function BTop { Write-Host "  " -NoNewline; Write-Host ("┌" + ("─"*$W) + "┐") -ForegroundColor DarkMagenta }
    function BSep { Write-Host "  " -NoNewline; Write-Host ("├" + ("─"*$W) + "┤") -ForegroundColor DarkMagenta }
    function BBot { Write-Host "  " -NoNewline; Write-Host ("└" + ("─"*$W) + "┘") -ForegroundColor DarkMagenta }

    Write-Host ""

    # MINOZ Logo block font — centered above box
    # Logo = 46 chars wide, box outer = 66, center offset = (66-46)/2 ≈ 10
    $pad = " " * 10
    Write-Host ($pad + "███╗   ███╗  ██╗  ███╗  ██╗   ██████╗  ███████╗") -ForegroundColor Green
    Write-Host ($pad + "████╗ ████║  ██║  ████╗ ██║  ██╔═══██╗    ███╔╝") -ForegroundColor Green
    Write-Host ($pad + "██╔████╔██║  ██║  ██╔██╗██║  ██║   ██║   ███╔╝ ") -ForegroundColor Green
    Write-Host ($pad + "██║╚██╔╝██║  ██║  ██║╚████║  ██║   ██║  ███╔╝  ") -ForegroundColor Green
    Write-Host ($pad + "██║ ╚═╝ ██║  ██║  ██║ ╚███║  ╚██████╔╝  ███████╗") -ForegroundColor Green
    Write-Host ($pad + "╚═╝     ╚═╝  ╚═╝  ╚═╝  ╚══╝   ╚═════╝   ╚══════╝") -ForegroundColor Green
    Write-Host ""

    # ┌─────────────────────────────────────────────────────────────────┐
    # │              MAIN INFO BOX                                      │
    # └─────────────────────────────────────────────────────────────────┘
    BTop
    BLine ""
    BLine "AEGIS SHROUD  --  GHOST PROTOCOL EDITION 2026" "Magenta"
    BLine "DEVELOPED BY: MinOz  |  v2.7.0" "DarkGray"
    BSep
    BLine ""
    BLine "Effectiveness: 100%  .  Anti-Cheat Proof" "Yellow"
    BLine "$dt     $time" "DarkGray"
    BLine ""
    BSep
    BLine ""

    # Status line
    if ($IsSpoofed) {
        $modeLabel = switch ($LastSpoofType.ToUpper()) {
            "FULL"     { "Ghost Full" }
            "STANDARD" { "Standard"  }
            default    { $LastSpoofType }
        }
        $st = "*  Active Spoofing :  $modeLabel"
        $l = [Math]::Max(0, [int](($W - $st.Length) / 2))
        $r = $W - $l - $st.Length
        Write-Host "  " -NoNewline
        Write-Host "│" -NoNewline -ForegroundColor DarkMagenta
        Write-Host (" "*$l + $st + " "*$r) -NoNewline -ForegroundColor Green
        Write-Host "│" -ForegroundColor DarkMagenta
    } else {
        BLine "o  ORIGINAL IDENTITY  (No Active Spoofing)" "Red"
    }

    BLine ""
    BBot

    Write-Host ""

    # Menu
    $lock = $IsSpoofed
    $items = @(
        @{ n="1"; label="GHOST PROTOCOL FULL  "; desc="100% - All Modules Active";           nc="Cyan";    locked=$lock }
        @{ n="2"; label="STANDARD PROTECTION  "; desc="70%  - Registry Only";               nc="Green";   locked=$lock }
        @{ n="3"; label="RESTORE IDENTITY     "; desc="Remove All Mods & Restore Original"; nc="Magenta"; locked=$false }
        @{ n="4"; label="VIEW CURRENT PROFILE "; desc="Detailed Identity Report";            nc="Yellow";  locked=$false }
        @{ n="5"; label="DEEP CLEAN TRACES    "; desc="Obliterate All Traces";              nc="Red";     locked=$false }
        @{ n="6"; label="EXIT                 "; desc="Quit";                               nc="Gray";    locked=$false }
    )

    foreach ($item in $items) {
        if ($item.locked) {
            Write-Host "  [" -NoNewline -ForegroundColor DarkGray
            Write-Host $item.n -NoNewline -ForegroundColor DarkGray
            Write-Host "]  " -NoNewline -ForegroundColor DarkGray
            Write-Host $item.label -NoNewline -ForegroundColor DarkGray
            Write-Host " LOCKED - Run [3] Restore first" -ForegroundColor DarkGray
        } else {
            Write-Host "  [" -NoNewline -ForegroundColor DarkMagenta
            Write-Host $item.n -NoNewline -ForegroundColor $item.nc
            Write-Host "]  " -NoNewline -ForegroundColor DarkMagenta
            Write-Host $item.label -NoNewline -ForegroundColor Yellow
            Write-Host " $($item.desc)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    Write-Host ("  " + ("─"*66)) -ForegroundColor DarkMagenta
    Write-Host ""
    Write-Host "  Select option " -NoNewline -ForegroundColor DarkGray
    Write-Host "[1-6]" -NoNewline -ForegroundColor Magenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    return Read-Host
}

function View-DetailedProfile {
    [CmdletBinding()]
    param()

    Write-AegisLog -Level "INFO" -Message "[MinOz] Displaying profile..."

    $PreState     = $null
    $PostState    = $null
    $CurrentState = @{}

    try { $PreState     = Get-SystemSnapshot -Type "Pre"  } catch {}
    try { $PostState    = Get-SystemSnapshot -Type "Post" } catch {}
    try { $CurrentState = Get-CurrentSystemIdentity       } catch {}

    Clear-Host
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host ("┌" + ("─"*70) + "┐") -ForegroundColor DarkMagenta
    Write-Host "  " -NoNewline
    Write-Host "│  AEGIS SHROUD  --  IDENTITY REPORT" -NoNewline -ForegroundColor DarkMagenta
    Write-Host (" " * 35 + "│") -ForegroundColor DarkMagenta
    $ts = Get-Date -Format "HH:mm:ss    dd/MM/yyyy"
    Write-Host "  " -NoNewline
    Write-Host "│  $ts" -NoNewline -ForegroundColor DarkMagenta
    Write-Host (" " * 48 + "│") -ForegroundColor DarkMagenta
    Write-Host "  " -NoNewline
    Write-Host ("└" + ("─"*70) + "┘") -ForegroundColor DarkMagenta
    Write-Host ""

    $sections = [ordered]@{
        "SYSTEM IDENTIFIERS" = @(
            @{Name="Computer Name"; Key="ComputerName"}
            @{Name="Machine GUID";  Key="MachineGuid"}
            @{Name="Product ID";    Key="ProductId"}
        )
        "HARDWARE PROFILE" = @(
            @{Name="Manufacturer";  Key="Manufacturer"}
            @{Name="Product Name";  Key="Product"}
        )
        "CPU & GPU" = @(
            @{Name="Processor";     Key="CPU"}
            @{Name="Graphics Card"; Key="GPU"}
        )
        "FIRMWARE / BIOS" = @(
            @{Name="BIOS Vendor";   Key="BiosVendor"}
            @{Name="Serial Number"; Key="Serial"}
        )
        "NETWORK & STORAGE" = @(
            @{Name="MAC Address";   Key="MacAddress"}
            @{Name="Disk Model";    Key="DiskModel"}
        )
    }

    foreach ($sectionName in $sections.Keys) {
        Write-Host "  " -NoNewline
        Write-Host "├─ " -NoNewline -ForegroundColor DarkMagenta
        Write-Host $sectionName -ForegroundColor Magenta

        foreach ($item in $sections[$sectionName]) {
            $key        = $item.Key
            $valCurrent = if ($CurrentState -and $CurrentState.ContainsKey($key)) { "$($CurrentState[$key])" } else { "N/A" }
            $valPre     = if ($PreState -and $PreState.ContainsKey($key))         { "$($PreState[$key])" }     else { $valCurrent }
            $valPost    = if ($PostState -and $PostState.ContainsKey($key))       { "$($PostState[$key])" }    else { $valCurrent }

            # Status and colors
            if ($null -eq $PreState -and $null -eq $PostState) {
                $status="ORIGINAL"; $preC="Cyan";    $postC="Cyan";    $stC="Cyan"
            } elseif ($valPre -ne $valPost) {
                # If Post value matches Current value, it's a success
                if ($valPost.Trim() -eq $valCurrent.Trim()) {
                    $status="SUCCESS";  $preC="Cyan";    $postC="Green";   $stC="Green"
                } else {
                    # If they don't match, it might need a reboot or failed to apply
                    $status="PENDING";  $preC="Cyan";    $postC="Yellow";  $stC="Yellow"
                }
            } else {
                # If Pre and Post are same, but Current is different, it's also a success (manual change or previous run)
                if ($valPre.Trim() -ne $valCurrent.Trim()) {
                    $status="SUCCESS";  $preC="Cyan";    $postC="Green";   $stC="Green"
                    $valPost = $valCurrent
                } else {
                    $status="UNCHANGED"; $preC="DarkGray"; $postC="DarkGray"; $stC="DarkGray"
                }
            }

            $trim = { param($v) if ($v.Length -gt 28) { $v.Substring(0,25)+"..." } else { $v } }

            Write-Host "  " -NoNewline
            Write-Host "│  " -NoNewline -ForegroundColor DarkMagenta
            Write-Host ("{0,-16}" -f $item.Name) -NoNewline -ForegroundColor White
            Write-Host "  " -NoNewline
            Write-Host ("{0,-28}" -f (& $trim $valPre)) -NoNewline -ForegroundColor $preC
            Write-Host "  ->  " -NoNewline -ForegroundColor DarkGray
            Write-Host ("{0,-28}" -f (& $trim $valPost)) -NoNewline -ForegroundColor $postC
            Write-Host "  [$status]" -ForegroundColor $stC
        }
        Write-Host ""
    }

    Write-Host "  " -NoNewline
    Write-Host ("└" + ("─"*85)) -ForegroundColor DarkMagenta
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host "ORIG" -NoNewline -ForegroundColor Cyan
    Write-Host " = Original (Blue)    " -NoNewline -ForegroundColor DarkGray
    Write-Host "VIRTUAL" -NoNewline -ForegroundColor Green
    Write-Host " = Spoofed (Green)    " -NoNewline -ForegroundColor DarkGray
    Write-Host "UNCHANGED" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "                   MinOz GHOST PROTOCOL 2026" -ForegroundColor DarkMagenta
    Write-Host ""

    Read-Host "  Press Enter to return to menu"
}
