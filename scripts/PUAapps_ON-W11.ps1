#Requires -RunAsAdministrator

# Enable Potentially Unwanted App (PUA) blocking
try {
    Set-MpPreference -PUAProtection Enabled
    Write-Host "✓ PUA blocking enabled successfully" -ForegroundColor Green
    
    # Verify the setting
    $status = (Get-MpPreference).PUAProtection
    Write-Host "Current PUA Protection status: $status" -ForegroundColor Cyan
}
catch {
    Write-Host "✗ Failed to enable PUA blocking: $_" -ForegroundColor Red
    exit 1
}
