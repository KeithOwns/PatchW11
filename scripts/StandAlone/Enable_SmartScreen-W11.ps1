# Requires -RunAsAdministrator

# Check if the script is running with Administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "This script requires Administrator privileges. Please right-click and select 'Run as Administrator'."
    exit
}

# 1. Clear the PowerShell window before output (User Preference)
Clear-Host

try {
    # Define the Registry Path and Value for Windows Defender SmartScreen
    # "Warn" sets the setting to "On" (Warn before running unrecognized apps)
    # "Block" would set it to strict blocking
    # "Off" would turn it off
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    $regName = "SmartScreenEnabled"
    $regValue = "Warn"

    # Check if the path exists, create if not (unlikely for this specific path, but good practice)
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Set the registry key
    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue -ErrorAction Stop

    Write-Host "Successfully enabled Windows Security > App & browser control > Check apps and files." -ForegroundColor Green
    Write-Host "Current Value for '$regName': $regValue" -ForegroundColor Gray
}
catch {
    Write-Error "An error occurred while attempting to modify the registry."
    Write-Error $_.Exception.Message
}

# 2. Print 5 empty lines at the bottom before exiting (User Preference)
Write-Host "`n`n`n`n`n" -NoNewline