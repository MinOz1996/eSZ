function Get-AegisConfig {
    $ConfigPath = Join-Path $PSScriptRoot "..\config\settings.json"
    if (Test-Path $ConfigPath) {
        return Get-Content $ConfigPath | ConvertFrom-Json
    } else {
        # Default Configuration
        $DefaultConfig = @{
            Version = "2.0.0"
            Environment = "Production"
            BackupDir = "Backups"
            Persistence = @{
                Enabled = $true
                TaskName = "AegisShroudUltimate"
            }
            Modules = @{
                Identity = @{ Enabled = $true }
                Cleaner = @{ Enabled = $true }
                Privacy = @{ Enabled = $true }
            }
        }
        $DefaultConfig | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath
        return $DefaultConfig
    }
}

function Save-AegisConfig {
    param($Config)
    $ConfigPath = Join-Path $PSScriptRoot "..\config\settings.json"
    $Config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath
}
