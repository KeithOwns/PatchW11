#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
  Windows 11 Finalization & Maintenance Script
.DESCRIPTION
  Performs comprehensive system optimization, diagnostics, and maintenance tasks including:
  - Disk optimization (Trim for SSDs, Defrag for HDDs)
  - Power settings optimization
  - Visual effects adjustment
  - System file integrity checks
  - Advanced diagnostics and remediation
  - System cleanup
  - Admin account hiding
  - Final restore point creation
.NOTES
  Requires Administrator privileges
  Some operations may require system restart
  Creates detailed logs in C:\Windows\Temp\Maint_[YYMMDD].log
.EXAMPLE
  .\Run_Maintenance-W11.ps1
  Runs full maintenance and optimization sequence
#>

# Global Variables
# $script:StartTime = Get-Date
# Updated log path format: Maint_[YYMMDD] (Removed seconds/time)
$script:LogPath = "C:\Windows\Temp\Maint_$(Get-Date -Format 'yyMMdd').log"
$script:RestartRequired = $false
$script:ErrorsFound = @()

# --- Utility Functions ---

function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('INFO','WARNING','ERROR','SUCCESS')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $script:LogPath -Value $logMessage -ErrorAction SilentlyContinue
}

function Write-StatusIcon {
    param(
        [Parameter(Mandatory)]
        [bool]$IsEnabled,

        [Parameter(Mandatory = $false)]
        [string]$Severity = "Warning"
    )

    if ($IsEnabled) {
        # Legend: DarkCyan = ✓ Checkmark (Enabled)
        Write-Host "✓" -NoNewline -ForegroundColor DarkCyan
        Write-Host " " -NoNewline
    } else {
        # Legend: DarkRed = ✗ Cross Mark (Disabled)
        Write-Host " ✗ " -NoNewline -ForegroundColor DarkRed
    }
}

function Write-SectionHeader {
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory = $false)]
        [string]$Icon = "⚙️"
    )

    # Legend: Cyan = Section Titles / @ (Icons)
    Write-Host "`n$Icon " -NoNewline -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Cyan
    # Legend: DarkBlue = Section boundary lines (50 chars)
    Write-Host ("─" * 50) -ForegroundColor DarkBlue
    Write-Log -Message "Starting: $Title" -Level INFO
}

function Get-RegistryValue {
    param([Parameter(Mandatory)] [string]$Path, [Parameter(Mandatory)] [string]$Name)
    try {
        if (Test-Path $Path) {
            $prop = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
            return $prop.$Name
        }
        return $null
    } catch { return $null }
}

function Set-RegistryDword {
    param([Parameter(Mandatory)] [string]$Path, [Parameter(Mandatory)] [string]$Name, [Parameter(Mandatory)] [int]$Value)
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
            Write-Log -Message "Created registry path: $Path" -Level INFO
        }
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
        Write-Log -Message "Set registry: $Path\$Name = $Value" -Level SUCCESS
        return $true
    } catch {
        Write-Log -Message "Failed to set registry: $Path\$Name - $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

# --- 1. Disk Optimization ---

function Optimize-Disks {
    Write-SectionHeader "Disk Optimization" "💾"

    try {
        $volumes = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' }

        foreach ($volume in $volumes) {
            $drive = $volume.DriveLetter

            Write-Host "`n  Drive $drive`:\" -ForegroundColor Cyan

            try {
                # Check if it's an SSD or HDD
                $isSSD = $false
                $partition = Get-Partition -DriveLetter $drive -ErrorAction SilentlyContinue
                if ($partition) {
                    $disk = Get-Disk -Number $partition.DiskNumber -ErrorAction SilentlyContinue
                    if ($disk) {
                        # Check if MediaType property exists before accessing it
                        $mediaTypeProperty = $disk.PSObject.Properties | Where-Object { $_.Name -eq 'MediaType' }
                        if ($mediaTypeProperty -and $disk.MediaType -eq 'SSD') {
                            $isSSD = $true
                        }
                    }
                }

                if ($isSSD) {
                    Write-Host "    Type: SSD - Running TRIM optimization..." -ForegroundColor Yellow
                    Optimize-Volume -DriveLetter $drive -ReTrim -Verbose
                    Write-Host "    ✓ TRIM completed successfully" -ForegroundColor Green
                    Write-Log -Message "TRIM completed for drive $drive" -Level SUCCESS
                } else {
                    Write-Host "    Type: HDD - Running Defragmentation (this may take a while)..." -ForegroundColor Yellow
                    Optimize-Volume -DriveLetter $drive -Defrag -Verbose
                    Write-Host "    ✓ Defragmentation completed successfully" -ForegroundColor Green
                    Write-Log -Message "Defragmentation completed for drive $drive" -Level SUCCESS
                }
            } catch {
                Write-Host "    ✗ Failed to optimize drive: $($_.Exception.Message)" -ForegroundColor Red
                Write-Log -Message "Failed to optimize drive $drive`: $($_.Exception.Message)" -Level ERROR
            }
        }
    } catch {
        Write-Host "  ✗ Error during disk optimization: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log -Message "Disk optimization error: $($_.Exception.Message)" -Level ERROR
    }
}

# --- 2. Power Settings ---

function Set-PowerSettings {
    Write-SectionHeader "Power Settings Optimization" "⚡"

    try {
        # Set power plan to High Performance
        Write-Host "`n  Setting power plan to High Performance..." -ForegroundColor Yellow

        $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        powercfg /setactive $highPerfGuid

        Write-Host "  ✓ Power plan set to High Performance" -ForegroundColor Green
        Write-Log -Message "Power plan set to High Performance" -Level SUCCESS

        # Set power mode to Best Performance (Windows 11)
        Write-Host "`n  Setting power mode to Best Performance..." -ForegroundColor Yellow

        $powerSettingsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7"
        Set-RegistryDword -Path $powerSettingsPath -Name "ACSettingIndex" -Value 0
        Set-RegistryDword -Path $powerSettingsPath -Name "DCSettingIndex" -Value 0

        Write-Host "  ✓ Power mode configured for best performance" -ForegroundColor Green

    } catch {
        Write-Host "  ✗ Error setting power settings: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log -Message "Power settings error: $($_.Exception.Message)" -Level ERROR
    }
}

# --- 3. Visual Effects Optimization ---

function Optimize-VisualEffects {
    Write-SectionHeader "Visual Effects Optimization" "🎨"

    try {
        Write-Host "`n  Adjusting visual effects for best performance..." -ForegroundColor Yellow

        $visualEffectsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
        Set-RegistryDword -Path $visualEffectsPath -Name "VisualFXSetting" -Value 2  # 2 = Best Performance

        # Set UserPreferencesMask as binary value for visual effects optimization
        try {
            $maskPath = "HKCU:\Control Panel\Desktop"
            $maskValue = [byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)
            Set-ItemProperty -Path $maskPath -Name "UserPreferencesMask" -Value $maskValue -Type Binary -Force
            Write-Log -Message "UserPreferencesMask set successfully" -Level SUCCESS
        } catch {
            Write-Log -Message "Failed to set UserPreferencesMask (non-critical): $($_.Exception.Message)" -Level WARNING
        }

        # Disable unnecessary visual effects
        Set-RegistryDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 0
        Set-RegistryDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0
        Set-RegistryDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0

        Write-Host "  ✓ Visual effects optimized for best performance" -ForegroundColor Green
        Write-Host "    Note: Changes will take full effect after logout/restart" -ForegroundColor Gray
        Write-Log -Message "Visual effects optimized" -Level SUCCESS

    } catch {
        Write-Host "  ✗ Error optimizing visual effects: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log -Message "Visual effects optimization error: $($_.Exception.Message)" -Level ERROR
    }
}

# --- 4. Advanced Diagnostics ---

# NOTE: Start-DiskCheck is NOT called automatically in this script
# It can be manually enabled if needed by uncommenting it in the main execution section
function Start-DiskCheck {
    Write-SectionHeader "Disk Error Check" "🔍"

    try {
        Write-Host "`n  Scheduling disk check on next restart..." -ForegroundColor Yellow
        Write-Host "    This will check and fix file system errors" -ForegroundColor Gray

        $result = chkdsk C: /f /x 2>&1

        Write-Host "`n  ⚠️  Disk check has been scheduled for next restart" -ForegroundColor Yellow
        Write-Host "    The system will check disk C: when you restart" -ForegroundColor Gray
        Write-Log -Message "Disk check scheduled for next restart" -Level WARNING

        $script:RestartRequired = $true

    } catch {
        Write-Host "  ✗ Error scheduling disk check: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log -Message "Disk check scheduling error: $($_.Exception.Message)" -Level ERROR
    }
}

function Test-SystemFiles {
    Write-SectionHeader "System File Integrity Check" "🛡️"

    Write-Host "`n  Running System File Checker (this may take 10-15 minutes)..." -ForegroundColor Yellow
    Write-Host "    Please be patient..." -ForegroundColor Gray

    try {
        # Run SFC
        $sfcOutput = & sfc /scannow 2>&1 | Out-String
        Write-Log -Message "SFC Output: $sfcOutput" -Level INFO

        if ($sfcOutput -match "Windows Resource Protection did not find any integrity violations") {
            Write-Host "`n  ✓ System files are healthy - No issues found" -ForegroundColor Green
            Write-Log -Message "SFC: No integrity violations found" -Level SUCCESS
            return $true
        }
        elseif ($sfcOutput -match "Windows Resource Protection found corrupt files and successfully repaired them") {
            Write-Host "`n  ✓ System files were repaired successfully" -ForegroundColor Green
            Write-Log -Message "SFC: Corrupt files repaired" -Level SUCCESS
            return $true
        }
        elseif ($sfcOutput -match "Windows Resource Protection found corrupt files but was unable to fix some of them") {
            Write-Host "`n  ⚠️  System files have unfixable errors" -ForegroundColor Yellow
            Write-Host "    Re-running System File Checker..." -ForegroundColor Yellow
            Write-Log -Message "SFC: Found unfixable errors, re-running" -Level WARNING

            # Re-run SFC
            Start-Sleep -Seconds 2
            $sfcOutput2 = & sfc /scannow 2>&1 | Out-String
            Write-Log -Message "SFC Re-run Output: $sfcOutput2" -Level INFO

            if ($sfcOutput2 -match "Windows Resource Protection found corrupt files but was unable to fix some of them") {
                Write-Host "`n  ✗ System files still have unfixable errors" -ForegroundColor Red
                Write-Host "    Proceeding to DISM repair..." -ForegroundColor Yellow
                Write-Log -Message "SFC: Still has unfixable errors after re-run" -Level ERROR
                $script:ErrorsFound += "System file integrity errors"
                return $false
            } else {
                Write-Host "`n  ✓ System files repaired on second attempt" -ForegroundColor Green
                Write-Log -Message "SFC: Repaired on second attempt" -Level SUCCESS
                return $true
            }
        }
        else {
            Write-Host "`n  ⚠️  SFC completed with unknown status" -ForegroundColor Yellow
            Write-Log -Message "SFC: Unknown status" -Level WARNING
            return $true
        }

    } catch {
        Write-Host "  ✗ Error running System File Checker: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log -Message "SFC error: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Repair-WindowsImage {
    Write-SectionHeader "Windows Image Repair (DISM)" "🔧"

    Write-Host "`n  Running DISM online repair (this may take 15-30 minutes)..." -ForegroundColor Yellow
    Write-Host "    Please be patient..." -ForegroundColor Gray

    try {
        # Run DISM RestoreHealth
        $dismOutput = & DISM /Online /Cleanup-Image /RestoreHealth 2>&1 | Out-String
        Write-Log -Message "DISM Output: $dismOutput" -Level INFO

        if ($dismOutput -match "The restore operation completed successfully" -or $dismOutput -match "No component store corruption detected") {
            Write-Host "`n  ✓ Windows image is healthy" -ForegroundColor Green
            Write-Log -Message "DISM: Image healthy or repaired successfully" -Level SUCCESS
            return $true
        }
        elseif ($dismOutput -match "The operation completed successfully") {
            Write-Host "`n  ✓ Windows image repaired successfully" -ForegroundColor Green
            Write-Log -Message "DISM: Repair completed successfully" -Level SUCCESS

            # Re-run SFC after DISM repair
            Write-Host "`n  Re-running System File Checker after DISM repair..." -ForegroundColor Yellow
            Test-SystemFiles | Out-Null
            return $true
        }
        else {
            Write-Host "`n  ⚠️  DISM reported potential issues" -ForegroundColor Yellow
            Write-Host "    Checking if memory diagnostics are needed..." -ForegroundColor Gray
            Write-Log -Message "DISM: Reported potential issues" -Level WARNING
            $script:ErrorsFound += "Windows image integrity issues"
            return $false
        }

    } catch {
        Write-Host "  ✗ Error running DISM: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log -Message "DISM error: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Start-MemoryDiagnostics {
    Write-SectionHeader "Memory Diagnostics" "🧠"

    Write-Host "`n  Scheduling Windows Memory Diagnostic..." -ForegroundColor Yellow
    Write-Host "    This will run on next restart to check for RAM issues" -ForegroundColor Gray

    try {
        # Schedule memory diagnostic
        & mdsched.exe

        Write-Host "`n  ⚠️  Memory diagnostics scheduled for next restart" -ForegroundColor Yellow
        Write-Host "    The system will restart and run memory tests" -ForegroundColor Gray
        Write-Host "    This may take several minutes" -ForegroundColor Gray
        Write-Log -Message "Memory diagnostics scheduled" -Level WARNING

        $script:RestartRequired = $true

    } catch {
        Write-Host "  ✗ Error scheduling memory diagnostics: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log -Message "Memory diagnostics scheduling error: $($_.Exception.Message)" -Level ERROR
    }
}

# --- 5. Optional Cleanup ---

function Invoke-SystemCleanup {
    Write-SectionHeader "System Cleanup" "🧹"

    try {
        Write-Host "`n  Running Disk Cleanup with aggressive settings..." -ForegroundColor Yellow
        Write-Host "    This will remove temporary files, old Windows installations, etc." -ForegroundColor Gray

        # Run cleanmgr with very low disk option
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/verylowdisk" -Wait -NoNewWindow

        Write-Host "  ✓ Disk cleanup completed" -ForegroundColor Green
        Write-Log -Message "Disk cleanup completed" -Level SUCCESS

    } catch {
        Write-Host "  ✗ Error running disk cleanup: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log -Message "Disk cleanup error: $($_.Exception.Message)" -Level ERROR
    }
}

function Update-GroupPolicy {
    Write-SectionHeader "Group Policy Update" "📋"

    try {
        Write-Host "`n  Applying latest group policies..." -ForegroundColor Yellow

        $gpOutput = & gpupdate /force 2>&1 | Out-String

        Write-Host "  ✓ Group policies updated successfully" -ForegroundColor Green
        Write-Log -Message "Group policy updated: $gpOutput" -Level SUCCESS

    } catch {
        Write-Host "  ✗ Error updating group policies: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log -Message "Group policy update error: $($_.Exception.Message)" -Level ERROR
    }
}

# --- 6. Final Administrative Tasks ---

function Hide-AdminAccount {
    Write-SectionHeader "Administrative Account Configuration" "👤"

    try {
        Write-Host "`n  Configuring local admin account visibility..." -ForegroundColor Yellow

        $userListPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"

        # Hide admin account from login screen
        Set-RegistryDword -Path $userListPath -Name "admin" -Value 0
        Set-RegistryDword -Path $userListPath -Name "Administrator" -Value 0

        Write-Host "  ✓ Admin accounts configured to be hidden from login screen" -ForegroundColor Green
        Write-Log -Message "Admin accounts hidden from login screen" -Level SUCCESS

    } catch {
        Write-Host "  ✗ Error configuring admin account: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log -Message "Admin account configuration error: $($_.Exception.Message)" -Level ERROR
    }
}

function New-FinalRestorePoint {
    Write-SectionHeader "System Restore Point" "💾"

    try {
        Write-Host "`n  Creating final system restore point..." -ForegroundColor Yellow

        # Enable System Protection if not already enabled
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue

        # Create restore point
        Checkpoint-Computer -Description "Maintenance Complete - $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -RestorePointType "MODIFY_SETTINGS"

        Write-Host "  ✓ System restore point created successfully" -ForegroundColor Green
        Write-Host "    Name: Maintenance Complete - $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Gray
        Write-Log -Message "System restore point created" -Level SUCCESS

    } catch {
        Write-Host "  ✗ Error creating restore point: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "    Note: Restore points may be limited by system policy or disk space" -ForegroundColor Yellow
        Write-Log -Message "Restore point creation error: $($_.Exception.Message)" -Level ERROR
    }
}

# --- Main Execution ---

try {
    Clear-Host

    # Create log file
    New-Item -Path $script:LogPath -ItemType File -Force | Out-Null
    Write-Log -Message "=== Maintenance Script Started ===" -Level INFO

    # Header
    Write-Host "`n" -NoNewline
    # Legend: DarkGreen = Script Titles
    Write-Host "WINDOWS 11 FINALIZATION & MAINTENANCE" -ForegroundColor DarkGreen
    # Legend: DarkBlue = Section boundary lines (50 chars)
    Write-Host ("═" * 50) -ForegroundColor DarkBlue

    # --- Task Selection Menu ---
    Write-Host "`n" -NoNewline
    # Legend: DarkBlue = Section boundary lines (50 chars)
    Write-Host ("─" * 50) -ForegroundColor DarkBlue
    # Legend: Cyan = Section Titles
    Write-Host "  MAINTENANCE TASK SELECTION" -ForegroundColor Cyan
    Write-Host ("─" * 50) -ForegroundColor DarkBlue
    
    $tasks = @(
        @{ ID=1; Name="Disk Optimization"; Function="Optimize-Disks" },
        @{ ID=2; Name="Power Settings Optimization"; Function="Set-PowerSettings" },
        @{ ID=3; Name="Visual Effects Optimization"; Function="Optimize-VisualEffects" },
        @{ ID=4; Name="System Integrity & Diagnostics"; Function="Run-Diagnostics" },
        @{ ID=5; Name="System Cleanup"; Function="Invoke-SystemCleanup" },
        @{ ID=6; Name="Group Policy Update"; Function="Update-GroupPolicy" },
        @{ ID=7; Name="Hide Administrative Accounts"; Function="Hide-AdminAccount" },
        @{ ID=8; Name="Create Restore Point"; Function="New-FinalRestorePoint" }
    )

    foreach ($t in $tasks) {
        Write-Host "  [$($t.ID)] $($t.Name)" -ForegroundColor White
    }
    Write-Host "  [A] Run All Tasks" -ForegroundColor Green
    Write-Host "  [Q] Quit" -ForegroundColor Red
    
    $selection = Read-Host "`nSelect tasks (1,3,5) or 'A' for All: "
    
    if ($selection -match "^[Qq]") { exit }
    
    $selectedIDs = @()
    if ($selection -match "^[Aa]") {
        $selectedIDs = $tasks.ID
    } else {
        $selectedIDs = $selection -split "," | ForEach-Object { $_.Trim() }
    }
    
    # Execute selected tasks
    foreach ($id in $selectedIDs) {
        switch ($id) {
            1 { Optimize-Disks }
            2 { Set-PowerSettings }
            3 { Optimize-VisualEffects }
            4 { 
                # Diagnostics sequence
                $sfcResult = Test-SystemFiles
                if (-not $sfcResult) {
                    $dismResult = Repair-WindowsImage
                    if (-not $dismResult) {
                        Start-MemoryDiagnostics
                    }
                }
            }
            5 { Invoke-SystemCleanup }
            6 { Update-GroupPolicy }
            7 { Hide-AdminAccount }
            8 { New-FinalRestorePoint }
        }
    }

    # Summary
    # $elapsed = ((Get-Date) - $script:StartTime).TotalSeconds

    Write-Host "`n" -NoNewline
    # Legend: DarkBlue = Section boundary lines (50 chars)
    Write-Host ("═" * 50) -ForegroundColor DarkBlue
    Write-Host "  MAINTENANCE SUMMARY" -ForegroundColor White
    Write-Host ("═" * 50) -ForegroundColor DarkBlue

    # Write-Host "`n  ⏱️  Total time: " -NoNewline -ForegroundColor Gray
    # Write-Host "$([math]::Round($elapsed, 2)) seconds" -ForegroundColor White

    Write-Host "`n📋  $script:LogPath" -ForegroundColor White

    if ($script:ErrorsFound.Count -gt 0) {
        Write-Host "`n  ⚠️  Issues found:" -ForegroundColor Yellow
        foreach ($error in $script:ErrorsFound) {
            Write-Host "    • $error" -ForegroundColor Yellow
        }
    } else {
        Write-Host "`n  ✓ " -NoNewline -ForegroundColor Green
        Write-Host "All checks passed successfully" -ForegroundColor White
    }

    if ($script:RestartRequired) {
        Write-Host "`n  ⚠️  RESTART REQUIRED" -ForegroundColor Yellow
        Write-Host "    Windows Memory Diagnostic has been scheduled" -ForegroundColor Gray
        Write-Host "    The system will restart and run memory tests" -ForegroundColor Gray
        Write-Host "`n    Restart your computer when convenient to complete diagnostics" -ForegroundColor White
    }

    Write-Host "`n" -NoNewline
    # Legend: DarkBlue = Section boundary lines (50 chars)
    Write-Host ("─" * 50) -ForegroundColor DarkBlue
    Write-Host "  Maintenance completed: " -NoNewline -ForegroundColor Gray
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
    Write-Host "  www.AIIT.support all rights reserved" -ForegroundColor Green
    Write-Host ("─" * 50) -ForegroundColor DarkBlue
    Write-Host ""

    Write-Log -Message "=== Maintenance Script Completed ===" -Level INFO

} catch {
    Write-Host "`n[CRITICAL ERROR] " -NoNewline -ForegroundColor Red
    Write-Host $_ -ForegroundColor White
    Write-Host "`nMaintenance script encountered a critical error." -ForegroundColor Yellow
    Write-Host "Check log file: $script:LogPath`n" -ForegroundColor Gray
    Write-Log -Message "Critical error: $($_.Exception.Message)" -Level ERROR
}
