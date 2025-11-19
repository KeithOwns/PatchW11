function Enable-PUAProtection {
    <#
    .SYNOPSIS
        Enables Potentially Unwanted App (PUA) Protection
    .DESCRIPTION
        Enables PUA blocking for both apps and downloads.
        Includes auto-repair for 0x800106ba (Service Unavailable) errors.
    #>
    param()

    try {
        Write-Host "`n  • Block potentially unwanted apps..." -ForegroundColor Cyan -NoNewline

        $GroupPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
        $GroupPolicyValue = "PUAProtection"
        $EdgePath = "HKCU:\SOFTWARE\Microsoft\Edge\SmartScreenPuaEnabled"

        # Basic Service Check
        $defenderService = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
        if ($null -eq $defenderService) {
            Write-Host " NOT AVAILABLE" -ForegroundColor DarkGray
            Write-Host "    ℹ️  Windows Defender service not found (third-party AV may be active)" -ForegroundColor Cyan
            return $false
        }

        # Step 1: Remove Group Policy management
        if (Test-Path $GroupPolicyPath) {
            $gpValue = Get-ItemProperty -Path $GroupPolicyPath -Name $GroupPolicyValue -ErrorAction SilentlyContinue
            if ($null -ne $gpValue) {
                try {
                    Remove-ItemProperty -Path $GroupPolicyPath -Name $GroupPolicyValue -Force -ErrorAction Stop
                } catch {
                    Write-Host " FAILED" -ForegroundColor Red
                    Write-Host "    ⚠️  Could not remove Group Policy lock (requires admin rights)" -ForegroundColor Yellow
                    return $false
                }
            }
        }

        # Step 2: Enable PUA Protection (With Auto-Repair)
        try {
            Set-MpPreference -PUAProtection Enabled -ErrorAction Stop
        } catch {
            # Check for 0x800106ba (The system service is unavailable)
            if ($_.Exception.Message -match "0x800106ba" -or $_.Exception.Message -match "system service is unavailable") {
                Write-Host " STALLED" -ForegroundColor Yellow
                Write-Host "    ⚠️  Service unresponsive (0x800106ba). Attempting auto-repair..." -ForegroundColor Yellow
                
                # Repair: Clear DisableAntiSpyware and force start service
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -ErrorAction SilentlyContinue
                Set-Service -Name WinDefend -StartupType Automatic -ErrorAction SilentlyContinue
                Start-Service -Name WinDefend -ErrorAction SilentlyContinue
                
                Start-Sleep -Seconds 3
                
                # Retry
                try {
                    Set-MpPreference -PUAProtection Enabled -ErrorAction Stop
                    Write-Host "    ✓ Repair successful. Retrying..." -ForegroundColor Green
                } catch {
                    Write-Host " FAILED" -ForegroundColor Red
                    Write-Host "    ⚠️  Repair failed. Third-party AV might be locking the service." -ForegroundColor Yellow
                    return $false
                }
            } else {
                Write-Host " FAILED" -ForegroundColor Red
                Write-Host "    ⚠️  Failed to enable PUA Protection: $($_.Exception.Message)" -ForegroundColor Yellow
                return $false
            }
        }

        Start-Sleep -Seconds 1

        # Step 3: Verify Windows Defender setting
        try {
            $mpPref = Get-MpPreference -ErrorAction Stop
            if ($mpPref.PUAProtection -ne 1) {
                Write-Host " FAILED" -ForegroundColor Red
                Write-Host "    ⚠️  PUA Protection value: $($mpPref.PUAProtection) (expected: 1)" -ForegroundColor Yellow
                return $false
            }
        } catch {
            Write-Host " FAILED" -ForegroundColor Red
            Write-Host "    ⚠️  Could not verify setting: $($_.Exception.Message)" -ForegroundColor Yellow
            return $false
        }

        # Step 4: Enable Edge PUA blocking (Optional)
        try {
            if (-not (Test-Path $EdgePath)) {
                New-Item -Path "HKCU:\SOFTWARE\Microsoft\Edge" -Name "SmartScreenPuaEnabled" -Force | Out-Null
            }
            Set-ItemProperty -Path $EdgePath -Name "(Default)" -Value 1 -Type DWord -Force
        } catch { }

        Write-Host " ENABLED" -ForegroundColor Green
        Write-Host "    ✓ Block apps: Enabled" -ForegroundColor Green
        Write-Host "    ✓ Block downloads: Enabled" -ForegroundColor Green
        return $true

    } catch {
        Write-Host " ERROR" -ForegroundColor Red
        Write-Host "    ⚠️  $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}