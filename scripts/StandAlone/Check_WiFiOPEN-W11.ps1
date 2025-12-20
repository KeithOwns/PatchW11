<#
.SYNOPSIS
    Checks the currently active Wi-Fi network to see if it is unsecured (open).
.DESCRIPTION
    Uses the 'netsh wlan show interfaces' command to find the authentication 
    method of the active Wi-Fi connection and checks if it is 'Open' or 'None'.
#>
function Check-OpenWifiStatus {
    try {
        # Get the raw WLAN interface details and filter for the 'Authentication' line
        $NetshOutput = netsh wlan show interfaces | Select-String -Pattern "Authentication"
        
        if ($NetshOutput) {
            # Extract and trim the authentication method value
            $AuthMethod = $NetshOutput -split ':' | Select -Last 1 | ForEach-Object { $_.Trim() }

            # Check for common unsecured values (Open, None)
            if ($AuthMethod -match "Open|None|Unsecured" -and $AuthMethod -notmatch "WPA2-Open") {
                # Output high-visibility warning for unsecured network
                Write-Host " ❌ WARNING: Unsecured Network Detected!" -ForegroundColor Black -BackgroundColor Red
                Write-Host "    Authentication: $AuthMethod" -ForegroundColor Red
                return $true
            } else {
                # Output success message for secured network
                Write-Host " ✅ Network is Secured." -ForegroundColor Green
                Write-Host "    Authentication: $AuthMethod" -ForegroundColor DarkGray
                return $false
            }
        } else {
            Write-Host " ❗ No active Wi-Fi connection found." -ForegroundColor DarkYellow
            return $false
        }
    } catch {
        Write-Host " ❌ Error checking network status: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Execute the function and capture the boolean result (optional)
$IsUnsecured = Check-OpenWifiStatus