#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- [USER PREFERENCE] CLEAR SCREEN START ---
Clear-Host
# --------------------------------------------

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
$FGGreen      = "$Esc[92m"  # Added for Script Success
$FGDarkRed    = "$Esc[31m"
$FGRed        = "$Esc[91m"  # Added for Script Failure
$FGDarkYellow = "$Esc[33m"
$FGYellow     = "$Esc[93m"
$FGDarkMagenta= "$Esc[35m"
$FGBlack      = "$Esc[30m"  # Added for Prompt Contrast

# Background Colors
$BGDarkCyan   = "$Esc[46m"
$BGDarkGreen  = "$Esc[42m"
$BGGreen      = "$Esc[102m" 
$BGDarkGray   = "$Esc[100m"
$BGYellow     = "$Esc[103m" # Added for Prompt Keys

# Icons
$Char_EmDash      = [char]0x2014
$Char_EnDash      = [char]0x2013 # Added for Body Titles
$Char_BallotCheck = [char]0x2611 # ☑
$Char_HeavyCheck  = [char]0x2705 # ✅ - Added for Script Success
$Char_XSquare     = [char]0x26DD # ⛝ - Updated per Rules v7.83
$Char_RedCross    = [char]0x274E # ❎ - Added for Script Failure
$Char_Warn        = [char]0x26A0 # ⚠
$Char_Finger      = [char]0x261B # ☛
$Char_Keyboard    = [char]0x2328 # ⌨
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504)
$Char_Copyright   = [char]0x00A9
$Char_Speaker     = [char]::ConvertFromUtf32(0x1F4E2) # 📢
$Char_BlackCircle = [char]0x26AB # ⚫
$Char_Gear        = [char]0x2699 # ⚙
$Char_Bell        = [char]::ConvertFromUtf32(0x1F514) # 🔔
$Char_Stopwatch   = [char]::ConvertFromUtf32(0x23F1)  # ⏱
$Char_User        = [char]::ConvertFromUtf32(0x1F464) # 👤

# Global Logging Variables
$script:LogPath = "C:\Windows\Temp\Update_$(Get-Date -Format 'yyMMdd').log"

# --- Unified Helper Functions ---

function Write-Centered {
    param([string]$Text, [int]$Width = 60, [string]$Color = "")
    $cleanText = $Text -replace "$Esc\[[0-9;]*m", ""
    $padLeft = [Math]::Floor(($Width - $cleanText.Length) / 2)
    if ($padLeft -lt 0) { $padLeft = 0 }
    Write-Host (" " * $padLeft + $Color + $Text + $Reset)
}

function Write-LeftAligned {
    param([string]$Text, [int]$Indent = 2)
    Write-Host (" " * $Indent + $Text)
}

function Write-FlexLine {
    param(
        [string]$LeftIcon,
        [string]$LeftText,
        [string]$RightText,
        [bool]$IsActive,
        [int]$Width = 60,
        [string]$ActiveColor = "$BGDarkGreen" # Default to DarkGreen, can override
    )
    
    # Construct Left Side (Icon + Text)
    # Left side (Icon and Text) Gray ($FGGray)
    $LeftDisplay = "$FGGray$LeftIcon $FGGray$LeftText$Reset"
    $LeftRaw = "$LeftIcon $LeftText"
    
    # Construct Right Side based on Active state
    if ($IsActive) {
        # Active: "On"
        # Toggle: "   " (3 spaces) where ALL 3 spaces have Bg color (ActiveColor)
        # Visual: [ActiveColor]   [Reset][DarkGrayBG]On[Reset][NormalSpace]
        $RightDisplay = "$ActiveColor   $Reset$BGDarkGray$FGGray$RightText$Reset "
        $RightRaw = "   $RightText " 
    } else {
        # Inactive: Standard Red Cross format
        $RightDisplay = "$FGDarkRed$Char_XSquare $FGDarkCyan Off$Reset"
        $RightRaw = "$Char_XSquare  Off"
    }

    # Calculate Spacing
    # REQ: Revert indent change. (Move back to right by 1 space).
    # PREV Formula (Left Shifted): $Width - ($LeftRaw.Length + $RightRaw.Length + 3) - 2
    # NEW Formula (Reverted): $Width - ($LeftRaw.Length + $RightRaw.Length + 3) - 1
    
    $SpaceCount = $Width - ($LeftRaw.Length + $RightRaw.Length + 3) - 1
    if ($SpaceCount -lt 1) { $SpaceCount = 1 }
    
    # Leading indent string is 3 spaces "   "
    Write-Host ("   " + $LeftDisplay + (" " * $SpaceCount) + $RightDisplay)
}

function Write-TopHeader {
    Write-Host ""
    
    # REVERTED: Patch-W11 on top (Cyan) - Added back
    $TitleText = "$Char_Loop Patch-W11"
    Write-Centered $TitleText -Color "$Bold$FGCyan"

    # UPDATED: Configurator line below (DarkCyan)
    Write-Centered "$Char_EmDash$Char_EmDash WINDOWS UPDATE CONFIGURATOR $Char_EmDash$Char_EmDash" -Color "$Bold$FGDarkCyan"
    
    # User requested removing the DarkBlue boundary here ("...remove the Fg DarkBlue Boundary...")
    # The first boundary (below this header) is usually kept, but the prompt implies removal of a specific line.
    # However, "except for the first and last Boundary" implies there SHOULD be a first boundary.
    # "Change the color of each Boundary line, except for the first and last Boundary to Fg DarkGray"
    # So the line BELOW this header is the "First" boundary. It stays DarkBlue.
    Write-Host "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"
}

function Write-BodyTitle {
    param([string]$Title)
    # Rules v7.83 use EnDash for Body Titles
    Write-LeftAligned "$Bold$FGWhite$Char_EnDash$Char_EnDash $Title $Char_EnDash$Char_EnDash$Reset"
}

function Write-Boundary {
    param([string]$Color = $FGDarkBlue)
    Write-Host "$Color$([string]$Char_EmDash * 60)$Reset"
}

function Get-StatusLine {
    param([bool]$IsEnabled, [string]$Text)
    if ($IsEnabled) { return "$FGDarkGreen$Char_BallotCheck  $FGDarkCyan$Text$Reset" } 
    else { return "$FGDarkRed$Char_XSquare $FGDarkCyan$Text$Reset" }
}

# --- Logging & Registry Functions ---

function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','WARNING','ERROR','SUCCESS')][string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -Path $script:LogPath -Value "[$timestamp] [$Level] $Message" -ErrorAction SilentlyContinue
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
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
        Write-Log -Message "Set registry: $Path\$Name = $Value" -Level SUCCESS
    } catch {
        Write-Log -Message "Failed to set registry: $Path\$Name - $($_.Exception.Message)" -Level ERROR
        throw $_ 
    }
}

# Registry Paths
$WU_UX  = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
$WU_POL = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$WINLOGON_USER = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" 
$WINLOGON_MACHINE = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

function Write-Header {
    param([string]$Title)
    # UPDATED: Section Headers use DarkGray for the top line
    Write-Host "$FGDarkGray$([string]$Char_EmDash * 60)$Reset"
    Write-Centered $Title -Color "$Bold$FGCyan"
    # No bottom boundary
}

function Show-WUStatus {
    # UPDATED: Empty line before Title, Title indented 2 spaces
    Write-Host ""
    Write-Host "  $Bold$FGWhite Windows Update$Reset"
    
    # --- Status Check (Moved to Top) ---
    $status_WindowsUpdate = "Updates available"
    $status_Color = $FGDarkYellow
    $status_Icon = $Char_Warn
    $LastSearchStr = "Unknown"
    
    try {
        # Quick check using COM
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        $UpdateSearcher.Online = $false # Try offline first for speed
        
        # Get count
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0")
        if ($SearchResult.Updates.Count -eq 0) {
            $status_WindowsUpdate = "You're up to date"
            # UPDATED: Fg White for "You're up to date" (and Icon)
            $status_Color = $FGWhite
            $status_Icon = $Char_Loop
        }
        
        # Get Last Search Time
        $AutoUpdate = New-Object -ComObject Microsoft.Update.AutoUpdate
        $LastSearch = $AutoUpdate.Results.LastSearchSuccessDate
        if ($LastSearch) {
             $LastSearchStr = $LastSearch.ToString()
        }
    } catch {
        $status_WindowsUpdate = "Check status failed"
        $status_Color = $FGDarkRed
        $status_Icon = $Char_XSquare
    }
    
    # Print Status immediately below header
    Write-Host ""
    Write-LeftAligned "$status_Color$status_Icon $status_WindowsUpdate$Reset"
    Write-LeftAligned "$FGGray Last checked: $LastSearchStr$Reset"
    
    Write-Log -Message "Starting Windows Update status check" -Level INFO

    Write-Host ""
    # UPDATED: Changed > More options to Just More options, White
    Write-LeftAligned "$Bold$FGWhite More options$Reset"
    
    $continuous = Get-RegistryValue -Path $WU_UX -Name "IsContinuousInnovationOptedIn"
    
    # 1. Get latest updates (Speaker Icon) - Gray, 3-space indent
    # UPDATED: First toggle uses DarkGreen ($BGDarkGreen)
    Write-FlexLine -LeftIcon $Char_Speaker -LeftText "Get latest updates as soon as possible" -RightText "On" -IsActive ($continuous -eq 1) -ActiveColor $BGDarkGreen

    Write-Host ""
    # Title Changed: Icon + Text (No dashes), removed leading space, White
    Write-LeftAligned "$Bold$FGWhite$Char_Gear  Advanced options $Reset"
    
    # 2. Receive updates (Loop Icon) - Gray, 3-space indent
    # Uses default DarkGreen
    $mu = Get-RegistryValue -Path $WU_UX  -Name "AllowMUUpdateService"
    Write-FlexLine -LeftIcon $Char_Loop -LeftText "Receive updates for other Microsoft products" -RightText "On" -IsActive ($mu -eq 1)

    # 3. Notify me (Bell Icon) - Gray, 3-space indent
    $restartNotify = Get-RegistryValue -Path $WU_UX -Name "RestartNotificationsAllowed2"
    Write-FlexLine -LeftIcon $Char_Bell -LeftText "Notify me when a restart is required" -RightText "On" -IsActive ($restartNotify -eq 1)

    # 4. Active hours (Stopwatch Icon)
    # UPDATED: Stopwatch icon is Gray. Indentation increased to 3 (Indent=3).
    $ahs = Get-RegistryValue -Path $WU_UX -Name "ActiveHoursStart"
    $ahe = Get-RegistryValue -Path $WU_UX -Name "ActiveHoursEnd"
    if ($ahs -ne $null -and $ahe -ne $null) {
        Write-LeftAligned "$FGGray$Char_Stopwatch $FGGray Active hours: ${ahs}:00 - ${ahe}:00$Reset" -Indent 3
    } else {
        Write-LeftAligned "$FGGray$Char_Stopwatch $FGGray Active hours: Auto$Reset" -Indent 3
    }
    
    Write-Host ""
    # Title Changed: Accounts > Sign-in options, White
    Write-LeftAligned "$Bold$FGWhite$Char_User Accounts >  Sign-in options$Reset"
    
    # 5. Automatically save restartable apps - Gray, 3-space indent
    $restartApps = Get-RegistryValue -Path $WINLOGON_USER -Name "RestartApps"
    Write-FlexLine -LeftIcon ">" -LeftText "Automatically save restartable apps" -RightText "On" -IsActive ($restartApps -eq 1)
    
    # 6. Use sign-in info - Gray, 3-space indent
    $arsoEnabled = $false
    try {
        $UserSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        if ($UserSID) {
            $userArsoPath = "$WINLOGON_MACHINE\UserARSO\$UserSID"
            $optOut = Get-RegistryValue -Path $userArsoPath -Name "OptOut"
            $arsoEnabled = ($optOut -ne $null -and $optOut -eq 0)
        }
    } catch { $arsoEnabled = $false }
    
    Write-FlexLine -LeftIcon ">" -LeftText "Use sign-in info to finish setup after update" -RightText "On" -IsActive $arsoEnabled

    # Current Status section removed from bottom

    Write-Host ""
    # Middle Boundary changed to DarkGray
    Write-Boundary $FGDarkGray
}

function Invoke-COMUpdateCheck {
    # UPDATED: Standardized Check Format
    # Boundary (DarkGray) -> Header -> Empty Line -> Content
    Write-Host "$FGDarkGray$([string]$Char_EmDash * 60)$Reset"
    Write-Centered "$Char_EnDash Update SEARCH (COM) $Char_EnDash" -Color "$Bold$FGCyan"
    Write-Host ""

    try {
        # STATUS Text: Gray
        Write-LeftAligned "$FGGray Contacting Windows Update Service...$Reset"
        Write-Log -Message "Initializing COM Update Searcher" -Level INFO
        
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0")
        $PendingUpdates = $SearchResult.Updates.Count
        
        if ($PendingUpdates -eq 0) {
            # SUCCESS: Green + HeavyCheck
            Write-LeftAligned "$FGGreen$Char_HeavyCheck System is up to date.$Reset"
            Write-Log -Message "COM Search: No updates found" -Level SUCCESS
        } else {
            # WARNING/INFO: DarkYellow
            Write-LeftAligned "$FGDarkYellow$Char_Warn Updates available: $PendingUpdates$Reset"
            Write-Log -Message "COM Search: $PendingUpdates updates found" -Level INFO
            
            Write-Host ""
            # TITLE: Body Title Format (White with EnDashes)
            Write-BodyTitle "Available updates"
            foreach ($Update in $SearchResult.Updates) {
                # CONTENT: Gray
                Write-LeftAligned "  $Char_Finger $($Update.Title)"
                Write-Log -Message "Available: $($Update.Title)" -Level INFO
            }
        }
        
        $TotalHistory = $UpdateSearcher.GetTotalHistoryCount()
        
    } catch {
        # FAILURE: Red + RedCross
        Write-LeftAligned "$FGRed$Char_RedCross Error checking status: $($_.Exception.Message)$Reset"
        Write-Log -Message "COM Check Error: $($_.Exception.Message)" -Level ERROR
    }
}

function Invoke-MSStoreUpdateCheck {
    # UPDATED: Standardized Check Format
    # Boundary (DarkGray) -> Header -> Empty Line -> Content
    Write-Host "$FGDarkGray$([string]$Char_EmDash * 60)$Reset"
    Write-Centered "$Char_EnDash Microsoft Store CHECK $Char_EnDash" -Color "$Bold$FGCyan"
    Write-Host ""

    try {
        Add-Type -AssemblyName UIAutomationClient
        Add-Type -AssemblyName UIAutomationTypes
    } catch {
        # FAILURE: Red + RedCross
        Write-LeftAligned "$FGRed$Char_RedCross Failed to load UI Automation assemblies$Reset"
        Write-Log -Message "Failed to load UI Automation assemblies" -Level ERROR
        return
    }

    # STATUS: Gray
    Write-LeftAligned "$FGGray Opening Microsoft Store to check for app updates...$Reset"
    Write-Log -Message "Attempting to open Microsoft Store for updates" -Level INFO
    Start-Process "ms-windows-store://downloadsandupdates"
    Start-Sleep -Seconds 5

    try {
        $desktop = [System.Windows.Automation.AutomationElement]::RootElement
        $condition = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, "Microsoft Store")
        $storeWindow = $desktop.FindFirst([System.Windows.Automation.TreeScope]::Children, $condition)
        
        if ($storeWindow -eq $null) {
            # FAILURE: Red + RedCross
            Write-LeftAligned "$FGRed$Char_RedCross Could not find Microsoft Store window$Reset"
            Write-Log -Message "Microsoft Store window not found" -Level WARNING
            return
        }
        
        Start-Sleep -Seconds 5
        
        $buttonTexts = @("Get updates", "Check for updates", "Update all")
        $buttonFound = $false
        
        foreach ($buttonText in $buttonTexts) {
            $buttonCondition = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, $buttonText)
            $button = $storeWindow.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $buttonCondition)
            
            if ($button -ne $null) {
                $invokePattern = $button.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
                if ($invokePattern -ne $null) {
                    $invokePattern.Invoke()
                    # SUCCESS: Green + HeavyCheck
                    Write-LeftAligned "$FGGreen$Char_HeavyCheck Successfully clicked '$buttonText'$Reset"
                    $buttonFound = $true
                    break
                }
            }
        }
        
        if (-not $buttonFound) {
            # WARNING: DarkYellow
            Write-LeftAligned "$FGDarkYellow$Char_Warn Could not find update button$Reset"
            Write-Log -Message "Could not find update button in Store" -Level WARNING
        }
        
    } catch {
        # FAILURE: Red + RedCross
        Write-LeftAligned "$FGRed$Char_RedCross UI Automation Error$Reset"
        Write-Log -Message "UI Automation Error in Store: $($_.Exception.Message)" -Level ERROR
    }
}

function Invoke-WinUpdateCheck {
    # UPDATED: Standardized Check Format
    # Boundary (DarkGray) -> Header -> Empty Line -> Content
    Write-Host "$FGDarkGray$([string]$Char_EmDash * 60)$Reset"
    Write-Centered "$Char_EnDash Windows Update CHECK $Char_EnDash" -Color "$Bold$FGCyan"
    Write-Host ""

    try {
        Add-Type -AssemblyName UIAutomationClient
        Add-Type -AssemblyName UIAutomationTypes
    } catch {
        # FAILURE: Red + RedCross
        Write-LeftAligned "$FGRed$Char_RedCross Failed to load UI Automation assemblies$Reset"
        return
    }

    # STATUS: Gray
    Write-LeftAligned "$FGGray Opening Windows Update settings...$Reset"
    Write-Log -Message "Attempting to open Windows Update settings" -Level INFO
    Start-Process "ms-settings:windowsupdate"
    Start-Sleep -Seconds 5

    try {
        $desktop = [System.Windows.Automation.AutomationElement]::RootElement
        $condition = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, "Settings")
        $settingsWindow = $desktop.FindFirst([System.Windows.Automation.TreeScope]::Children, $condition)
        
        if ($settingsWindow -eq $null) {
            # FAILURE: Red + RedCross
            Write-LeftAligned "$FGRed$Char_RedCross Could not find Settings window$Reset"
            Write-Log -Message "Settings window not found" -Level WARNING
            return
        }
        
        Start-Sleep -Seconds 2
        
        $targetButtons = @("Check for updates", "Download & install all")
        $buttonFound = $false
        
        foreach ($text in $targetButtons) {
            $buttonCondition = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, $text)
            $button = $settingsWindow.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $buttonCondition)
            
            if ($button -ne $null) {
                $invokePattern = $button.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
                if ($invokePattern -ne $null) {
                    $invokePattern.Invoke()
                    # SUCCESS: Green + HeavyCheck
                    Write-LeftAligned "$FGGreen$Char_HeavyCheck Successfully clicked '$text'$Reset"
                    $buttonFound = $true
                    break
                }
            }
        }
        
        if (-not $buttonFound) {
             # WARNING: DarkYellow
             Write-LeftAligned "$FGDarkYellow$Char_Warn Could not find update buttons$Reset"
             Write-Log -Message "Could not find update buttons in Settings" -Level WARNING
        }
        
    } catch {
        # FAILURE: Red + RedCross
        Write-LeftAligned "$FGRed$Char_RedCross UI Automation Error$Reset"
        Write-Log -Message "UI Automation Error in Settings: $($_.Exception.Message)" -Level ERROR
    }
}

# --- Main ---
Write-TopHeader
Set-WUSettings
Show-WUStatus

# --- User Prompt ---
Write-Host ""
# UPDATED: Prompt logic updated to match Rules v7.83 (Finger Yellow, Key Name Black on Yellow)
$prompt = "${FGDarkCyan}$Char_Keyboard  ${FGYellow}Press ${FGYellow}$Char_Finger ${FGBlack}${BGYellow}Enter${Reset}${FGDarkCyan} to Run Checks  |  Press ${FGYellow}$Char_Finger ${FGBlack}${BGYellow}Spacebar${Reset}${FGDarkCyan} to Skip$Reset"
Write-Centered $prompt

do {
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} while ($key.VirtualKeyCode -ne 13 -and $key.Character -ne ' ')

if ($key.VirtualKeyCode -eq 13) {
    Invoke-COMUpdateCheck
    Invoke-MSStoreUpdateCheck
    Invoke-WinUpdateCheck
} else {
    Write-Host ""
    Write-LeftAligned "$FGGray Skipping update checks.$Reset"
    Write-Log -Message "User skipped update checks" -Level INFO
}

# Footer
# UPDATED: Two empty lines before Footer Boundary
Write-Host ""
Write-Host ""
# UPDATED: DarkBlue separator above footer
Write-Boundary $FGDarkBlue
# UPDATED: Cyan Footer text
Write-Centered "$FGCyan$Char_Copyright 2025, www.AIIT.support. All Rights Reserved.$Reset"

# Exit Spacing
1..5 | ForEach-Object { Write-Host "" }
