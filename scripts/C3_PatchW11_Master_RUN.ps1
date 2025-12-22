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

function Pause {
    Write-Host ""
    while ($Host.UI.RawUI.KeyAvailable) { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }
    for ($i = 5; $i -gt 0; $i--) {
        if ($Host.UI.RawUI.KeyAvailable) {
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Write-Host "`r  $([char]0x23F8) Paused. Press any key to continue...       " -NoNewline -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            break
        }
        Write-Host "`r  $([char]0x23F1) Continuing in $i s... (Press any key to pause)   " -NoNewline -ForegroundColor Gray
        Start-Sleep -Seconds 1
    }
    Write-Host "`r                                                           " -NoNewline
    Write-Host ""
}

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
    Write-Header "MASTER CONTROL SUITE v3.0"
    
    Write-Host ""
    Write-LeftAligned " ${FGBlack}${BGYellow}[0]${Reset} ${FGGray}System Pre-Check ${FGDarkGray}(Health & Status)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[1]${Reset} ${FGGray}Windows Update ${FGDarkGray}(Set & Scan)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[2]${Reset} ${FGGray}Windows Security ${FGDarkGray}(Check & Fix)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[3]${Reset} ${FGGray}Maintenance ${FGDarkGray}(Optimize & Clean)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[4]${Reset} ${FGGray}App Installer ${FGDarkGray}(Select & Install)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[5]${Reset} ${FGGray}System Repair ${FGDarkGray}(SFC & DISM Flow)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[6]${Reset} ${FGGray}Debloat & Privacy ${FGDarkGray}(Remove Junk & Harden)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[7]${Reset} ${FGGray}System Restore ${FGDarkGray}(Revert Changes)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[8]${Reset} ${FGGray}Network Toolkit ${FGDarkGray}(Fix & Secure)${Reset}"
    Write-Host ""
    Write-LeftAligned " ${FGBlack}${BGYellow}[9]${Reset} ${FGGray}Utilities & Reports ${FGDarkGray}(Inventory, Batt, Logs...)${Reset}"
    Write-Host ""
    Write-LeftAligned " ${FGBlack}${BGYellow}[A]${Reset} ${FGGray}Run ${FGYellow}ALL${FGGray} Diagnostics (1-3, 5, 6)${Reset}"
    
    Write-Boundary $FGDarkBlue
    
    $prompt = "${FGWhite}$Char_Keyboard  Press${FGDarkGray} ${FGYellow}$Char_Finger [Key]${FGDarkGray} ${FGWhite}to${FGDarkGray} ${FGYellow}RUN${FGWhite}|${FGDarkGray}any other to ${FGWhite}EXIT$Char_Eject${Reset}"
    Write-Centered $prompt
    
    $inputStr = Read-Host "  $Char_Finger Selection"
    
    switch ($inputStr.Trim().ToUpper()) {
        '0' { & "$PSScriptRoot\CHECK_System_PreCheck.ps1" }
        '1' { & "$PSScriptRoot\C1_WindowsUpdate_SETnSCAN.ps1"; Pause }
        '2' { & "$PSScriptRoot\C5_WindowsSecurity_CHECKnSETnSCAN.ps1"; Pause }
        '3' { & "$PSScriptRoot\C4_WindowsMaintenance_SETnSCAN.ps1" }
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
            if ($subChar -eq 'C') { & "$PSScriptRoot\SET_Create_AppConfig.ps1" } elseif ($subChar -eq 'I') { & "$PSScriptRoot\RUN_Install_Apps-Configurable.ps1"; Pause }
        }
        '5' { & "$PSScriptRoot\RUN_WindowsSFC_REPAIR.ps1"; Pause }
        '6' { & "$PSScriptRoot\C2_WindowsDebloat_CLEAN.ps1"; Pause }
        '7' { & "$PSScriptRoot\RUN_System_RESTORE.ps1" }
        '8' { & "$PSScriptRoot\C7_Network_FIXnSECURE.ps1"; Pause }
        '9' {
            # Utilities Sub-Menu
            $utilsRunning = $true
            while ($utilsRunning) {
                Clear-Host
                Write-Header "UTILITIES & REPORTS"
                Write-Host ""
                Write-LeftAligned " ${FGBlack}${BGYellow}[1]${Reset} ${FGGray}System Inventory ${FGDarkGray}(Report)${Reset}"
                Write-LeftAligned " ${FGBlack}${BGYellow}[2]${Reset} ${FGGray}Battery Health ${FGDarkGray}(Report)${Reset}"
                Write-LeftAligned " ${FGBlack}${BGYellow}[3]${Reset} ${FGGray}BSOD Analyzer ${FGDarkGray}(Logs)${Reset}"
                Write-LeftAligned " ${FGBlack}${BGYellow}[4]${Reset} ${FGGray}User Manager ${FGDarkGray}(Admin/Pass)${Reset}"
                Write-LeftAligned " ${FGBlack}${BGYellow}[5]${Reset} ${FGGray}Manage Startup ${FGDarkGray}(Boot)${Reset}"
                Write-LeftAligned " ${FGBlack}${BGYellow}[6]${Reset} ${FGGray}Bulk Uninstaller ${FGDarkGray}(Apps)${Reset}"
                Write-LeftAligned " ${FGBlack}${BGYellow}[7]${Reset} ${FGGray}Context Menu Integration${Reset}"
                Write-LeftAligned " ${FGBlack}${BGYellow}[8]${Reset} ${FGGray}Configure Notifications${Reset}"
                Write-Host ""
                Write-LeftAligned " ${FGBlack}${BGYellow}[U]${Reset} ${FGGray}Update Suite ${FGDarkGray}(Git Pull)${Reset}"
                Write-LeftAligned " ${FGBlack}${BGYellow}[P]${Reset} ${FGGray}Pack Portable ${FGDarkGray}(Zip)${Reset}"
                Write-LeftAligned " ${FGBlack}${BGYellow}[R]${Reset} ${FGGray}Remote Execute ${FGDarkGray}(Deploy)${Reset}"
                Write-LeftAligned " ${FGBlack}${BGYellow}[D]${Reset} ${FGGray}Undo Debloat ${FGDarkGray}(Restore)${Reset}"
                Write-LeftAligned " ${FGBlack}${BGYellow}[X]${Reset} ${FGGray}Suite Cleanup ${FGDarkGray}(Delete)${Reset}"
                
                Write-Boundary $FGDarkBlue
                $uPrompt = "${FGWhite}$Char_Keyboard  Press${FGDarkGray} ${FGYellow}$Char_Finger [Key]${FGDarkGray} ${FGWhite}to${FGDarkGray} ${FGYellow}RUN${FGWhite}|${FGDarkGray}any other to ${FGWhite}BACK${Reset}"
                Write-Centered $uPrompt
                
                $uInput = Read-Host "  $Char_Finger Selection"
                switch ($uInput.Trim().ToUpper()) {
                    '1' { & "$PSScriptRoot\CHECK_System_INVENTORY.ps1" }
                    '2' { & "$PSScriptRoot\CHECK_Check_BatteryHealth.ps1" }
                    '3' { & "$PSScriptRoot\CHECK_Check_BSOD.ps1" }
                    '4' { & "$PSScriptRoot\SET_User_MANAGER.ps1" }
                    '5' { & "$PSScriptRoot\SET_Manage_Startup.ps1" }
                    '6' { & "$PSScriptRoot\RUN_Bulk_Uninstaller.ps1" }
                    '7' { & "$PSScriptRoot\SET_Integration_ContextMenu.ps1" }
                    '8' { & "$PSScriptRoot\SET_Setup_Notifications.ps1" }
                    'U' { & "$PSScriptRoot\RUN_Update_Suite.ps1" }
                    'P' { & "$PSScriptRoot\RUN_Pack_Portable.ps1" }
                    'R' { & "$PSScriptRoot\RUN_Remote_EXECUTE.ps1" }
                    'D' { & "$PSScriptRoot\C2_WindowsDebloat_CLEAN.ps1" }
                    'X' { & "$PSScriptRoot\RUN_Suite_CLEANUP.ps1" }
                    Default { $utilsRunning = $false }
                }
            }
        }
        'A' {
            Write-Host ""
            Write-LeftAligned "$FGYellow Running Full Suite...$Reset"
            Start-Sleep -Seconds 1
            & "$PSScriptRoot\C1_WindowsUpdate_SETnSCAN.ps1"
            & "$PSScriptRoot\C5_WindowsSecurity_CHECKnSETnSCAN.ps1"
            & "$PSScriptRoot\C4_WindowsMaintenance_SETnSCAN.ps1"
            & "$PSScriptRoot\RUN_WindowsSFC_REPAIR.ps1"
            & "$PSScriptRoot\C2_WindowsDebloat_CLEAN.ps1" -AutoRun
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