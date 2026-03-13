#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Disables the Widgets button on the Taskbar.
.DESCRIPTION
    Sets 'TaskbarDa' to 0 in HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced.
    Standalone version. Includes Reverse Mode (-r).
.PARAMETER Reverse
    (Alias: -r) Reverses the setting (Shows Widgets button).
#>

& {
    param(
        [Parameter(Mandatory = $false)]
        [Alias('r')]
        [switch]$Reverse
    )

    # --- STANDALONE HELPERS ---
    $Esc = [char]0x1B; $Reset = "$Esc[0m"; $Bold = "$Esc[1m"; $FGGreen = "$Esc[92m"; $FGRed = "$Esc[91m"; $FGCyan = "$Esc[96m"; $FGDarkBlue = "$Esc[34m"
    $Char_HeavyCheck = "[v]"; $Char_RedCross = "[x]"
    
    if (-not (Get-Command Write-Boundary -ErrorAction SilentlyContinue)) { function Write-Boundary { param([string]$Color = $FGDarkBlue) Write-Host "$Color$([string]'_' * 60)$Reset" } }
    if (-not (Get-Command Write-Header -ErrorAction SilentlyContinue)) { function Write-Header { param([string]$Title) Clear-Host; Write-Host ""; Write-Host (" " * 25 + "$Bold$FGCyan- WinAuto -$Reset"); Write-Boundary; Write-Host (" " * [Math]::Floor((60 - $Title.Length) / 2) + "$Bold$FGCyan$($Title.ToUpper())$Reset"); Write-Boundary } }
    if (-not (Get-Command Write-LeftAligned -ErrorAction SilentlyContinue)) { function Write-LeftAligned { param($Text) Write-Host "  $Text" } }

    Write-Header "WIDGETS TOGGLE"

    $Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $Name = "TaskbarDa"
    $Value = if ($Reverse) { 1 } else { 0 }
    $ActionStr = if ($Reverse) { "SHOWN" } else { "HIDDEN" }

    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type DWord -Force
        Write-LeftAligned "$FGGreen$Char_HeavyCheck Taskbar Widgets button is $ActionStr.$Reset"
        Write-LeftAligned "$FGCyan Restarting Explorer to apply...$Reset"
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        Start-Process explorer
    }
    catch { Write-LeftAligned "$FGRed$Char_RedCross Failed: $($_.Exception.Message)$Reset" }
} @args
