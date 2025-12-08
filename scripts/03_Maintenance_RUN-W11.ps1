#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- [USER PREFERENCE] CLEAR SCREEN START ---
Clear-Host
# --------------------------------------------

<#
.SYNOPSIS
  Windows 11 Finalization & Maintenance Script
.DESCRIPTION
  Performs comprehensive system optimization, diagnostics, and maintenance tasks.
  
  MATCHED FORMATTING TO scriptRULES-W11.ps1 standards.
#>

# --- Preamble: Formatting Rules & Encoding ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Esc = [char]0x1B
$Reset = "$Esc[0m"
$Bold = "$Esc[1m"

# Colors from Rules
$FGCyan       = "$Esc[96m"
$FGDarkCyan   = "$Esc[36m"
$FGDarkBlue   = "$Esc[34m"
$FGBlue       = "$Esc[94m"  # Added for Header Icon
$FGWhite      = "$Esc[97m"
$FGGray       = "$Esc[37m"
$FGDarkGray   = "$Esc[90m"
$FGDarkGreen  = "$Esc[32m"
$FGDarkRed    = "$Esc[31m"
$FGDarkYellow = "$Esc[33m"
$FGYellow     = "$Esc[93m"
$FGDarkMagenta= "$Esc[35m"

# Icons
$Char_EmDash      = [char]0x2014
$Char_BallotCheck = [char]0x2611 # ☑
$Char_XSquare     = [char]0x274E # ❎
$Char_Warn        = [char]0x26A0 # ⚠
$Char_Finger      = [char]0x261B # ☛
$Char_Keyboard    = [char]0x2328 # ⌨
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504)
$Char_Copyright   = [char]0x00A9
$Char_NoEntry     = [char]::ConvertFromUtf32(0x26D4) # 🚫

# Global Variables
$script:LogPath = "C:\Windows\Temp\Maint_$(Get-Date -Format 'yyMMdd').log"
$script:RestartRequired = $false
$script:ErrorsFound = @()

# --- Formatting Helpers ---

function Write-Centered {
    param(
        [string]$Text,
        [int]$Width = 60
    )
    $cleanText = $Text -replace "$Esc\[[0-9;]*m", ""
    $padLeft = [Math]::Floor(($Width - $cleanText.Length) / 2)
    if ($padLeft -lt 0) { $padLeft = 0 }
    
    Write-Host (" " * $padLeft + $Text)
}

function Write-LeftAligned {
    param(
        [string]$Text,
        [int]$Indent = 2
    )
    Write-Host (" " * $Indent + $Text)
}

function Write-Header {
    param([string]$Title)
    $Width = 60
    $Pad = [Math]::Max(0, [Math]::Floor(($Width - $Title.Length) / 2))
    $Line = "$FGDarkBlue$([string]$Char_EmDash * $Width)$Reset"
    
    # Print Top Line, Centered Title, Sub-Header
    Write-Host $Line
    Write-Host (" " * $Pad + "$Bold$FGCyan$Title$Reset")
    
    $SubText = "Patch-W11 "
    $SubIcon = "$Char_Loop"
    $SubPad = [Math]::Max(0, [Math]::Floor(($Width - ($SubText.Length + 1)) / 2)) # Approx width fix for icon
    Write-Host (" " * $SubPad + "$Bold$FGDarkCyan$SubText$FGBlue$SubIcon$Reset")
    Write-Host $Line
}

function Write-BodyTitle {
    param([string]$Title)
    Write-LeftAligned "$Bold$FGWhite$Char_EmDash$Char_EmDash $Title $Char_EmDash$Char_EmDash$Reset"
}

function Write-Boundary {
    param([string]$Color = $FGDarkBlue)
    Write-Host "$Color$([string]$Char_EmDash * 60)$Reset"
}

function Get-StatusLine {
    param(
        [bool]$IsEnabled,
        [string]$Text
    )
    if ($IsEnabled) {
        return "$FGDarkGreen$Char_BallotCheck  $FGDarkCyan$Text$Reset"
    } else {
        return "$FGDarkRed$Char_XSquare $FGDarkCyan$Text$Reset"
    }
}

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
    Write-Host ""
    Write-Header "DISK OPTIMIZATION"

    try {
        $volumes = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' }

        foreach ($volume in $volumes) {
            $drive = $volume.DriveLetter
            Write-Host ""
            Write-BodyTitle "Drive $drive`:\"

            try {
                $isSSD = $false
                $partition = Get-Partition -DriveLetter $drive -ErrorAction SilentlyContinue
                if ($partition) {
                    $disk = Get-Disk -Number $partition.DiskNumber -ErrorAction SilentlyContinue
                    if ($disk) {
                        $mediaTypeProperty = $disk.PSObject.Properties | Where-Object { $_.Name -eq 'MediaType' }
                        if ($mediaTypeProperty -and $disk.MediaType -eq 'SSD') {
                            $isSSD = $true
                        }
                    }
                }

                if ($isSSD) {
                    Write-LeftAligned "$FGYellow Type: SSD - Running TRIM...$Reset"
                    Optimize-Volume -DriveLetter $drive -ReTrim -Verbose | Out-Null
                    Write-LeftAligned (Get-StatusLine $true "TRIM completed successfully")
                    Write-Log -Message "TRIM completed for drive $drive" -Level SUCCESS
                } else {
                    Write-LeftAligned "$FGYellow Type: HDD - Running Defrag...$Reset"
                    Optimize-Volume -DriveLetter $drive -Defrag -Verbose | Out-Null
                    Write-LeftAligned (Get-StatusLine $true "Defragmentation completed")
                    Write-Log -Message "Defragmentation completed for drive $drive" -Level SUCCESS
                }
            } catch {
                Write-LeftAligned "$FGDarkRed$Char_XSquare Failed to optimize drive: $($_.Exception.Message)$Reset"
                Write-Log -Message "Failed to optimize drive $drive`: $($_.Exception.Message)" -Level ERROR
            }
        }
    } catch {
        Write-LeftAligned "$FGDarkRed$Char_XSquare Disk optimization error$Reset"
        Write-Log -Message "Disk optimization error: $($_.Exception.Message)" -Level ERROR
    }
    Write-Boundary $FGDarkGray
}

# --- 2. Power Settings ---

function Set-PowerSettings {
    Write-Host ""
    Write-Header "POWER SETTINGS"

    try {
        Write-LeftAligned "$FGYellow Setting High Performance plan...$Reset"
        $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        powercfg /setactive $highPerfGuid
        Write-LeftAligned (Get-StatusLine $true "Power plan set to High Performance")
        Write-Log -Message "Power plan set to High Performance" -Level SUCCESS

        Write-LeftAligned "$FGYellow Setting Best Performance mode...$Reset"
        $powerSettingsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7"
        Set-RegistryDword -Path $powerSettingsPath -Name "ACSettingIndex" -Value 0
        Set-RegistryDword -Path $powerSettingsPath -Name "DCSettingIndex" -Value 0
        Write-LeftAligned (Get-StatusLine $true "Power mode configured")

    } catch {
        Write-LeftAligned "$FGDarkRed$Char_XSquare Error: $($_.Exception.Message)$Reset"
        Write-Log -Message "Power settings error: $($_.Exception.Message)" -Level ERROR
    }
    Write-Boundary $FGDarkGray
}

# --- 3. Visual Effects Optimization ---

function Optimize-VisualEffects {
    Write-Host ""
    Write-Header "VISUAL EFFECTS"

    try {
        Write-LeftAligned "$FGYellow Adjusting for best performance...$Reset"

        $visualEffectsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
        Set-RegistryDword -Path $visualEffectsPath -Name "VisualFXSetting" -Value 2

        try {
            $maskPath = "HKCU:\Control Panel\Desktop"
            $maskValue = [byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)
            Set-ItemProperty -Path $maskPath -Name "UserPreferencesMask" -Value $maskValue -Type Binary -Force
            Write-Log -Message "UserPreferencesMask set successfully" -Level SUCCESS
        } catch {
            Write-Log -Message "Failed to set UserPreferencesMask: $($_.Exception.Message)" -Level WARNING
        }

        Set-RegistryDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 0
        Set-RegistryDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0
        Set-RegistryDword -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0

        Write-LeftAligned (Get-StatusLine $true "Visual effects optimized")
        Write-LeftAligned "$FGGray Note: Requires logout/restart$Reset"
        Write-Log -Message "Visual effects optimized" -Level SUCCESS

    } catch {
        Write-LeftAligned "$FGDarkRed$Char_XSquare Error: $($_.Exception.Message)$Reset"
        Write-Log -Message "Visual effects error: $($_.Exception.Message)" -Level ERROR
    }
    Write-Boundary $FGDarkGray
}

# --- 4. System Cleanup (Completed Section) ---

function Optimize-SystemCleanup {
    Write-Host ""
    Write-Header "SYSTEM CLEANUP"
    
    $cleanCount = 0
    $tempPaths = @(
        "$env:TEMP",
        "$env:WINDIR\Temp"
    )

    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            Write-BodyTitle "Cleaning: $path"
            try {
                $files = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                if ($files) {
                    $fileCount = $files.Count
                    $files | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                    Write-LeftAligned (Get-StatusLine $true "Removed $fileCount temporary items")
                    $cleanCount += $fileCount
                } else {
                    Write-LeftAligned "$FGGray  Folder is already empty$Reset"
                }
            } catch {
                Write-LeftAligned "$FGDarkRed$Char_XSquare Partial cleanup failure$Reset"
            }
        }
    }
    Write-Log -Message "System cleanup removed $cleanCount items" -Level SUCCESS
    Write-Boundary $FGDarkGray
}

# --- Main Execution ---

try {
    # --- Determine Copyright Year ---
    $ScriptPath = $PSCommandPath
    if ($ScriptPath) {
        $LastEditYear = (Get-Item $ScriptPath).LastWriteTime.Year
    } else {
        $LastEditYear = (Get-Date).Year
    }
    $CopyrightLine = "© $LastEditYear, www.AIIT.support. All Rights Reserved."

    $showMenu = $true

    while ($showMenu) {
        Clear-Host
        Write-Host "`n" -NoNewline
        
        # Standard Header
        Write-Header "MAINTENANCE & OPTIMIZATION"
        
        Write-Host ""
        Write-BodyTitle "AVAILABLE MAINTENANCE TASKS"
        
        # Menu Options (Rule 4: 2-space Indent)
        Write-LeftAligned " ${FGYellow}[1]${Reset} Disk Optimization"
        Write-LeftAligned " ${FGYellow}[2]${Reset} Power Settings"
        Write-LeftAligned " ${FGYellow}[3]${Reset} Visual Effects"
        Write-LeftAligned " ${FGYellow}[4]${Reset} System Cleanup"
        Write-Host ""
        Write-LeftAligned " ${FGYellow}[A]${Reset} Run All Tasks"
        
        Write-Boundary $FGDarkBlue
        
        # Prompt
        $prompt = "${FGDarkCyan}$Char_Keyboard  ${FGYellow}Press ${FGYellow}$Char_Finger Key${FGDarkCyan} to Select  |  Press ${FGYellow}$Char_Finger Spacebar${FGDarkCyan} to Exit$Reset"
        Write-Centered $prompt
        
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        if ($key.Character -eq ' ') {
            $showMenu = $false
            Write-Host ""
            Write-LeftAligned "$FGGray Exiting...$Reset"
        } else {
            # Execute Selection
            switch ($key.Character.ToString().ToUpper()) {
                '1' { Optimize-Disks }
                '2' { Set-PowerSettings }
                '3' { Optimize-VisualEffects }
                '4' { Optimize-SystemCleanup }
                'A' { 
                    Optimize-Disks
                    Set-PowerSettings
                    Optimize-VisualEffects
                    Optimize-SystemCleanup
                }
                Default { continue } # Skip to top if invalid
            }
            
            # Pause to allow user to read output
            Write-Host ""
            Write-Centered "$FGGray Press any key to return to menu...$Reset"
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
    
    # Footer
    Write-Host "`n" -NoNewline
    Write-Host "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"
    $padCopyright = [math]::Max(0, [math]::Floor((60 - $CopyrightLine.Length) / 2))
    Write-Host (" " * $padCopyright) -NoNewline
    Write-Host "$FGDarkCyan$CopyrightLine$Reset"
    
    # Final 5 Empty Lines
    1..5 | ForEach-Object { Write-Host "" }
    
} catch {
    Write-Host "`n$FGDarkRed$Char_XSquare Critical Script Error: $($_.Exception.Message)$Reset"
    Write-Log -Message "Critical Script Error: $($_.Exception.Message)" -Level ERROR
    exit 1
}
