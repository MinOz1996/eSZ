function Invoke-AegisCleaner {
    Write-AegisLog -Level "INFO" -Message "Executing Ultimate Deep Trace Cleaner..."

    # 1. SetupAPI Logs
    $logs = @("C:\Windows\inf\setupapi.dev.log", "C:\Windows\inf\setupapi.setup.log")
    foreach ($log in $logs) {
        if (Test-Path $log) { 
            try { Set-Content -Path $log -Value "" -Force; Write-AegisLog -Level "DEBUG" -Message "Cleared SetupAPI Log: $log" } catch {} 
        }
    }

    # 2. Prefetch & Temp
    $tempPaths = @("C:\Windows\Prefetch\*.pf", "$env:TEMP\*", "C:\Windows\Temp\*")
    foreach ($path in $tempPaths) {
        try { Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue } catch {}
    }
    Write-AegisLog -Level "DEBUG" -Message "Cleared Prefetch and Temporary Files"

    # 3. Recent Files & Jump Lists
    $recentPath = "$env:APPDATA\Microsoft\Windows\Recent\*"
    try { Get-ChildItem $recentPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue } catch {}
    Write-AegisLog -Level "DEBUG" -Message "Cleared Recent Files and Jump Lists"

    # 4. Event Logs
    $eventLogs = @("System", "Security", "Application", "Setup", "Windows PowerShell")
    foreach ($logName in $eventLogs) {
        try { Clear-EventLog -LogName $logName -ErrorAction SilentlyContinue } catch {}
    }
    Write-AegisLog -Level "DEBUG" -Message "Cleared Event Logs"

    # 5. MUICache & ShimCache
    try {
        $muiPath = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
        if (Test-Path $muiPath) {
            $key = Get-Item $muiPath
            foreach ($valName in $key.GetValueNames()) {
                if ($valName -ne "(Default)") { Remove-ItemProperty $muiPath -Name $valName -Force -ErrorAction SilentlyContinue }
            }
        }
        Remove-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache" -Name "AppCompatCache" -Force -ErrorAction SilentlyContinue
    } catch {}
    Write-AegisLog -Level "DEBUG" -Message "Cleared Registry Artifacts (MUICache/ShimCache)"

    Write-AegisLog -Level "INFO" -Message "Deep Cleaning Completed."
}
