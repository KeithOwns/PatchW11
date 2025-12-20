#Requires -RunAsAdministrator
<#
.SYNOPSIS
    PatchW11 Master Control Suite (AUTOMATED)
.DESCRIPTION
    Runs the full PatchW11 suite (Update, Security, Maintenance) sequentially
    without user interaction.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- STYLE & FORMATTING CONFIGURATION ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Char_HeavyLine = [char]0x2501
$Char_HeavyMinus = [char]0x2796
$Esc = [char]0x1B
$Reset = "$Esc[0m"
$Bold = "$Esc[1m"
$FGCyan = "$Esc[96m"
$FGWhite = "$Esc[97m"
$FGYellow = "$Esc[93m"
$FGGreen = "$Esc[92m"
$FGDarkBlue = "$Esc[34m"

function Write-Centered { param($Text, $Width = 60) $clean = $Text -replace "$Esc\[[0-9;]*m", ""; $pad = [Math]::Floor(($Width - $clean.Length) / 2); if ($pad -lt 0) { $pad = 0 }; Write-Host (" " * $pad + $Text) }
function Write-LeftAligned { param($Text, $Indent = 2) Write-Host (" " * $Indent + $Text) }
function Write-Header { param($Title) Write-Host ""; Write-Centered "$Bold$FGCyan $Char_HeavyLine PatchW11 $Char_HeavyLine $Reset"; Write-Centered "$Bold$FGCyan$Title$Reset"; Write-Host "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset" }

# --- MAIN EXECUTION ---
Clear-Host
Write-Header "MASTER SUITE (AUTO)"

Write-Host ""
Write-LeftAligned "$FGYellow Starting Automated Sequence...$Reset"
Start-Sleep -Seconds 2

# 1. Update
Write-Host ""
Write-LeftAligned "$FGWhite$Char_HeavyMinus Module 1/3: Windows Update$Reset"
& "$PSScriptRoot\WindowsUpdate_SETnSCAN.ps1" -AutoRun

# 2. Security
Write-Host ""
Write-LeftAligned "$FGWhite$Char_HeavyMinus Module 2/3: Windows Security$Reset"
& "$PSScriptRoot\WindowsSecurity_CHECKnSETnSCAN.ps1" -AutoRun

# 3. Maintenance
Write-Host ""
Write-LeftAligned "$FGWhite$Char_HeavyMinus Module 3/3: Maintenance$Reset"
& "$PSScriptRoot\WindowsMaintenance_SETnSCAN.ps1" -AutoRun

Write-Host ""
Write-Host "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"
Write-Centered "$FGGreen SEQUENCE COMPLETE $Reset"
Write-Host "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"
Start-Sleep -Seconds 3
