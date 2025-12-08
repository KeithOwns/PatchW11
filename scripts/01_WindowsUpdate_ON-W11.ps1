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

# --- Formatting Helpers ---

function Write-Centered {
    param(
        [string]$Text,
        [int]$Width = 60
    )
    # Strip ANSI for length calculation
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
    # Rule 3 & 4: Left-align with 2 spaces indentation
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
    # Rule 3: Body content Left-aligned
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

# --- Original Registry Logic ---

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
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
}

# Registry Paths
$WU_UX  = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
$WU_POL = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$WINLOGON_USER = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" 
$WINLOGON_MACHINE = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

function Show-WUStatus {
    Write-Header "WINDOWS UPDATE SETTINGS"

    Write-Host ""
    Write-BodyTitle "More options"
    $continuous = Get-RegistryValue -Path $WU_UX -Name "IsContinuousInnovationOptedIn"
    Write-LeftAligned (Get-StatusLine ($continuous -eq 1) "Get latest updates as soon as possible")

    Write-Host ""
    Write-BodyTitle "Advanced options"
    $mu = Get-RegistryValue -Path $WU_UX  -Name "AllowMUUpdateService"
    Write-LeftAligned (Get-StatusLine ($mu -eq 1) "Receive updates for other Microsoft products")

    $restartNotify = Get-RegistryValue -Path $WU_UX -Name "RestartNotificationsAllowed2"
    Write-LeftAligned (Get-StatusLine ($restartNotify -eq 1) "Notify me when a restart is required")

    $ahs = Get-RegistryValue -Path $WU_UX -Name "ActiveHoursStart"
    $ahe = Get-RegistryValue -Path $WU_UX -Name "ActiveHoursEnd"
    if ($ahs -ne $null -and $ahe -ne $null) {
        Write-LeftAligned "$FGGray  Active hours: ${ahs}:00 - ${ahe}:00$Reset"
    } else {
        Write-LeftAligned "$FGGray  Active hours: Auto (based on device activity)$Reset"
    }
    
    Write-Host ""
    Write-BodyTitle "Sign-in options"
    $restartApps = Get-RegistryValue -Path $WINLOGON_USER -Name "RestartApps"
    Write-LeftAligned (Get-StatusLine ($restartApps -eq 1) "Automatically save restartable apps")
    
    # Logic for "Use sign-in info" (ARSO)
    $arsoEnabled = $false
    try {
        $UserSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        if ($UserSID) {
            $userArsoPath = "$WINLOGON_MACHINE\UserARSO\$UserSID"
            $optOut = Get-RegistryValue -Path $userArsoPath -Name "OptOut"
            $arsoEnabled = ($optOut -ne $null -and $optOut -eq 0)
        }
        Write-LeftAligned (Get-StatusLine $arsoEnabled "Use sign-in info to finish setup after update")
    } catch {
        Write-LeftAligned "$FGDarkRed$Char_XSquare $FGGray Use sign-in info (Check Failed)$Reset"
    }

    Write-Host ""
    Write-BodyTitle "Policy inspection"
    $pol_mu = Get-RegistryValue -Path $WU_POL -Name "AllowMUUpdateService"
    if ($pol_mu -ne $null) { 
        Write-LeftAligned "$FGGray Policy enforces Microsoft Update: $pol_mu$Reset"
    } else { 
        Write-LeftAligned "$FGGray No policy enforcement detected$Reset"
    }
    Write-Host ""
    Write-Boundary $FGDarkGray
}

function Set-WUSettings {
    try {
        # Configuring More options
        Set-RegistryDword -Path $WU_UX -Name "IsContinuousInnovationOptedIn" -Value 1

        # Configuring Advanced options
        Set-RegistryDword -Path $WU_UX -Name "AllowMUUpdateService" -Value 1
        Set-RegistryDword -Path $WU_UX -Name "RestartNotificationsAllowed2" -Value 1
        
        # Configuring Sign-in options
        try {
            Set-RegistryDword -Path $WINLOGON_USER -Name "RestartApps" -Value 1
            
            $policyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            $policyName = "DisableAutomaticRestartSignOn"
            $policyValue = Get-RegistryValue -Path $policyPath -Name $policyName

            if ($null -ne $policyValue -and $policyValue -eq 1) {
                # Policy blocking, skip
            } else {
                $UserSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
                if (-not $UserSID) { throw "Could not determine current user's SID." }
                $userArsoPath = "$WINLOGON_MACHINE\UserARSO\$UserSID"
                Set-RegistryDword -Path $WINLOGON_MACHINE -Name "ARSOUserConsent" -Value 1
                New-Item -Path $userArsoPath -Force -ErrorAction Stop | Out-Null
                Set-RegistryDword -Path $userArsoPath -Name "OptOut" -Value 0
            }
        } catch {
             Write-LeftAligned "$FGDarkRed$Char_Warn Failed to set user sign-in options$Reset"
        }
    }
    catch {
        Write-LeftAligned "$FGDarkRed$Char_Warn Error applying settings: $($_.Exception.Message)$Reset"
    }
}

function Invoke-MSStoreUpdateCheck {
    Write-Host ""
    Write-Header "MICROSOFT STORE UPDATES"

    try {
        Add-Type -AssemblyName UIAutomationClient
        Add-Type -AssemblyName UIAutomationTypes
    } catch {
        Write-LeftAligned "$FGDarkYellow$Char_Warn Failed to load UI Automation assemblies$Reset"
        return
    }

    Write-LeftAligned "$FGYellow Opening Microsoft Store to check for app updates...$Reset"
    Start-Process "ms-windows-store://downloadsandupdates"
    Start-Sleep -Seconds 5

    try {
        $desktop = [System.Windows.Automation.AutomationElement]::RootElement
        $condition = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, "Microsoft Store")
        $storeWindow = $desktop.FindFirst([System.Windows.Automation.TreeScope]::Children, $condition)
        
        if ($storeWindow -eq $null) {
            Write-LeftAligned "$FGDarkYellow$Char_Warn Could not find Microsoft Store window$Reset"
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
                    Write-LeftAligned "$FGDarkGreen$Char_BallotCheck Successfully clicked '$buttonText'$Reset"
                    $buttonFound = $true
                    break
                }
            }
        }
        
        if (-not $buttonFound) {
            Write-LeftAligned "$FGDarkYellow$Char_Warn Could not find update button$Reset"
        }
        
    } catch {
        Write-LeftAligned "$FGDarkYellow$Char_Warn UI Automation Error$Reset"
    }
    Write-Boundary $FGDarkGray
}

function Invoke-WinUpdateCheck {
    Write-Host ""
    Write-Header "WINDOWS UPDATE CHECK"

    try {
        Add-Type -AssemblyName UIAutomationClient
        Add-Type -AssemblyName UIAutomationTypes
    } catch {
        Write-LeftAligned "$FGDarkYellow$Char_Warn Failed to load UI Automation assemblies$Reset"
        return
    }

    Write-LeftAligned "$FGYellow Opening Windows Update settings...$Reset"
    Start-Process "ms-settings:windowsupdate"
    Start-Sleep -Seconds 5

    try {
        $desktop = [System.Windows.Automation.AutomationElement]::RootElement
        $condition = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, "Settings")
        $settingsWindow = $desktop.FindFirst([System.Windows.Automation.TreeScope]::Children, $condition)
        
        if ($settingsWindow -eq $null) {
            Write-LeftAligned "$FGDarkYellow$Char_Warn Could not find Settings window$Reset"
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
                    Write-LeftAligned "$FGDarkGreen$Char_BallotCheck Successfully clicked '$text'$Reset"
                    $buttonFound = $true
                    break
                }
            }
        }
        
        if (-not $buttonFound) {
             Write-LeftAligned "$FGDarkYellow$Char_Warn Could not find update buttons$Reset"
        }
        
    } catch {
        Write-LeftAligned "$FGDarkYellow$Char_Warn UI Automation Error$Reset"
    }
    Write-Boundary $FGDarkGray
}

# --- Main ---
Write-Header "WINDOWS UPDATE CONFIGURATOR"

Set-WUSettings
Show-WUStatus

# --- User Prompt ---
Write-Host ""
# Icons and Colors matched to scriptRULES-W11.ps1
$prompt = "${FGDarkCyan}$Char_Keyboard  ${FGYellow}Press ${FGYellow}$Char_Finger Enter${FGDarkCyan} to Run Checks  |  Press ${FGYellow}$Char_Finger Spacebar${FGDarkCyan} to Skip$Reset"
Write-Centered $prompt

do {
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} while ($key.VirtualKeyCode -ne 13 -and $key.Character -ne ' ')

if ($key.VirtualKeyCode -eq 13) { # 13 is Enter
    Invoke-MSStoreUpdateCheck
    Invoke-WinUpdateCheck
} else {
    Write-Host ""
    Write-LeftAligned "$FGGray Skipping update checks.$Reset"
}

# Footer
Write-Host ""
$lastEditedTimestamp = "2025-11-25"
Write-Boundary $FGDarkBlue
Write-Centered "$FGDarkCyan$Char_Copyright $lastEditedTimestamp, www.AIIT.support$Reset"
# Write-Boundary $FGDarkBlue # Removed bottom boundary to match typical Install script footer style if preferred, otherwise keep. Kept simple.

# Exit Spacing
1..5 | ForEach-Object { Write-Host "" }
