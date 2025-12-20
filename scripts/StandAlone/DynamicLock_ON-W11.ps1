<#
.SYNOPSIS
    Enables the Dynamic Lock feature in Windows 10/11.
.DESCRIPTION
    Sets the 'EnableGoodbye' registry key in the current user's Winlogon path.
    Requires a paired Bluetooth device to function effectively.
#>

$regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
$regName = "EnableGoodbye"

try {
    # Check if path exists, create if not (unlikely for Winlogon, but safe)
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Set EnableGoodbye to 1 (Enabled)
    Set-ItemProperty -Path $regPath -Name $regName -Value 1 -Type DWord -Force -ErrorAction Stop

    Write-Host -ForegroundColor Green "Success: Dynamic Lock has been enabled."
    Write-Host -ForegroundColor Yellow "Reminder: Ensure your smartphone is paired via Bluetooth."
}
catch {
    Write-Error "Failed to enable Dynamic Lock: $_"
}