#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows 11 Debloat & Privacy Optimizer
.DESCRIPTION
    Removes pre-installed bloatware, hardens privacy settings (Telemetry, Ad ID),
    and offers UI tweaks (Taskbar alignment, Classic Context Menu).
#>

param([switch]$AutoRun)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- STYLE & FORMATTING ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Char_HeavyLine = [char]0x2501; $Char_BallotCheck = [char]0x2611; $Char_RedCross = [char]0x274E
$Char_Warn = [char]0x26A0; $Char_Finger = [char]0x261B; $Char_HeavyMinus = [char]0x2796
$Char_Eject = [char]0x23CF; $Char_Keyboard = [char]0x2328; $Char_Skip = [char]0x23ED
$Esc = [char]0x1B; $Reset = "$Esc[0m"; $Bold = "$Esc[1m"
$FGCyan = "$Esc[96m"; $FGGreen = "$Esc[92m"; $FGYellow = "$Esc[93m"; $FGRed = "$Esc[91m"; $FGWhite = "$Esc[97m"; $FGGray = "$Esc[37m"
$FGDarkBlue = "$Esc[34m"; $FGDarkGray = "$Esc[90m"; $FGDarkGreen = "$Esc[32m"; $FGBlack = "$Esc[30m"; $BGYellow = "$Esc[103m"

function Write-Centered { param($Text, $Width = 60) $clean = $Text -replace "$Esc\[[0-9;]*m", ""; $pad = [Math]::Floor(($Width - $clean.Length) / 2); if ($pad -lt 0) { $pad = 0 }; Write-Host (" " * $pad + $Text) }
function Write-LeftAligned { param($Text, $Indent = 2) Write-Host (" " * $Indent + $Text) }
function Write-Header { param($Title) Write-Host ""; Write-Centered "$Bold$FGCyan $Char_HeavyLine PatchW11 $Char_HeavyLine $Reset"; Write-Centered "$Bold$FGCyan$Title$Reset"; Write-Host "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset" }
function Write-Boundary { param($Color = $FGDarkBlue) Write-Host "$Color$([string]$Char_HeavyLine * 60)$Reset" }

# --- BLOATWARE LISTS ---
$ThirdPartyBloat = @(
    "*Spotify*", "*Disney*", "*Netflix*", "*Instagram*", "*TikTok*", "*Facebook*", "*Twitter*", "*CandyCrush*", "*LinkedIn*", "*GamingApp*"
)
$MicrosoftBloat = @(
    "*BingNews*", "*BingWeather*", "*GetHelp*", "*GetStarted*", "*Microsoft365Hub*", "*SolitaireCollection*", "*Todos*", "*FeedbackHub*", "*YourPhone*", "*Cortana*"
)

# --- FUNCTIONS ---

function Create-RestorePoint {
    Write-Host ""
    Write-Header "SYSTEM RESTORE POINT"
    try {
        $pointName = "PatchW11 Debloat $(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-LeftAligned "$FGYellow Creating restore point: $pointName...$Reset"
        Checkpoint-Computer -Description $pointName -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-LeftAligned "$FGGreen$Char_BallotCheck Restore Point created successfully.$Reset"
    } catch {
        Write-LeftAligned "$FGRed$Char_Warn Skip Restore Point: $($_.Exception.Message)$Reset"
    }
    Write-Boundary $FGDarkGray
}

# --- MAIN MENU ---
if (-not $AutoRun) {
    Clear-Host
    Write-Header "WINDOWS DEBLOAT & OPTIMIZER"
    Write-Host ""
    Write-LeftAligned "Select an operation:"
    Write-Host ""
    Write-LeftAligned "  [1] DEBLOAT Windows (Remove junk, enhance privacy)"
    Write-LeftAligned "  [2] RESTORE Default Apps (Undo debloat)"
    Write-Host ""
    Write-Boundary $FGDarkBlue
    
    $menuChoice = Read-Host "  $Char_Finger Selection"
} else {
    $menuChoice = "1" # Default to Debloat in AutoRun
}

# --- PATH 2: RESTORE ---
if ($menuChoice -eq "2") {
    Clear-Host
    Write-Header "UNDO DEBLOAT (RESTORE APPS)"

    Write-Host ""
    Write-LeftAligned "$FGYellow Warning: This will attempt to reinstall ALL default Windows apps.$Reset"
    Write-LeftAligned "This process may take several minutes and might show red error messages"
    Write-LeftAligned "for apps that are currently in use or newer versions."
    Write-Host ""

    $choice = Read-Host "  Type 'RESTORE' to continue"
    if ($choice -ne 'RESTORE') { exit }

    Write-Host ""
    Write-LeftAligned "$FGYellow Starting restoration process...$Reset"

    try {
        # The standard command to re-register all apps
        Get-AppxPackage -AllUsers | ForEach-Object {
            if ($_.InstallLocation -and (Test-Path "$($_.InstallLocation)\AppXManifest.xml")) {
                Write-Host "." -NoNewline -ForegroundColor Gray
                Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue
            }
        }
        Write-Host ""
        Write-Host ""
        Write-LeftAligned "$FGGreen$Char_BallotCheck Operation Complete.$Reset"
        Write-LeftAligned "$FGGray Please restart your computer to finalize app registration.$Reset"
    } catch {
        Write-LeftAligned "$FGRed$Char_Warn Critical Error: $($_.Exception.Message)$Reset"
    }

    Write-Host ""
    if (-not $AutoRun) { Pause }
    exit
}

# --- PATH 1: DEBLOAT (Continue with existing script) ---

function Remove-AppList {
    param($List, $Name)
    Write-LeftAligned "$FGYellow Scanning for $Name...$Reset"
    $found = 0
    foreach ($pattern in $List) {
        $app = Get-AppxPackage -Name $pattern -ErrorAction SilentlyContinue
        if ($app) {
            Write-LeftAligned "  Removing: $($app.Name)"
            $app | Remove-AppxPackage -ErrorAction SilentlyContinue
            $found++
        }
    }
    if ($found -eq 0) { Write-LeftAligned "$FGGray  No $Name found.$Reset" }
    else { Write-LeftAligned "$FGGreen  Removed $found apps.$Reset" }
}

function Configure-Privacy {
    Write-Host ""
    Write-LeftAligned "$Bold$FGWhite$Char_HeavyMinus Configuring Privacy Settings$Reset"
    
    try {
        # Disable Advertising ID
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name "Enabled" -Value 0 -Type DWord
        Write-LeftAligned "$FGGreen$Char_BallotCheck Advertising ID Disabled$Reset"

        # Disable Telemetry (Requires HKLM)
        $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name "AllowTelemetry" -Value 0 -Type DWord
        Write-LeftAligned "$FGGreen$Char_BallotCheck Telemetry Disabled$Reset"

        # Disable Tailored Experiences
        $path = "HKCU:\Software\Policies\Microsoft\Windows\CloudContent"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name "DisableTailoredExperiencesWithDiagnosticData" -Value 1 -Type DWord
        Write-LeftAligned "$FGGreen$Char_BallotCheck Tailored Experiences Disabled$Reset"
        
        # Disable Suggested Content in Settings
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord
        Set-ItemProperty -Path $path -Name "SubscribedContent-353698Enabled" -Value 0 -Type DWord
        Write-LeftAligned "$FGGreen$Char_BallotCheck Suggestions & Tips Disabled$Reset"

    } catch {
        Write-LeftAligned "$FGRed$Char_RedCross Error setting privacy: $($_.Exception.Message)$Reset"
    }
}

function Configure-Explorer {
    Write-Host ""
    Write-LeftAligned "$Bold$FGWhite$Char_HeavyMinus Configuring File Explorer & UI$Reset"
    
    try {
        # Show File Extensions
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-ItemProperty -Path $path -Name "HideFileExt" -Value 0 -Type DWord
        Write-LeftAligned "$FGGreen$Char_BallotCheck File Extensions Visible$Reset"

        # Show Hidden Files
        Set-ItemProperty -Path $path -Name "Hidden" -Value 1 -Type DWord
        Write-LeftAligned "$FGGreen$Char_BallotCheck Hidden Files Visible$Reset"
        
        # Launch Folder Windows in Separate Process (Stability)
        Set-ItemProperty -Path $path -Name "SeparateProcess" -Value 1 -Type DWord
        Write-LeftAligned "$FGGreen$Char_BallotCheck Explorer Separate Process Enabled$Reset"

    } catch {
        Write-LeftAligned "$FGRed$Char_RedCross Error configuring Explorer: $($_.Exception.Message)$Reset"
    }
}

function Restore-ClassicContext {
    $key = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    if (-not (Test-Path $key)) {
        New-Item -Path $key -Force | Out-Null
        Set-ItemProperty -Path $key -Name "(default)" -Value "" -Force
        Write-LeftAligned "$FGGreen$Char_BallotCheck Classic Context Menu Restored (Restart Explorer to apply)$Reset"
    } else {
        Write-LeftAligned "$FGGray Classic Context Menu already set.$Reset"
    }
}

function Align-Taskbar {
    param($AlignLeft = $true)
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $val = if ($AlignLeft) { 0 } else { 1 }
    Set-ItemProperty -Path $path -Name "TaskbarAl" -Value $val -Type DWord
    $pos = if ($AlignLeft) { "Left" } else { "Center" }
    Write-LeftAligned "$FGGreen$Char_BallotCheck Taskbar Aligned: $pos$Reset"
}

# --- MAIN EXECUTION ---

Write-Header "DEBLOAT & PRIVACY"

if ($AutoRun) {
    Create-RestorePoint
    Write-LeftAligned "$FGYellow AutoRun: Executing Standard Debloat...$Reset"
    
    # 1. Privacy First
    Configure-Privacy
    Configure-Explorer
    
    # 2. Bloatware (Safe list only for Auto)
    Write-Host ""
    Remove-AppList -List $ThirdPartyBloat -Name "Third-Party Bloatware"
    
    # 3. Tweaks
    Write-Host ""
    Write-LeftAligned "$Bold$FGWhite$Char_HeavyMinus Applying UI Tweaks$Reset"
    Restore-ClassicContext
    # Default to Left Align for Auto? Or skip? Let's skip Taskbar alignment in Auto to respect user pref unless explicit.
    # Actually, Classic Context is a safe "Pro" default.
    
    Write-Host ""
    Write-Boundary
    Write-Centered "$FGGreen DEBLOAT COMPLETE $Reset"
    Stop-Process -Name explorer -Force # Restart explorer to apply UI
    exit
}

# --- Interactive Menu ---
$menu = $true
while ($menu) {
    Write-Host ""
    Write-LeftAligned " ${FGBlack}${BGYellow}[1]${Reset} ${FGGray}Remove Third-Party Bloat ${FGDarkGray}(Spotify, TikTok, etc.)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[2]${Reset} ${FGGray}Remove Microsoft Bloat ${FGDarkGray}(Bing News, Solitaire, etc.)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[3]${Reset} ${FGGray}Apply Privacy Hardening ${FGDarkGray}(Telemetry, Ads)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[4]${Reset} ${FGGray}Explorer Tweaks ${FGDarkGray}(Show Exts, Hidden Files)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[5]${Reset} ${FGGray}Restore Classic Context Menu${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[6]${Reset} ${FGGray}Align Taskbar Left${Reset}"
    Write-Host ""
    Write-LeftAligned " ${FGBlack}${BGYellow}[A]${Reset} ${FGYellow}Run ALL Recommended${Reset}"
    
    Write-Boundary
    $prompt = "${FGWhite}$Char_Keyboard  Press${FGDarkGray} ${FGYellow}$Char_Finger [Key]${FGDarkGray} ${FGWhite}to${FGDarkGray} ${FGYellow}Execute${FGWhite}|${FGDarkGray}any other to ${FGWhite}EXIT$Char_Eject${Reset}"
    Write-Centered $prompt
    
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $c = $key.Character.ToString().ToUpper()
    
    switch ($c) {
        '1' { Remove-AppList -List $ThirdPartyBloat -Name "Third-Party Bloatware" }
        '2' { Remove-AppList -List $MicrosoftBloat -Name "Microsoft Bloatware" }
        '3' { Configure-Privacy }
        '4' { Configure-Explorer }
        '5' { Restore-ClassicContext; Stop-Process -Name explorer -Force }
                '6' { Align-Taskbar -AlignLeft $true; Stop-Process -Name explorer -Force }
                'A' {
                    Create-RestorePoint
                    Configure-Privacy
                    Configure-Explorer            Remove-AppList -List $ThirdPartyBloat -Name "Third-Party Bloatware"
            Remove-AppList -List $MicrosoftBloat -Name "Microsoft Bloatware"
            Restore-ClassicContext
            Stop-Process -Name explorer -Force
        }
        Default { $menu = $false }
    }
}
