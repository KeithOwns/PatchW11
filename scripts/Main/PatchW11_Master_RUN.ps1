#Requires -RunAsAdministrator
<#
.SYNOPSIS
    PatchW11 Master Control Suite
.DESCRIPTION
    The central hub for the PatchW11 suite. Combines Windows Update, Security,
    Maintenance, and Application Deployment into a single unified interface.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- [USER PREFERENCE] CLEAR SCREEN START ---
Clear-Host
# --------------------------------------------

# --- STYLE & FORMATTING CONFIGURATION ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Icons
$Char_HeavyLine   = [char]0x2501 # ━
$Char_BallotCheck = [char]0x2611 # ☑
$Char_RedCross    = [char]0x274E # ❎
$Char_Warn        = [char]0x26A0 # ⚠
$Char_Finger      = [char]0x261B # ☛
$Char_Keyboard    = [char]0x2328 # ⌨
$Char_Skip        = [char]0x23ED # ⏭
$Char_HeavyMinus  = [char]0x2796 # ➖
$Char_Eject       = [char]0x23CF # ⏏

# Colors
$Esc = [char]0x1B
$Reset = "$Esc[0m"
$Bold = "$Esc[1m"
$FGCyan       = "$Esc[96m"
$FGBlue       = "$Esc[94m"
$FGDarkBlue   = "$Esc[34m"
$FGGreen      = "$Esc[92m"
$FGRed        = "$Esc[91m"
$FGYellow     = "$Esc[93m"
$FGDarkCyan   = "$Esc[36m"
$FGWhite      = "$Esc[97m"
$FGGray       = "$Esc[37m"
$FGDarkGray   = "$Esc[90m"
$FGBlack      = "$Esc[30m"
$BGYellow     = "$Esc[103m"

# Helper Functions
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
    Write-Host ""
    $TopTitle = " $Char_HeavyLine PatchW11 $Char_HeavyLine "
    Write-Centered "$Bold$FGCyan$TopTitle$Reset"
    Write-Centered "$Bold$FGCyan$Title$Reset"
    Write-Boundary $FGDarkBlue
}

function Write-Boundary {
    param([string]$Color = $FGDarkBlue)
    Write-Host "$Color$([string]$Char_HeavyLine * 60)$Reset"
}

# --- MAIN EXECUTION ---

$running = $true

while ($running) {
    Clear-Host
    Write-Header "MASTER CONTROL SUITE"
    
    Write-Host ""
    Write-LeftAligned " ${FGBlack}${BGYellow}[1]${Reset} ${FGGray}Windows Update ${FGDarkGray}(Set & Scan)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[2]${Reset} ${FGGray}Windows Security ${FGDarkGray}(Check & Fix)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[3]${Reset} ${FGGray}Maintenance ${FGDarkGray}(Optimize & Clean)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[4]${Reset} ${FGGray}App Installer ${FGDarkGray}(Select & Install)${Reset}"
    Write-Host ""
    Write-LeftAligned " ${FGBlack}${BGYellow}[A]${Reset} ${FGGray}Run ${FGYellow}ALL${FGGray} Diagnostics (1-3)${Reset}"
    
    Write-Boundary $FGDarkBlue
    
    $prompt = "${FGWhite}$Char_Keyboard  Press${FGDarkGray} ${FGYellow}$Char_Finger [Key]${FGDarkGray} ${FGWhite}to${FGDarkGray} ${FGYellow}RUN${FGWhite}|${FGDarkGray}any other to ${FGWhite}EXIT$Char_Eject${Reset}"
    Write-Centered $prompt
    
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $char = $key.Character.ToString().ToUpper()
    
    switch ($char) {
        '1' { 
            & "$PSScriptRoot\WindowsUpdate_SETnSCAN.ps1"
            Pause 
        }
        '2' { 
            & "$PSScriptRoot\WindowsSecurity_CHECKnSETnSCAN.ps1"
            Pause 
        }
        '3' { 
            & "$PSScriptRoot\WindowsMaintenance_SETnSCAN.ps1" 
            # Maintenance script has its own pause/menu loop usually, but let's pause to be safe
        }
        '4' { 
            # App Installer Sub-Menu
            Write-Host ""
            Write-Boundary $FGDarkGray
            Write-Centered "${FGWhite}App Installer Setup"
            Write-LeftAligned " ${FGBlack}${BGYellow}[C]${Reset} ${FGGray}Configure / Edit App List${Reset}"
            Write-LeftAligned " ${FGBlack}${BGYellow}[I]${Reset} ${FGGray}Install Apps ${FGDarkGray}(Current Config)${Reset}"
            Write-Boundary $FGDarkGray
            
            $subPrompt = "${FGWhite}$Char_Keyboard  Press${FGDarkGray} ${FGYellow}$Char_Finger [Key]${FGDarkGray} ${FGWhite}to${FGDarkGray} ${FGYellow}Select${FGWhite}|${FGDarkGray}any other to ${FGWhite}BACK${Reset}"
            Write-Centered $subPrompt
            
            $subKey = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            $subChar = $subKey.Character.ToString().ToUpper()
            
            if ($subChar -eq 'C') {
                & "$PSScriptRoot\Create_AppConfig.ps1"
            } elseif ($subChar -eq 'I') {
                & "$PSScriptRoot\Install_Apps-Configurable.ps1"
                Pause
            }
        }
        'A' {
            Write-Host ""
            Write-LeftAligned "$FGYellow Running Full Suite...$Reset"
            Start-Sleep -Seconds 1
            
            & "$PSScriptRoot\WindowsUpdate_SETnSCAN.ps1"
            & "$PSScriptRoot\WindowsSecurity_CHECKnSETnSCAN.ps1"
            & "$PSScriptRoot\WindowsMaintenance_SETnSCAN.ps1"
            
            Write-Host ""
            Write-LeftAligned "$FGGreen$Char_BallotCheck Suite Complete.$Reset"
            Pause
        }
        Default {
            $running = $false
            Write-Host ""
            Write-LeftAligned "$FGGray Exiting...$Reset"
            Start-Sleep -Milliseconds 500
        }
    }
}

# --- FOOTER ---
Write-Host ""
Write-Boundary $FGDarkBlue
$FooterText = "© $(Get-Date -Format 'yyyy'), www.AIIT.support. All Rights Reserved."
Write-Centered "$FGCyan$FooterText$Reset"
1..3 | ForEach-Object { Write-Host "" }