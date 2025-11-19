<#
.SYNOPSIS
    Enables the Windows Firewall for any network profile where it is currently disabled.
.DESCRIPTION
    Scans Domain, Private, and Public profiles. If a profile is off, it turns it on.
    Requires Run as Administrator.
#>

# Get all firewall profiles that are currently disabled
$disabledProfiles = Get-NetFirewallProfile | Where-Object { $_.Enabled -eq $False }

if ($disabledProfiles) {
    foreach ($profile in $disabledProfiles) {
        Write-Host "Enabling firewall for $($profile.Name) profile..." -NoNewline
        
        try {
            Set-NetFirewallProfile -Name $profile.Name -Enabled True -ErrorAction Stop
            Write-Host " [OK]" -ForegroundColor Green
        }
        catch {
            Write-Host " [FAILED]" -ForegroundColor Red
            Write-Error $_
        }
    }
}
else {
    Write-Host -ForegroundColor Green "All firewall profiles are already active."
}