#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Restarts the Windows Explorer process.
.DESCRIPTION
    Standardized for WinAuto. Force closes and restarts explorer.exe to apply UI changes.
    Standalone version.
#>

& {
    # --- STANDALONE HELPERS ---
    $Esc = [char]0x1B; $Reset = "$Esc[0m"; $Bold = "$Esc[1m"; $FGGreen = "$Esc[92m"; $FGRed = "$Esc[91m"; $FGCyan = "$Esc[96m"; $FGDarkBlue = "$Esc[34m"
    $Char_HeavyCheck = "[v]"; $Char_RedCross = "[x]"
    
    if (-not (Get-Command Write-Boundary -ErrorAction SilentlyContinue)) { function Write-Boundary { param([string]$Color = $FGDarkBlue) Write-Host "$Color$([string]'_' * 60)$Reset" } }
    if (-not (Get-Command Write-Header -ErrorAction SilentlyContinue)) { function Write-Header { param([string]$Title) Clear-Host; Write-Host ""; Write-Host (" " * 25 + "$Bold$FGCyan- WinAuto -$Reset"); Write-Boundary; Write-Host (" " * [Math]::Floor((60 - $Title.Length) / 2) + "$Bold$FGCyan$($Title.ToUpper())$Reset"); Write-Boundary } }
    if (-not (Get-Command Write-LeftAligned -ErrorAction SilentlyContinue)) { function Write-LeftAligned { param($Text) Write-Host "  $Text" } }

    Write-Header "RESTART EXPLORER"

    try {
        Write-LeftAligned "Restarting Explorer..."
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        if (-not (Get-Process explorer -ErrorAction SilentlyContinue)) {
            Start-Process explorer
        }
        Write-LeftAligned "$FGGreen$Char_HeavyCheck Explorer restarted.$Reset"
    }
    catch { Write-LeftAligned "$FGRed$Char_RedCross Failed: $($_.Exception.Message)$Reset" }
} @args
