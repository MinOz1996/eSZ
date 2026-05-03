function Show-AegisBanner {
    Clear-Host
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host "     AEGIS SHROUD PROFESSIONAL FRAMEWORK  " -ForegroundColor Green
    Write-Host "     Version 2.0.0 | Production Ready     " -ForegroundColor Green
    Write-Host "  ========================================" -ForegroundColor Green
}

function Show-AegisMenu {
    Show-AegisBanner
    Write-Host "`n  [1] Run Full Protection Pipeline" -ForegroundColor Cyan
    Write-Host "  [2] View System State Snapshots" -ForegroundColor Cyan
    Write-Host "  [3] Rollback to Previous State" -ForegroundColor Cyan
    Write-Host "  [4] View Logs" -ForegroundColor Cyan
    Write-Host "  [5] Exit" -ForegroundColor Cyan
    
    return Read-Host "`nSelect an option"
}
