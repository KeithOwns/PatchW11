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
  UPDATED: Helper functions unified.
  UPDATED: Logging standardized.
  UPDATED: Header Icon placement.
  UPDATED: Visual styles (High contrast keys, Disabled backgrounds, EnDashes).
  UPDATED: Fixed System Restore logic and removed CPU Turbo Boost limiter.
  UPDATED: Header layout and Main Menu Prompt colors (DarkGray Background for Spacebar).
  UPDATED: Menu colors and layout (Centered Title, Yellow "SELECT", Adjusted Spacing).
  UPDATED: "Run ALL Tasks" formatting (Yellow "ALL").
  UPDATED: Restore Point prompt styling to match Main Menu.
  UPDATED: Reordered "Run ALL Tasks" logic for expert efficiency (Cleanup -> Power -> Visuals -> Disk).
  UPDATED: Fixed spacing in Main Menu Title (added spaces inside dashes).
  UPDATED: Main Menu Prompt text and logic ("any other key to EXIT").
  UPDATED: Reverted Title to "RUN", DarkBlue Boundary, Added Space to Exit Prompt.
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
$FGBlue       = "$Esc[94m"
$FGWhite      = "$Esc[97m"
$FGGray       = "$Esc[37m"
$FGDarkGray   = "$Esc[90m"
$FGDarkGreen  = "$Esc[32m"
$FGGreen      = "$Esc[92m"
$FGDarkRed    = "$Esc[31m"
$FGRed        = "$Esc[91m"
$FGDarkYellow = "$Esc[33m"
$FGYellow     = "$Esc[93m"
$FGDarkMagenta= "$Esc[35m"
$FGBlack      = "$Esc[30m"

# Background Colors (Added for Compliance)
$BGDarkRed    = "$Esc[41m"
$BGYellow     = "$Esc[103m"
$BGDarkCyan   = "$Esc[46m"
$BGDarkGray   = "$Esc[100m"
$BGGray       = "$Esc[47m" # Added for EXIT prompt

# Icons
$Char_EmDash      = [char]0x2014 # —
$Char_EnDash      = [char]0x2013 # – (Added for Body Titles)
$Char_BallotCheck = [char]0x2611 # ☑
$Char_Check       = [char]0x2713
$Char_Cross       = [char]0x2718
$Char_XSquare     = [char]0x274E # ❎
$Char_Warn        = [char]0x26A0 # ⚠
$Char_Info        = [char]0x2139
$Char_Bell        = [char]::ConvertFromUtf32(0x1F514)
$Char_Gear        = [char]0x2699
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504) # 🔄
$Char_Shield      = [char]::ConvertFromUtf32(0x1F6E1) # 🛡️
$Char_Person      = [char]::ConvertFromUtf32(0x1F464) # 👤
$Char_Satellite   = [char]::ConvertFromUtf32(0x1F4E1) # 📡
$Char_CardIndex   = [char]::ConvertFromUtf32(0x1F5C2) # 🗂️
$Char_Desktop     = [char]::ConvertFromUtf32(0x1F5A5) # 🖥️
$Char_Keyboard    = [char]0x2328 # ⌨
$Char_Finger      = [char]0x261B # ☛
$Char_NoEntry     = [char]::ConvertFromUtf32(0x26D4) # 🚫
$Char_WhiteCheck  = [char]0x2705 # ✅
$Char_CrossMark   = [char]::ConvertFromUtf32(0x274C) # ❌
$Char_Copyright   = [char]0x00A9
$Char_Eject       = [char]0x23CF # ⏏

# Global Variables
$script:LogPath = "C:\Windows\Temp\Maint_$(Get-Date -Format 'yyMMdd').log"
$script:RestartRequired = $false
$script:ErrorsFound = @()

# --- Unified Helper Functions ---

function Write-Centered {
    param([string]$Text, [int]$Width = 60)
    $cleanText = $Text -replace "$Esc\[[0-9;]*m", ""
    $padLeft = [Math]::Floor(($Width - $cleanText.Length) / 2)
    if ($padLeft -lt 0) { $padLeft = 0 }
    Write-Host (" " * $padLeft + $Text)
}

function Write-LeftAligned {
    param([string]$Text, [int]$Indent = 2)
    Write-Host (" " * $Indent + $Text)
}

function Write-Header {
    param([string]$Title)
    # Line 1: Top Title "— Patch-W11 —" (Cyan, Centered)
    $TopTitle = "$Char_EmDash Patch-W11 $Char_EmDash"
    Write-Centered "$Bold$FGCyan$TopTitle$Reset"
    
    # Line 2: The Variable Title (DarkCyan, Centered)
    Write-Centered "$Bold$FGDarkCyan$Title$Reset"
    
    # Line 3: Boundary (DarkBlue)
    Write-Boundary $FGDarkBlue
}

function Write-BodyTitle {
    param([string]$Title)
    # UPDATED: Use EnDash and specific spacing (Rule 7/8 equivalent in Visuals)
    Write-LeftAligned "$Bold$FGWhite $Char_EnDash $Title $Char_EnDash$Reset"
}

function Write-Boundary {
    param([string]$Color = $FGDarkBlue)
    Write-Host "$Color$([string]$Char_EmDash * 60)$Reset"
}

function Get-StatusLine {
    param([bool]$IsEnabled, [string]$Text)
    if ($IsEnabled) { 
        # UPDATED: Full DarkGreen line for Enabled/Success (Matches Visual Rules Row 10)
        return "$FGDarkGreen$Char_BallotCheck $Text$Reset" 
    }
    else { 
        # UPDATED: Black on DarkRed BG for Disabled (Matches Visual Rules Row 11)
        return "${FGBlack}${BGDarkRed}$Char_XSquare $Text$Reset" 
    }
}

# --- Logging & Registry Functions (Standardized) ---

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
    } catch {
        Write-Log -Message "Failed to set registry: $Path\$Name - $($_.Exception.Message)" -Level ERROR
        throw $_ 
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
                # UPDATED: Use FGRed for Script/Action Failure
                Write-LeftAligned "$FGRed$Char_XSquare Failed to optimize drive: $($_.Exception.Message)$Reset"
                Write-Log -Message "Failed to optimize drive $drive`: $($_.Exception.Message)" -Level ERROR
            }
        }
    } catch {
        Write-LeftAligned "$FGRed$Char_XSquare Disk optimization error$Reset"
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

        # REMOVED: Registry edit for Processor Performance Boost Mode (0).
        # Setting "Processor performance boost mode" to 0 (Disabled) effectively disables Turbo Boost,
        # capping the CPU at base clock. This contradicts "High Performance".
        # We rely on the High Performance Power Plan activated above to manage boost states correctly.

    } catch {
        Write-LeftAligned "$FGRed$Char_XSquare Error: $($_.Exception.Message)$Reset"
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
        Write-LeftAligned "$FGRed$Char_XSquare Error: $($_.Exception.Message)$Reset"
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
                # UPDATED: Use FGRed for Script Failure
                Write-LeftAligned "$FGRed$Char_XSquare Partial cleanup failure$Reset"
            }
        }
    }
    Write-Log -Message "System cleanup removed $cleanCount items" -Level SUCCESS
    Write-Boundary $FGDarkGray
}

# --- 5. Create System Restore Point (New Function) ---

function Create-RestorePoint {
    Write-Host ""
    Write-Header "SYSTEM RESTORE POINT"

    # REMOVED: The check "if (-not (Get-ComputerRestorePoint...))".
    # This command lists *existing* restore points. If the system has Restore ENABLED but 0 points,
    # the original check would fail and claim it was disabled.
    # We now let Checkpoint-Computer run; if disabled, the Catch block will handle it.

    try {
        $pointName = "Maintenance Script $(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-LeftAligned "$FGYellow Creating restore point: $pointName...$Reset"
        
        Checkpoint-Computer -Description $pointName -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        
        Write-LeftAligned (Get-StatusLine $true "Restore Point created successfully")
        Write-Log -Message "Restore Point '$pointName' created successfully" -Level SUCCESS

    } catch {
        # This catch block will handle cases where System Restore is actually disabled
        Write-LeftAligned "${FGBlack}${BGDarkRed}$Char_XSquare Failed to create Restore Point: $($_.Exception.Message)$Reset"
        Write-Log -Message "Failed to create Restore Point: $($_.Exception.Message)" -Level ERROR
    }
    Write-Boundary $FGDarkGray
}

# --- Main Execution ---

try {
    # Script 03 Footer Logic
    $ScriptPath = $PSCommandPath
    if ($ScriptPath) { $LastEditYear = (Get-Item $ScriptPath).LastWriteTime.Year } else { $LastEditYear = (Get-Date).Year }
    $CopyrightLine = "© $LastEditYear, www.AIIT.support. All Rights Reserved."

    $showMenu = $true

    while ($showMenu) {
        Clear-Host
        Write-Host "`n" -NoNewline
        
        # Standard Header (Updated Style)
        Write-Header "MAINTENANCE & OPTIMIZATION"
        
        # REMOVED: Empty line above body title
        
        # Updated Body Title: Centered, Cyan, with Yellow "RUN"
        # Reverted "SELECT" to "RUN" and adjusted spacing: "–  RUN"
        $BodyTitle = "$Bold$FGCyan$Char_EnDash  ${FGYellow}RUN${FGCyan} Maintenance & Optimization Tasks $Char_EnDash$Reset"
        Write-Centered $BodyTitle
        
        # ADDED: Empty line below body title
        Write-Host ""
        
        # Menu Options (Rule 4: 2-space Indent)
        # UPDATED: Use Black on Yellow for Input Keys
        # UPDATED: Use DarkCyan for Item Text
        Write-LeftAligned " ${FGBlack}${BGYellow}[1]${Reset} ${FGDarkCyan}Disk Optimization${Reset}"
        Write-LeftAligned " ${FGBlack}${BGYellow}[2]${Reset} ${FGDarkCyan}Power Settings${Reset}"
        Write-LeftAligned " ${FGBlack}${BGYellow}[3]${Reset} ${FGDarkCyan}Visual Effects${Reset}"
        Write-LeftAligned " ${FGBlack}${BGYellow}[4]${Reset} ${FGDarkCyan}System Cleanup${Reset}"
        Write-Host ""
        
        # UPDATED: "All" -> "ALL" (Yellow)
        Write-LeftAligned " ${FGBlack}${BGYellow}[A]${Reset} ${FGDarkCyan}Run ${FGYellow}ALL${FGDarkCyan} Tasks${Reset}"
        
        # UPDATED: Use DarkBlue for boundary below the tasks
        Write-Boundary $FGDarkBlue
        
        # Prompt (Completely Redesigned per Request)
        # ⌨ Press ☛ ['Key'] to RUN or any other key to EXIT⏏ 
        # UPDATED: Colors matched to request. Added space after Eject icon inside BG.
        $prompt = "${FGWhite}$Char_Keyboard  ${FGDarkCyan}Press ${FGYellow}$Char_Finger ${FGBlack}${BGYellow}['Key']${Reset}${FGDarkCyan} to ${FGYellow}RUN${FGDarkCyan} or any other ${FGGray}key${FGDarkCyan} to ${FGRed}${BGGray}EXIT$Char_Eject ${Reset}"
        Write-Centered $prompt
        
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        $taskCompleted = $false
        
        # Execute Selection or Exit
        switch ($key.Character.ToString().ToUpper()) {
            '1' { Optimize-Disks; $taskCompleted = $true }
            '2' { Set-PowerSettings; $taskCompleted = $true }
            '3' { Optimize-VisualEffects; $taskCompleted = $true }
            '4' { Optimize-SystemCleanup; $taskCompleted = $true }
            'A' { 
                # UPDATED ORDER: Clean > Power > Visuals > Disk
                Optimize-SystemCleanup
                Set-PowerSettings
                Optimize-VisualEffects
                Optimize-Disks
                $taskCompleted = $true
            }
            Default { 
                # "Any other key to EXIT"
                $showMenu = $false
                Write-Host ""
                Write-LeftAligned "$FGGray Exiting...$Reset"
            }
        }


        # Check for completed tasks and show new prompt
        if ($taskCompleted) {
            Write-Host ""
            Write-Boundary $FGDarkBlue
            
            # New Prompt: Restore Point or Exit
            # UPDATED: Styled to match Main Menu Prompt
            $restorePrompt = "${FGWhite}$Char_Keyboard  ${FGDarkCyan}Press ${FGYellow}$Char_Finger ${FGBlack}${BGYellow}[Enter]${Reset}${FGDarkCyan} to ${FGYellow}Create Restore Point${FGDarkCyan}  ${FGWhite}|${FGDarkCyan}  Press ${FGDarkGray}$Char_Finger ${FGBlack}${BGDarkGray}[Spacebar]${Reset}${FGDarkCyan} to ${FGDarkGray}Exit${Reset}"
            Write-Centered $restorePrompt
            
            $key2 = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            
            if ($key2.Character -eq [char]0x0D) { # Enter key is ASCII 0x0D
                Create-RestorePoint
                # Wait after creating restore point before returning to main menu
                Write-Host ""
                Write-Centered "$FGGray Press any key to return to menu...$Reset"
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            } elseif ($key2.Character -eq ' ') {
                $showMenu = $false
                Write-Host ""
                Write-LeftAligned "$FGGray Exiting...$Reset"
            }
        }
    }
    
    # Footer
    Write-Host "`n" -NoNewline
    Write-Host "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"
    $padCopyright = [math]::Max(0, [math]::Floor((60 - $CopyrightLine.Length) / 2))
    Write-Host (" " * $padCopyright) -NoNewline
    # UPDATED: Changed to FGCyan (Cyan) instead of DarkCyan
    Write-Host "$FGCyan$CopyrightLine$Reset"
    
    # Final 5 Empty Lines
    1..5 | ForEach-Object { Write-Host "" }
    
} catch {
    # UPDATED: Use FGRed for Critical Failure
    Write-Host "`n$FGRed$Char_XSquare Critical Script Error: $($_.Exception.Message)$Reset"
    Write-Log -Message "Critical Script Error: $($_.Exception.Message)" -Level ERROR
    exit 1
}
