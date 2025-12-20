# Check Windows Update status
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

Write-Host "Checking Windows Update status..." -ForegroundColor Cyan

try {
    # Search for updates
    $SearchResult = $UpdateSearcher.Search("IsInstalled=0")
    
    $PendingUpdates = $SearchResult.Updates.Count
    
    if ($PendingUpdates -eq 0) {
        Write-Host "`nStatus: You're up to date" -ForegroundColor Green
        Write-Host "No pending updates available." -ForegroundColor Green
    }
    else {
        Write-Host "`nStatus: Updates available" -ForegroundColor Yellow
        Write-Host "Pending updates: $PendingUpdates" -ForegroundColor Yellow
        
        Write-Host "`nAvailable updates:" -ForegroundColor White
        foreach ($Update in $SearchResult.Updates) {
            Write-Host "  - $($Update.Title)" -ForegroundColor White
        }
    }
    
    # Check last update check time
    $UpdateServiceManager = New-Object -ComObject Microsoft.Update.ServiceManager
    Write-Host "`nLast checked: $($UpdateSearcher.GetTotalHistoryCount()) updates in history" -ForegroundColor Gray
}
catch {
    Write-Host "`nError checking Windows Update status: $($_.Exception.Message)" -ForegroundColor Red
}