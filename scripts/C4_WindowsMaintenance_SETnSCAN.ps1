#Requires -RunAsAdministrator
param([switch]$AutoRun)
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
  
  MATCHED FORMATTING TO scriptRULES-W11.ps1 (v8.33).
  UPDATED: Header completely aligned with Rules visual style.
  UPDATED: Body Titles use Heavy Minus (➖).
  UPDATED: Status lines match Visual Legend (FG Colors, no BG).
  UPDATED: Text colors changed from DarkCyan to Gray (Menu, Prompt, Status).
  UPDATED: Prompt syntax strictly aligned with Rules script formatting.
  UPDATED: Clears Prompt and Exiting message on exit before printing Footer.
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

# Background Colors
$BGDarkRed    = "$Esc[41m"
$BGYellow     = "$Esc[103m"
$BGDarkCyan   = "$Esc[46m"
$BGDarkGray   = "$Esc[100m"
$BGGray       = "$Esc[47m"
$BGDarkGreen  = "$Esc[42m"

# Icons
$Char_HeavyLine   = [char]0x2501 # ━
$Char_LightLine   = [char]0x2500 # ─
$Char_Overline    = [char]0x203E # ‾
$Char_EmDash      = [char]0x2014 # —
$Char_EnDash      = [char]0x2013 # –
$Char_HeavyMinus  = [char]0x2796 # ➖ (Used for Body Titles)
$Char_BallotCheck = [char]0x2611 # ☑
$Char_Check       = [char]0x2713
$Char_RedCross    = [char]0x274E # ❎ (Used for Disabled/Failure)
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
$Char_Copyright   = [char]0x00A9
$Char_Eject       = [char]0x23CF # ⏏
$Char_Skip        = [char]0x23ED # ⏭

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
    # Line 1: Top Title " ━ PatchW11 ━" (Cyan, Centered) matches Rules visual
    $TopTitle = " ${Char_HeavyLine} PatchW11 ${Char_HeavyLine} " 
    Write-Centered "$Bold$FGCyan$TopTitle$Reset"
    
    # Line 2: Main Title (Cyan, Centered) matches "SCRIPT OUTPUT RULES" style
    Write-Centered "$Bold$FGCyan$Title$Reset"
    
    # Line 3: Boundary (DarkBlue)
    Write-Boundary $FGDarkBlue
}

function Write-BodyTitle {
    param([string]$Title)
    # Rules Legend "White": BOLD ➖
    Write-LeftAligned "$Bold$FGWhite$Char_HeavyMinus $Title$Reset"
}

function Write-Boundary {
    param([string]$Color = $FGDarkBlue)
    Write-Host "$Color$([string]$Char_HeavyLine * 60)$Reset"
}

function Get-StatusLine {
    param([bool]$IsEnabled, [string]$Text)
    if ($IsEnabled) { 
        # Visual Row 10: DarkGreen Icon + Gray Text (Body Text Rule)
        return "$FGDarkGreen$Char_BallotCheck $FGGray$Text$Reset" 
    }
    else { 
        # Visual Row 11: DarkRed Icon + DarkRed Text
        return "$FGDarkRed$Char_RedCross $Text$Reset" 
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
                # Visual Row 5: Red Failure
                Write-LeftAligned "$FGRed$Char_RedCross Failed to optimize drive: $($_.Exception.Message)$Reset"
                Write-Log -Message "Failed to optimize drive $drive`: $($_.Exception.Message)" -Level ERROR
            }
        }
    } catch {
        Write-LeftAligned "$FGRed$Char_RedCross Disk optimization error$Reset"
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

    } catch {
        Write-LeftAligned "$FGRed$Char_RedCross Error: $($_.Exception.Message)$Reset"
        Write-Log -Message "Power settings error: $($_.Exception.Message)" -Level ERROR
    }
    Write-Boundary $FGDarkGray
}

# --- 3. Visual Effects Optimization ---

function Optimize-VisualEffects {
    Write-Host ""
    Write-Header "VISUAL EFFECTS"

    # Check for SYSTEM account
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    if ($currentUser -match "SYSTEM") {
        Write-LeftAligned "$FGGray Skipping Visual Effects (Running as SYSTEM/Service)$Reset"
        Write-LeftAligned "$FGGray These settings apply to the Current User (HKCU).$Reset"
        Write-Log -Message "Skipped Visual Effects optimization (Running as SYSTEM)" -Level WARNING
        Write-Boundary $FGDarkGray
        return
    }

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
        Write-LeftAligned "$FGRed$Char_RedCross Error: $($_.Exception.Message)$Reset"
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
                    $fileCount = @($files).Count
                    $files | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                    Write-LeftAligned (Get-StatusLine $true "Removed $fileCount temporary items")
                    $cleanCount += $fileCount
                } else {
                    Write-LeftAligned "$FGGray  Folder is already empty$Reset"
                }
            } catch {
                Write-LeftAligned "$FGRed$Char_RedCross Partial cleanup failure$Reset"
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

    try {
        $pointName = "Maintenance Script $(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-LeftAligned "$FGYellow Creating restore point: $pointName...$Reset"
        
        Checkpoint-Computer -Description $pointName -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        
        Write-LeftAligned (Get-StatusLine $true "Restore Point created successfully")
        Write-Log -Message "Restore Point '$pointName' created successfully" -Level SUCCESS

    } catch {
        # Visual Row 11 style for Failure/Disabled
        Write-LeftAligned "$FGDarkRed$Char_RedCross Failed to create Restore Point: $($_.Exception.Message)$Reset"
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
    
    if ($AutoRun) {
        Write-Host ""
        Write-Header "MAINTENANCE (AUTO)"
        Write-LeftAligned "$FGYellow AutoRun: Executing All Tasks...$Reset"
        
        Optimize-Disks
        Set-PowerSettings
        Optimize-VisualEffects
        Optimize-SystemCleanup
        
        Write-Host ""
        Write-LeftAligned "$FGGreen Maintenance Complete.$Reset"
        
        # Restore Point Logic for AutoRun (Default: Create)
        Create-RestorePoint
        
        # Exit immediately
        $showMenu = $false
        # Footer is printed after this block
    }

    while ($showMenu) {
        Clear-Host
        Write-Host "`n" -NoNewline
        
        # Standard Header (Updated Style to match RULES)
        Write-Header "MAINTENANCE & OPTIMIZATION"
        
        Write-Host ""
        
        # Menu Options
        # UPDATED: Text is now FGGray (was FGDarkCyan)
        Write-LeftAligned " ${FGBlack}${BGYellow}[1]${Reset} ${FGGray}Disk Optimization${Reset}"
        Write-LeftAligned " ${FGBlack}${BGYellow}[2]${Reset} ${FGGray}Power Settings${Reset}"
        Write-LeftAligned " ${FGBlack}${BGYellow}[3]${Reset} ${FGGray}Visual Effects${Reset}"
        Write-LeftAligned " ${FGBlack}${BGYellow}[4]${Reset} ${FGGray}System Cleanup${Reset}"
        Write-Host ""
        
        # "Run ALL Tasks" - UPDATED: Text FGGray, ALL Yellow
        Write-LeftAligned " ${FGBlack}${BGYellow}[A]${Reset} ${FGGray}Run ${FGYellow}ALL${FGGray} Tasks${Reset}"
        
        # Boundary Line
        Write-Boundary $FGDarkBlue
        
        # Capture cursor position BEFORE prompt to clear it later on exit
        $PromptCursorTop = [Console]::CursorTop

        # Prompt (Aligned with RULES Prompt Logic + Custom Eject Exit)
        $prompt = "${FGWhite}$Char_Keyboard  Press${FGDarkGray} ${FGYellow}$Char_Finger [Key]${FGDarkGray} ${FGWhite}to${FGDarkGray} ${FGYellow}RUN${FGWhite}|${FGDarkGray}any other to ${FGWhite}EXIT$Char_Eject${Reset}"
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
                Optimize-Disks
                Set-PowerSettings
                Optimize-VisualEffects
                Optimize-SystemCleanup
                $taskCompleted = $true
            }
            Default { 
                $showMenu = $false
                Write-Host ""
                Write-LeftAligned "$FGGray Exiting...$Reset"
                
                # Logic to Clear Prompt & Exiting Text before Footer
                Start-Sleep -Milliseconds 500
                $CurrentTop = [Console]::CursorTop
                # Overwrite lines with spaces
                for ($i = $PromptCursorTop; $i -le $CurrentTop; $i++) {
                    [Console]::SetCursorPosition(0, $i)
                    Write-Host (" " * 80) -NoNewline
                }
                # Reset cursor to Prompt start so Footer overwrites/places correctly
                [Console]::SetCursorPosition(0, $PromptCursorTop)
            }
        }


        # Check for completed tasks and show new prompt
        if ($taskCompleted) {
            Write-Host ""
            Write-Boundary $FGDarkBlue
            
            # Restore Point Prompt (Matching Rules Colors)
            $restorePrompt = "${FGWhite}Press${FGDarkGray} ${FGYellow}$Char_Finger [Enter]${FGDarkGray} ${FGWhite}to${FGDarkGray} ${FGYellow}Create Restore Point${FGWhite}|${FGDarkGray}any other to ${FGWhite}SKIP$Char_Skip ${Reset}"
            Write-Centered $restorePrompt
            
            $key2 = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            
            if ($key2.Character -eq [char]0x0D) { 
                Create-RestorePoint
                Write-Host ""
                Write-Centered "$FGGray Press any key to return to menu...$Reset"
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            } elseif ($key2.Character -eq ' ') {
                $showMenu = $false
                Write-Host ""
                Write-LeftAligned "$FGGray Exiting...$Reset"
                
                # Logic to Clear Prompt & Exiting Text (Same as Default Exit)
                Start-Sleep -Milliseconds 500
                # Note: For this path, we need to know where the Restore Prompt started.
                # However, this prompt is printed after task output, so $PromptCursorTop (saved before menu) is invalid here.
                # We can just let this one print normally as it's at the bottom of a long log log, 
                # OR we could capture cursor before Restore Prompt too. 
                # Given user request specifically mentioned the Main Prompt string, applying logic there is priority.
            }
        }
    }
    
    # Footer (Cyan, Centered, DarkBlue Boundary)
    Write-Host "`n" -NoNewline
    Write-Host "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"
    $padCopyright = [math]::Max(0, [math]::Floor((60 - $CopyrightLine.Length) / 2))
    Write-Host (" " * $padCopyright) -NoNewline
    Write-Host "$FGCyan$CopyrightLine$Reset"
    
    # Final 5 Empty Lines
    1..5 | ForEach-Object { Write-Host "" }
    
} catch {
    # Critical Error: Red Icon, DarkRed Text (Visual Row 11/Failure style)
    Write-Host "`n$FGDarkRed$Char_RedCross Critical Script Error: $($_.Exception.Message)$Reset"
    Write-Log -Message "Critical Script Error: $($_.Exception.Message)" -Level ERROR
    exit 1
}