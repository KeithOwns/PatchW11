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
$FGGreen      = "$Esc[92m"
$FGDarkRed    = "$Esc[31m"
$FGRed        = "$Esc[91m"
$FGDarkYellow = "$Esc[33m"
$FGYellow     = "$Esc[93m"
$FGDarkMagenta= "$Esc[35m"
$FGBlack      = "$Esc[30m"

# Background Colors
$BGDarkCyan   = "$Esc[46m"
$BGDarkGreen  = "$Esc[42m"
$BGGreen      = "$Esc[102m" 
$BGDarkGray   = "$Esc[100m"
$BGYellow     = "$Esc[103m"

# Icons
$Char_HeavyLine   = [char]0x2501
$Char_LightLine   = [char]0x2500
$Char_HeavyMinus  = [char]0x2796
$Char_Hyphen      = [char]0x002D
$Char_EmDash      = [char]0x2014
$Char_EnDash      = [char]0x2013
$Char_BallotCheck = [char]0x2611
$Char_HeavyCheck  = [char]0x2705
$Char_XSquare     = [char]0x26DD
$Char_RedCross    = [char]0x274E
$Char_Warn        = [char]0x26A0
$Char_Finger      = [char]0x261B
$Char_Keyboard    = [char]0x2328
$Char_Skip        = [char]0x23ED
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504)
$Char_Copyright   = [char]0x00A9
$Char_Speaker     = [char]::ConvertFromUtf32(0x1F4E2)
$Char_BlackCircle = [char]0x26AB
$Char_Gear        = [char]0x2699
$Char_Bell        = [char]::ConvertFromUtf32(0x1F514)
$Char_Stopwatch   = [char]::ConvertFromUtf32(0x23F1)
$Char_User        = [char]::ConvertFromUtf32(0x1F464)

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
        [string]$ActiveColor = "$BGDarkGreen"
    )
    
    $LeftDisplay = "$FGGray$LeftIcon $FGGray$LeftText$Reset"
    $LeftRaw = "$LeftIcon $LeftText"
    
    if ($IsActive) {
        $RightDisplay = "$ActiveColor   $Reset$BGDarkGray$FGGray$RightText$Reset "
        $RightRaw = "   $RightText " 
    } else {
        $RightDisplay = "$FGDarkRed$Char_RedCross $FGGray Off$Reset"
        $RightRaw = "$Char_RedCross  Off"
    }

    $SpaceCount = $Width - ($LeftRaw.Length + $RightRaw.Length + 3) - 1
    if ($SpaceCount -lt 1) { $SpaceCount = 1 }
    
    Write-Host ("   " + $LeftDisplay + (" " * $SpaceCount) + $RightDisplay)
}

function Write-TopHeader {
    Write-Host ""
    $TitleText = " $Char_HeavyLine PatchW11 $Char_HeavyLine "
    Write-Centered $TitleText -Color "$Bold$FGCyan"
    Write-Centered "WINDOWS UPDATE CONFIGURATOR" -Color "$Bold$FGCyan"
    Write-Host "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"
}

function Write-BodyTitle {
    param([string]$Title)
    Write-LeftAligned "$FGWhite$Char_HeavyMinus $Bold$Title$Reset"
}

function Write-Boundary {
    param([string]$Color = $FGDarkBlue)
    Write-Host "$Color$([string]$Char_HeavyLine * 60)$Reset"
}

function Get-StatusLine {
    param([bool]$IsEnabled, [string]$Text)
    if ($IsEnabled) { return "$FGDarkGreen$Char_BallotCheck  $FGGray$Text$Reset" } 
    else { return "$FGDarkRed$Char_RedCross $FGGray$Text$Reset" }
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
    Write-Host "$FGDarkGray$([string]$Char_LightLine * 60)$Reset"
    Write-Centered $Title -Color "$Bold$FGCyan"
}

function Show-WUStatus {
    Write-Boundary $FGDarkGray

    Write-Host " $Bold$FGWhite Windows Update$Reset"
    
    $status_WindowsUpdate = "Updates available"
    $status_Color = $FGDarkYellow
    $status_Icon = $Char_Warn
    $LastSearchStr = "Unknown"
    
    # Defaults
    $iconColor = $Char_Warn
    $timestampColor = $FGGray
    
    try {
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        $UpdateSearcher.Online = $false
        
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0")
        if ($SearchResult.Updates.Count -eq 0) {
            $status_WindowsUpdate = "You're up to date"
            $status_Color = $FGWhite
            $status_Icon = $Char_Loop
        }
        
        $AutoUpdate = New-Object -ComObject Microsoft.Update.AutoUpdate
        $LastSearch = $AutoUpdate.Results.LastSearchSuccessDate
        
        if ($LastSearch) {
             $LastSearchStr = $LastSearch.ToString()
             
             # Calculate 48 Hour Logic
             $TimeDiff = (Get-Date) - $LastSearch
             if ($TimeDiff.TotalHours -lt 48) {
                 # < 48h: DarkGreen
                 $iconColor = $FGDarkGreen
                 $timestampColor = $FGDarkGreen
             } else {
                 # > 48h: DarkRed
                 $iconColor = $FGDarkRed
                 $timestampColor = $FGDarkRed
             }
        }
    } catch {
        $status_WindowsUpdate = "Check status failed"
        $status_Color = $FGDarkRed
        $status_Icon = $Char_XSquare
    }
    
    Write-Host ""
    
    # --- CHANGED: Updates Available Logic ---
    if ($status_WindowsUpdate -eq "Updates available") {
        # Updates found: Print in DarkYellow and HIDE 'Last checked'
        Write-LeftAligned "$FGDarkYellow$Char_Warn $FGDarkYellow$status_WindowsUpdate$Reset"
    }
    else {
        # Updates NOT found (or check failed): Use standard logic + 'Last checked'
        Write-LeftAligned "$iconColor$status_Icon $status_Color$status_WindowsUpdate$Reset"
        Write-LeftAligned "$FGGray Last checked: $timestampColor$LastSearchStr$Reset"
    }
    # ----------------------------------------
    
    Write-Log -Message "Starting Windows Update status check" -Level INFO

    Write-Host ""
    Write-LeftAligned "$Bold$FGWhite More options$Reset"
    
    $continuous = Get-RegistryValue -Path $WU_UX -Name "IsContinuousInnovationOptedIn"
    
    Write-FlexLine -LeftIcon $Char_Speaker -LeftText "Get latest updates as soon as possible" -RightText "On" -IsActive ($continuous -eq 1) -ActiveColor $BGDarkGreen

    Write-Host ""
    Write-LeftAligned "$Bold$FGWhite$Char_Gear  Advanced options $Reset"
    
    $mu = Get-RegistryValue -Path $WU_UX  -Name "AllowMUUpdateService"
    Write-FlexLine -LeftIcon $Char_Loop -LeftText "Receive updates for other Microsoft products" -RightText "On" -IsActive ($mu -eq 1)

    $restartNotify = Get-RegistryValue -Path $WU_UX -Name "RestartNotificationsAllowed2"
    Write-FlexLine -LeftIcon $Char_Bell -LeftText "Notify me when a restart is required" -RightText "On" -IsActive ($restartNotify -eq 1)

    $ahs = Get-RegistryValue -Path $WU_UX -Name "ActiveHoursStart"
    $ahe = Get-RegistryValue -Path $WU_UX -Name "ActiveHoursEnd"
    if ($ahs -ne $null -and $ahe -ne $null) {
        Write-LeftAligned "$FGGray$Char_Stopwatch $FGGray Active hours: ${ahs}:00 - ${ahe}:00$Reset" -Indent 3
    } else {
        Write-LeftAligned "$FGGray$Char_Stopwatch $FGGray Active hours: Auto$Reset" -Indent 3
    }
    
    Write-Host ""
    Write-LeftAligned "$Bold$FGWhite$Char_User Accounts >  Sign-in options$Reset"
    
    $restartApps = Get-RegistryValue -Path $WINLOGON_USER -Name "RestartApps"
    Write-FlexLine -LeftIcon ">" -LeftText "Automatically save restartable apps" -RightText "On" -IsActive ($restartApps -eq 1)
    
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

    Write-Host ""
    Write-Boundary $FGDarkGray
}

function Set-WUSettings {
    try {
        Write-Log -Message "Applying Windows Update configurations" -Level INFO
        Set-RegistryDword -Path $WU_UX -Name "IsContinuousInnovationOptedIn" -Value 1
        Set-RegistryDword -Path $WU_UX -Name "AllowMUUpdateService" -Value 1
        Set-RegistryDword -Path $WU_UX -Name "RestartNotificationsAllowed2" -Value 1
        
        try {
            Set-RegistryDword -Path $WINLOGON_USER -Name "RestartApps" -Value 1
            $policyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            $policyName = "DisableAutomaticRestartSignOn"
            $policyValue = Get-RegistryValue -Path $policyPath -Name $policyName

            if ($null -ne $policyValue -and $policyValue -eq 1) {
                Write-Log -Message "ARSO blocked by policy" -Level WARNING
            } else {
                $UserSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
                if (-not $UserSID) { throw "Could not determine current user's SID." }
                $userArsoPath = "$WINLOGON_MACHINE\UserARSO\$UserSID"
                Set-RegistryDword -Path $WINLOGON_MACHINE -Name "ARSOUserConsent" -Value 1
                if (-not (Test-Path $userArsoPath)) { New-Item -Path $userArsoPath -Force -ErrorAction Stop | Out-Null }
                Set-RegistryDword -Path $userArsoPath -Name "OptOut" -Value 0
            }
        } catch {
             Write-Log -Message "Failed to set user sign-in options: $($_.Exception.Message)" -Level ERROR
        }
    }
    catch {
        Write-Log -Message "Error applying settings: $($_.Exception.Message)" -Level ERROR
    }
}

function Invoke-COMUpdateCheck {
    Write-Host ""
    Write-Host "$FGDarkGray$([string]$Char_LightLine * 60)$Reset"
    Write-Centered "$Char_EnDash Update SEARCH (COM) $Char_EnDash" -Color "$Bold$FGCyan"
    Write-Host ""

    try {
        Write-LeftAligned "$FGGray Contacting Windows Update Service...$Reset"
        Write-Log -Message "Initializing COM Update Searcher" -Level INFO
        
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0")
        $PendingUpdates = $SearchResult.Updates.Count
        
        if ($PendingUpdates -eq 0) {
            Write-LeftAligned "$FGGreen$Char_HeavyCheck System is up to date.$Reset"
            Write-Log -Message "COM Search: No updates found" -Level SUCCESS
        } else {
            Write-LeftAligned "$FGDarkYellow$Char_Warn Updates available: $PendingUpdates$Reset"
            Write-Log -Message "COM Search: $PendingUpdates updates found" -Level INFO
            
            Write-Host ""
            Write-BodyTitle "Available updates"
            foreach ($Update in $SearchResult.Updates) {
                Write-LeftAligned "  $Char_Finger $($Update.Title)"
                Write-Log -Message "Available: $($Update.Title)" -Level INFO
            }
        }
        
    } catch {
        Write-LeftAligned "$FGRed$Char_RedCross Error checking status: $($_.Exception.Message)$Reset"
        Write-Log -Message "COM Check Error: $($_.Exception.Message)" -Level ERROR
    }
}

function Invoke-MSStoreUpdateCheck {
    Write-Host "$FGDarkGray$([string]$Char_LightLine * 60)$Reset"
    Write-Centered "$Char_EnDash Microsoft Store CHECK $Char_EnDash" -Color "$Bold$FGCyan"
    Write-Host ""

    try {
        Add-Type -AssemblyName UIAutomationClient
        Add-Type -AssemblyName UIAutomationTypes
    } catch {
        Write-LeftAligned "$FGRed$Char_RedCross Failed to load UI Automation assemblies$Reset"
        Write-Log -Message "Failed to load UI Automation assemblies" -Level ERROR
        return
    }

    Write-LeftAligned "$FGGray Opening Microsoft Store to check for app updates...$Reset"
    Write-Log -Message "Attempting to open Microsoft Store for updates" -Level INFO
    Start-Process "ms-windows-store://downloadsandupdates"
    
    # RESTORED: Name-based logic
    $buttonTexts = @("Get updates", "Check for updates", "Update all")
    
    # Start loop for wait
    $timeout = 10
    $startTime = Get-Date
    $storeWindow = $null
    
    do {
        $desktop = [System.Windows.Automation.AutomationElement]::RootElement
        $condition = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, "Microsoft Store")
        $storeWindow = $desktop.FindFirst([System.Windows.Automation.TreeScope]::Children, $condition)
        if ($storeWindow -ne $null) { break }
        Start-Sleep -Milliseconds 500
    } while ((Get-Date) -lt $startTime.AddSeconds($timeout))

    if ($storeWindow -eq $null) {
        Write-LeftAligned "$FGRed$Char_RedCross Could not find Microsoft Store window$Reset"
        Write-Log -Message "Microsoft Store window not found" -Level WARNING
        return
    }
    
    Start-Sleep -Seconds 2
    
    $buttonFound = $false
    foreach ($buttonText in $buttonTexts) {
        $buttonCondition = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, $buttonText)
        $button = $storeWindow.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $buttonCondition)
        
        if ($button -ne $null) {
            $invokePattern = $button.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
            if ($invokePattern -ne $null) {
                $invokePattern.Invoke()
                Write-LeftAligned "$FGGreen$Char_HeavyCheck Successfully clicked '$buttonText'$Reset"
                $buttonFound = $true
                break
            }
        }
    }
    
    if (-not $buttonFound) {
        Write-LeftAligned "$FGDarkYellow$Char_Warn Could not find update button$Reset"
        Write-Log -Message "Could not find update button in Store" -Level WARNING
    }
    
    trap {
        Write-LeftAligned "$FGRed$Char_RedCross UI Automation Error$Reset"
        Write-Log -Message "UI Automation Error in Store: $($_.Exception.Message)" -Level ERROR
        continue
    }
}

function Invoke-WinUpdateCheck {
    Write-Host "$FGDarkGray$([string]$Char_LightLine * 60)$Reset"
    Write-Centered "$Char_EnDash Windows Update CHECK $Char_EnDash" -Color "$Bold$FGCyan"
    Write-Host ""

    try {
        Add-Type -AssemblyName UIAutomationClient
        Add-Type -AssemblyName UIAutomationTypes
    } catch {
        Write-LeftAligned "$FGRed$Char_RedCross Failed to load UI Automation assemblies$Reset"
        return
    }

    Write-LeftAligned "$FGGray Opening Windows Update settings...$Reset"
    Write-Log -Message "Attempting to open Windows Update settings" -Level INFO
    Start-Process "ms-settings:windowsupdate"
    
    # RESTORED: Name-based logic
    $targetButtons = @("Check for updates", "Download & install all", "Install all", "Restart now")
    
    $timeout = 10
    $startTime = Get-Date
    $settingsWindow = $null
    
    do {
        $desktop = [System.Windows.Automation.AutomationElement]::RootElement
        $condition = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, "Settings")
        $settingsWindow = $desktop.FindFirst([System.Windows.Automation.TreeScope]::Children, $condition)
        if ($settingsWindow -ne $null) { break }
        Start-Sleep -Milliseconds 500
    } while ((Get-Date) -lt $startTime.AddSeconds($timeout))
    
    if ($settingsWindow -eq $null) {
        Write-LeftAligned "$FGRed$Char_RedCross Could not find Settings window$Reset"
        Write-Log -Message "Settings window not found" -Level WARNING
        return
    }
    
    Start-Sleep -Seconds 2
    
    $buttonFound = $false
    foreach ($text in $targetButtons) {
        $buttonCondition = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, $text)
        $button = $settingsWindow.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $buttonCondition)
        
        if ($button -ne $null) {
            $invokePattern = $button.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
            if ($invokePattern -ne $null) {
                $invokePattern.Invoke()
                Write-LeftAligned "$FGGreen$Char_HeavyCheck Successfully clicked '$text'$Reset"
                $buttonFound = $true
                break
            }
        }
    }
    
    if (-not $buttonFound) {
            Write-LeftAligned "$FGDarkYellow$Char_Warn Could not find update buttons$Reset"
            Write-Log -Message "Could not find update buttons in Settings" -Level WARNING
    }
    
    trap {
        Write-LeftAligned "$FGRed$Char_RedCross UI Automation Error$Reset"
        Write-Log -Message "UI Automation Error in Settings: $($_.Exception.Message)" -Level ERROR
        continue
    }
}

# --- Main ---
Write-TopHeader
Set-WUSettings
Show-WUStatus

# --- User Prompt ---
Write-Host ""
$prompt = "${FGWhite}$Char_Keyboard  Press${FGDarkGray} ${FGYellow}$Char_Finger [Enter]${FGDarkGray} ${FGWhite}to${FGDarkGray} ${FGYellow}RUN Checks${FGWhite}|${FGDarkGray}any other to ${FGWhite}SKIP$Char_Skip ${Reset}"

# Capture cursor position for UI cleanup
$PromptCursorTop = [Console]::CursorTop

Write-Centered $prompt

$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# --- UI Cleanup: Clear Prompt ---
try {
    Start-Sleep -Milliseconds 200 # Slight delay for UX
    $CurrentTop = [Console]::CursorTop
    # Overwrite prompt lines with spaces
    for ($i = $PromptCursorTop; $i -le $CurrentTop; $i++) {
        [Console]::SetCursorPosition(0, $i)
        Write-Host (" " * 80) -NoNewline
    }
    # Reset cursor to start of prompt
    [Console]::SetCursorPosition(0, $PromptCursorTop)
} catch {
    # Fallback if console manipulation fails
    Write-Host ""
}
# --------------------------------

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
Write-Host ""
Write-Host ""
Write-Boundary $FGDarkBlue
Write-Centered "$FGCyan$Char_Copyright 2025, www.AIIT.support. All Rights Reserved.$Reset"

# Exit Spacing
1..5 | ForEach-Object { Write-Host "" }