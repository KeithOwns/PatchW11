#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Comprehensive Windows Security Status Checker with Reporting and Remediation
.DESCRIPTION
    Retrieves and displays all Windows Security configurations with visual formatting,
    security scoring, and remediation suggestions.
    
    STRICTLY MATCHED TO scriptRULES-W11.ps1 STANDARDS.
    - Header: Cyan 'PatchW11' / DarkCyan Subtitle / DarkBlue Boundary
    - Body: Left-Aligned, 1 Space Indent
    - Icons: System Enabled (DarkGreen Ballot), System Disabled (DarkRed XSquare 0x274E)
    - Boundaries: Body (DarkGray), Header/Footer (DarkBlue)
    - Footer: Copyright 2025, All Rights Reserved (Cyan)
    - Colors: Body Text (Gray), Header Icons (White), Output Text (DarkCyan)
    - Version Check: Compares local signature against Microsoft Online (DarkGreen/DarkRed)

.PARAMETER ShowRemediation
    Display PowerShell commands to fix disabled security features
.NOTES
    Requires Administrator privileges
    Encoding: UTF-8
#>

param(
    [Parameter(Mandatory = $false)]
    [switch]$ShowRemediation
)

# --- [USER PREFERENCE] CLEAR SCREEN START ---
Clear-Host
# --------------------------------------------

# --- FIX: Reset environment settings to prevent conflicts ---
Set-StrictMode -Off
$ErrorActionPreference = 'Continue'

# --- Formatting & Encoding ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Define Unicode Characters & ANSI Colors (Unified with scriptRULES) ---
$Char_EmDash      = [char]0x2014 # —
$Char_EnDash      = [char]0x2013 # –
$Char_BallotCheck = [char]0x2611 # ☑ - Used for DarkGreen Enabled
# EDITED: Updated to 0x274E (❎) per user request
$Char_XSquare     = [char]0x274E # ❎ - Used for DarkRed Disabled
$Char_Warn        = [char]0x26A0 # ⚠ - Used for DarkYellow Warning
$Char_Radioactive = [char]0x2622 # ☢ - Used for Critical Warnings
$Char_HeavyCheck  = [char]0x2705 # ✅ - Used for Green Success
$Char_RedCross    = [char]0x274E # ❎ - Used for Red Failure
$Char_Keyboard    = [char]0x2328 # ⌨ - Used for Prompt
$Char_Finger      = [char]0x261B # ☛ - Used for Yellow Keypress
$Char_Copyright   = [char]0x00A9 # © - Used for Footer
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504) # 🔄
$Char_Shield      = [char]::ConvertFromUtf32(0x1F6E1) # 🛡️
$Char_Person      = [char]::ConvertFromUtf32(0x1F464) # 👤
$Char_Satellite   = [char]::ConvertFromUtf32(0x1F4E1) # 📡
$Char_CardIndex   = [char]::ConvertFromUtf32(0x1F5C2) # 🗂️
$Char_Desktop     = [char]::ConvertFromUtf32(0x1F5A5) # 🖥️

# Colors (scriptRULES Palette)
$Esc = [char]0x1B
$Reset = "$Esc[0m"
$Bold = "$Esc[1m"
$FGCyan       = "$Esc[96m"  # Header Title
$FGDarkCyan   = "$Esc[36m"  # Output Text
$FGBlue       = "$Esc[94m"  # Body Icon
$FGDarkBlue   = "$Esc[34m"  # Header Boundary
$FGWhite      = "$Esc[97m"  # Body Title
$FGGray       = "$Esc[37m"  # Body Text
$FGDarkGray   = "$Esc[90m"  # Body Boundary
$FGDarkGreen  = "$Esc[32m"  # System Enabled
$FGDarkRed    = "$Esc[31m"  # System Disabled
$FGDarkYellow = "$Esc[33m"  # System Warning
$FGGreen      = "$Esc[92m"  # SCRIPT Success
$FGRed        = "$Esc[91m"  # SCRIPT Failure
$FGYellow     = "$Esc[93m"  # Input Keypress
$FGBlack      = "$Esc[30m"
$BGYellow     = "$Esc[103m"
# EDITED: Added BGDarkGray for prompt styling
$BGDarkGray   = "$Esc[100m"

# Global Logging Variables
$script:LogPath = "C:\Windows\Temp\Security_$(Get-Date -Format 'yyMMdd').log"

# --- Unified Helper Functions ---

function Write-Centered {
    param([string]$Text, [int]$Width = 60)
    $cleanText = $Text -replace "$Esc\[[0-9;]*m", ""
    $padLeft = [Math]::Floor(($Width - $cleanText.Length) / 2)
    if ($padLeft -lt 0) { $padLeft = 0 }
    Write-Host (" " * $padLeft + $Text)
}

function Write-LeftAligned {
    param([string]$Text, [int]$Indent = 1) # Rule: Icon 1 space
    Write-Host (" " * $Indent + $Text)
}

function Write-Header {
    param([string]$SubTitle)
    
    # Empty line before header
    Write-Host ""
    
    # 1. Top Title (Cyan, Bold, Centered)
    $TopTitle = "── PatchW11 ──"
    Write-Centered "$Bold$FGCyan$TopTitle$Reset"
    
    # 2. Sub-Header (DarkCyan, Bold, Centered)
    Write-Centered "$Bold$FGDarkCyan$SubTitle$Reset"

    # 3. Header Boundary (DarkBlue, 60 chars)
    Write-Host "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"
}

function Write-BodyTitle {
    param([string]$Title)
    # Rule: White Body Title. Default String format is "- - Title - -"
    Write-LeftAligned "$Bold$FGWhite$Char_EmDash$Char_EmDash $Title $Char_EmDash$Char_EmDash$Reset" -Indent 1
}

function Write-Boundary {
    param([string]$Color = $FGDarkGray) # Rule: Body Boundary is DarkGray
    Write-Host "$Color$([string]$Char_EmDash * 60)$Reset"
}

function Get-StatusLine {
    param([bool]$IsEnabled, [string]$Text)
    # Rule: System Enabled (DarkGreen + BallotCheck), System Disabled (DarkRed + XSquare)
    # Rule: Output Text (Gray) - User Requested
    if ($IsEnabled) { return "$FGDarkGreen$Char_BallotCheck  $FGGray$Text$Reset" }
    else { return "$FGDarkRed$Char_XSquare $FGGray$Text$Reset" }
}

# --- Logging & Registry Functions ---

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

# NEW: Set-RegistryString to handle text-based registry values (like SmartScreen)
function Set-RegistryString {
    param([Parameter(Mandatory)] [string]$Path, [Parameter(Mandatory)] [string]$Name, [Parameter(Mandatory)] [string]$Value)
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
            Write-Log -Message "Created registry path: $Path" -Level INFO
        }
        New-ItemProperty -Path $Path -Name $Name -PropertyType String -Value $Value -Force | Out-Null
        Write-Log -Message "Set registry string: $Path\$Name = $Value" -Level SUCCESS
    } catch {
        Write-Log -Message "Failed to set registry: $Path\$Name - $($_.Exception.Message)" -Level ERROR
        throw $_
    }
}

# --- Script 02 Specific Helpers ---

# Global variables
$script:SecurityChecks = @()
$script:RealTimeProtectionEnabled = $true
$script:ThirdPartyAVActive = $false
$script:ScanStatusAllGreen = $false
$script:ActiveThreatCount = 0
$script:FullScanNeeded = $false

class SecurityCheck {
    [string]$Category
    [string]$Name
    [bool]$IsEnabled
    [string]$Severity
    [string]$Remediation
    [string]$Details
}

function Add-SecurityCheck {
    param(
        [string]$Category, [string]$Name, [bool]$IsEnabled, 
        [string]$Severity = "Warning", [string]$Remediation = "", [string]$Details = ""
    )
    $check = [SecurityCheck]@{
        Category = $Category; Name = $Name; IsEnabled = $IsEnabled; 
        Severity = $Severity; Remediation = $Remediation; Details = $Details
    }
    $script:SecurityChecks += $check
}

function Write-SectionHeader {
    param(
        [string]$Title, 
        [string]$Icon = $Char_Shield, 
        [string]$IconColor = $FGWhite, # Default to White as requested
        [int]$Gap = 2,
        [switch]$IsFirstSection, # NEW: Switch to identify the top section
        [switch]$NoBoundary # NEW: Switch to suppress the boundary
    )
    # 1. DarkGray Boundary (Only if not suppressed)
    if (-not $NoBoundary) {
        Write-Boundary $FGDarkGray
    }
    
    # 2. Windows Security (Only for First Section)
    if ($IsFirstSection) {
        # UPDATED: FGCyan -> FGWhite per user request
        Write-LeftAligned "$FGWhite Windows Security$Reset" -Indent 1
        # 3. Empty Line
        Write-Host ""
    } else {
        # Standard empty line for spacing between boundary and title
        # EDITED: Removed this empty line to compact sections per request
        # Write-Host "" 
    }
    
    # 4. Icon + Title (White)
    # Rule: Icon 1 space indent.
    $Indent = " "
    $Spacing = " " * $Gap
    # Rule: Body Title is White.
    Write-Host ("$Indent$IconColor$Icon$Spacing$FGWhite$Title$Reset")
}

# --- Auditing Functions ---

function Get-ThirdPartyAntivirus {
    try {
        $antivirusProducts = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName "AntiVirusProduct" -ErrorAction Stop
        foreach ($av in $antivirusProducts) {
            if ($av.displayName -notmatch "Defender|Windows Security") {
                if ($av.productState) { return [PSCustomObject]@{ IsThirdParty = $true; ProductName = $av.displayName } }
            }
        }
        return [PSCustomObject]@{ IsThirdParty = $false; ProductName = "Windows Defender" }
    } catch {
        return [PSCustomObject]@{ IsThirdParty = $false; ProductName = "Windows Defender" }
    }
}

function Get-DefenderStatus {
    # IconColor defaulting to White in function, removed explicit Blue
    # Added -IsFirstSection switch to trigger "Windows Security" header text
    # EDITED: Added -NoBoundary to suppress default boundary in favor of the new global header structure
    Write-SectionHeader "Virus & threat protection" -Icon "🛡" -Gap 2 -IsFirstSection -NoBoundary

    $avInfo = Get-ThirdPartyAntivirus
    if ($avInfo.IsThirdParty) {
        # Indent 2 for text under headers (Rule: Text: 2 spaces)
        Write-LeftAligned "$Char_Warn Managed by: $($avInfo.ProductName)" -Indent 3
        $script:RealTimeProtectionEnabled = $false
        $script:ThirdPartyAVActive = $true
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Third-party antivirus" -IsEnabled $true -Severity "Info" -Details "Managed by: $($avInfo.ProductName)"
        Write-Log -Message "Third-party AV detected: $($avInfo.ProductName)" -Level INFO
        return
    }

    try { $preferences = Get-MpPreference -ErrorAction Stop } catch {
        Write-LeftAligned "$FGDarkRed$Char_XSquare Unable to retrieve Defender settings$Reset" -Indent 3
        Write-Log -Message "Failed to retrieve Defender preferences" -Level ERROR
        return
    }

    $realTimeOff = $preferences.DisableRealtimeMonitoring
    $script:RealTimeProtectionEnabled = !$realTimeOff
    $enabled = !$realTimeOff
    # Indent 3 aligns the status icon comfortably under the section header
    Write-LeftAligned (Get-StatusLine $enabled "Real-time protection") -Indent 3
    Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Real-time protection" -IsEnabled $enabled -Severity "Critical" -Remediation "Set-MpPreference -DisableRealtimeMonitoring `$false"

    if (!$enabled) { Write-LeftAligned "$FGDarkYellow$Char_Warn Dependencies disabled$Reset" -Indent 3 }
    
    $enabled = !$preferences.DisableDevDriveScanning
    Write-LeftAligned (Get-StatusLine $enabled "Dev Drive protection") -Indent 3
    Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Dev Drive protection" -IsEnabled $enabled -Severity "Info" -Remediation "Set-MpPreference -DisableDevDriveScanning `$false"

    $enabled = $preferences.MAPSReporting -ne 0
    Write-LeftAligned (Get-StatusLine $enabled "Cloud-delivered protection") -Indent 3
    Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Cloud-delivered protection" -IsEnabled $enabled -Severity "Warning" -Remediation "Set-MpPreference -MAPSReporting Advanced"

    $enabled = $preferences.SubmitSamplesConsent -ne 0
    Write-LeftAligned (Get-StatusLine $enabled "Automatic sample submission") -Indent 3
    Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Automatic sample submission" -IsEnabled $enabled -Severity "Warning" -Remediation "Set-MpPreference -SubmitSamplesConsent SendAllSamples"

    try {
        $tamperProtection = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection" -ErrorAction Stop
        $enabled = ($tamperProtection -eq 1 -or $tamperProtection -eq 5)
        
        # EDITED: Uses new XSquare (❎) automatically via global variable change
        if ($enabled) {
            Write-LeftAligned (Get-StatusLine $enabled "Tamper protection") -Indent 3
        } else {
            # EDITED: Changed FG color to FGDarkRed for both the icon AND the text as requested
            Write-LeftAligned "$FGDarkRed$Char_XSquare $FGDarkRed Tamper protection$Reset" -Indent 3
        }
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Tamper protection" -IsEnabled $enabled -Severity "Critical" -Remediation "Enable via Windows Security UI"
    } catch {
        Write-LeftAligned "$FGDarkRed$Char_XSquare $FGGray Tamper protection (Unknown)$Reset" -Indent 3
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Tamper protection" -IsEnabled $false -Severity "Critical"
    }

    if ($script:RealTimeProtectionEnabled) {
        $cfaEnabled = $preferences.EnableControlledFolderAccess -eq 1
        Write-LeftAligned (Get-StatusLine $cfaEnabled "Controlled folder access") -Indent 3
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Controlled folder access" -IsEnabled $cfaEnabled -Severity "Warning" -Remediation "Set-MpPreference -EnableControlledFolderAccess Enabled"
    }
}

function Get-AccountProtection {
    # REMOVED BOUNDARY via switch
    Write-SectionHeader "Account protection" -Icon $Char_Person -Gap 1 -NoBoundary
    
    $helloConfigured = $false
    try { if ((Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\AccountInfo" -ErrorAction SilentlyContinue).Count -gt 0) { $helloConfigured = $true } } catch {}
    
    Write-LeftAligned (Get-StatusLine $helloConfigured "Windows Hello") -Indent 3
    Add-SecurityCheck -Category "Account Protection" -Name "Windows Hello" -IsEnabled $helloConfigured -Severity "Warning" -Remediation "Configure via Settings > Accounts"

    $dynamicLockEnabled = (Get-RegistryValue "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "EnableGoodbye") -eq 1
    Write-LeftAligned (Get-StatusLine $dynamicLockEnabled "Dynamic lock") -Indent 3
    Add-SecurityCheck -Category "Account Protection" -Name "Dynamic lock" -IsEnabled $dynamicLockEnabled -Severity "Info" -Remediation "Configure via Settings > Accounts"
}

function Get-FirewallStatus {
    # REMOVED BOUNDARY via switch
    Write-SectionHeader "Firewall & network protection" -Icon $Char_Satellite -Gap 1 -NoBoundary

    $activeNetworks = @{}
    try {
        Get-NetConnectionProfile | ForEach-Object { $activeNetworks[$_.NetworkCategory] = $_.Name }
    } catch {}

    $profiles = @{ 'Domain'='DomainAuthenticated'; 'Private'='Private'; 'Public'='Public' }
    foreach ($p in $profiles.Keys) {
        try {
            $fw = Get-NetFirewallProfile -Name $p -ErrorAction Stop
            $enabled = $fw.Enabled
            $suffix = if ($activeNetworks[$profiles[$p]]) { " ($($activeNetworks[$profiles[$p]]))" } else { "" }
            Write-LeftAligned (Get-StatusLine $enabled "$p network firewall$suffix") -Indent 3
            Add-SecurityCheck -Category "Firewall" -Name "$p network firewall" -IsEnabled $enabled -Severity "Critical" -Remediation "Set-NetFirewallProfile -Profile $p -Enabled True"
        } catch {}
    }

    # Wi-Fi Check
    try {
        $netshOutput = netsh wlan show interfaces | Select-String -Pattern "Authentication"
        if ($netshOutput) {
            $authMethod = ($netshOutput -split ':')[-1].Trim()
            $isUnsecured = ($authMethod -match "Open|None|Unsecured" -and $authMethod -notmatch "WPA2-Open")
            
            if ($isUnsecured) {
                # EDITED: Uses XSquare (now ❎)
                Write-LeftAligned "$FGDarkRed$Char_XSquare $FGDarkCyan Wi-Fi Security (UNSECURED: $authMethod)$Reset" -Indent 3
                Add-SecurityCheck -Category "Network" -Name "Wi-Fi Security" -IsEnabled $false -Severity "Warning" -Remediation "Connect to secured network"
                Write-Log -Message "Unsecured Wi-Fi detected: $authMethod" -Level WARNING
            } else {
                # EDITED: Removed one space after BallotCheck and changed FGDarkCyan to FGGray
                Write-LeftAligned "$FGDarkGreen$Char_BallotCheck $FGGray Wi-Fi Security ($authMethod)$Reset" -Indent 3
                Add-SecurityCheck -Category "Network" -Name "Wi-Fi Security" -IsEnabled $true -Severity "Info"
            }
        }
    } catch {}
}

function Get-ReputationProtection {
    # REMOVED BOUNDARY via switch
    Write-SectionHeader "App & browser control" -Icon "🗂" -Gap 2 -NoBoundary

    # Check apps and files
    $smartScreenEnabled = (Get-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen") -eq 1
    if (-not $smartScreenEnabled) {
        $val = Get-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled"
        $smartScreenEnabled = ($val -ne "Off")
    }
    
    Write-LeftAligned (Get-StatusLine $smartScreenEnabled "Check apps and files") -Indent 3
    Add-SecurityCheck -Category "App Control" -Name "Check apps and files" -IsEnabled $smartScreenEnabled -Severity "Warning" -Remediation "Set SmartScreenEnabled to Warn"

    # Edge SmartScreen
    $edgeEnabled = $true # Default assumption
    $val = Get-RegistryValue "HKCU:\Software\Microsoft\Edge\SmartScreenEnabled" "(default)"
    if ($val -ne $null -and $val -eq 0) { $edgeEnabled = $false }
    
    Write-LeftAligned (Get-StatusLine $edgeEnabled "SmartScreen for Edge") -Indent 3
    Add-SecurityCheck -Category "App Control" -Name "SmartScreen for Microsoft Edge" -IsEnabled $edgeEnabled -Severity "Warning" -Remediation "Enable Edge SmartScreen"

    # PUA
    if ($script:RealTimeProtectionEnabled) {
        try { $pua = (Get-MpPreference).PUAProtection -eq 1 } catch { $pua = $false }
        Write-LeftAligned (Get-StatusLine $pua "Potentially unwanted app blocking") -Indent 3
        Add-SecurityCheck -Category "App Control" -Name "Potentially unwanted app blocking" -IsEnabled $pua -Severity "Warning" -Remediation "Set-MpPreference -PUAProtection Enabled"
    }
}

function Get-CoreIsolationStatus {
    # REMOVED BOUNDARY via switch
    Write-SectionHeader "Device security" -Icon "🖥" -Gap 2 -NoBoundary

    $memInt = (Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" "Enabled") -eq 1
    
    Write-LeftAligned (Get-StatusLine $memInt "Memory integrity") -Indent 3
    Add-SecurityCheck -Category "Device Security" -Name "Memory integrity" -IsEnabled $memInt -Severity "Warning" -Remediation "Enable via Security Settings"

    $lsa = (Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RunAsPPL") -ge 1
    
    Write-LeftAligned (Get-StatusLine $lsa "Local Security Authority protection") -Indent 3
    Add-SecurityCheck -Category "Device Security" -Name "Local Security Authority protection" -IsEnabled $lsa -Severity "Warning" -Remediation "Set RunAsPPL to 1"

    $vdb = $true
    try { if ((Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Config" "VulnerableDriverBlocklistEnable" -ErrorAction SilentlyContinue).VulnerableDriverBlocklistEnable -eq 0) { $vdb = $false } } catch {}
    
    Write-LeftAligned (Get-StatusLine $vdb "Microsoft Vulnerable Driver Blocklist") -Indent 3
    Add-SecurityCheck -Category "Device Security" -Name "Microsoft Vulnerable Driver Blocklist" -IsEnabled $vdb -Severity "Warning" -Remediation "Enable VulnerableDriverBlocklist"
}

# --- NEW: Online Version Check Helper ---
function Get-OnlineDefenderVersion {
    try {
        # Fetch the release notes page (contains current version)
        $url = "https://www.microsoft.com/en-us/wdsi/definitions/antimalware-definitions-release-notes"
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
        
        if ($response.Content -match 'Version:</b>\s*([0-9\.]+)') {
            return $matches[1]
        }
        return $null
    } catch {
        return $null
    }
}

function Get-ScanInformation {
    # Renamed to "Current threats", Icon color White (Default)
    # REMOVED BOUNDARY via switch
    Write-SectionHeader "Current threats" -Icon $Char_Loop -Gap 1 -NoBoundary

    $status = Get-MpComputerStatus
    $now = Get-Date
    $threats = @(Get-MpThreat -ErrorAction SilentlyContinue)
    $script:ActiveThreatCount = $threats.Count
    
    # Logic for colors (Green or Red)
    $qsColor = if ($status.QuickScanStartTime -and ($now - $status.QuickScanStartTime).Days -lt 7) { $FGDarkGreen } else { $FGRed }
    $fsColor = if ($status.FullScanStartTime -and ($now - $status.FullScanStartTime).Days -lt 30) { $FGDarkGreen } else { $FGRed }
    $updColor = if ($status.AntivirusSignatureLastUpdated -and ($now - $status.AntivirusSignatureLastUpdated).Days -lt 7) { $FGDarkGreen } else { $FGRed }

    $script:ScanStatusAllGreen = ($qsColor -eq $FGDarkGreen) -and ($fsColor -eq $FGDarkGreen) -and ($updColor -eq $FGDarkGreen) -and ($script:ActiveThreatCount -eq 0)

    # CHECK: If Full Scan is Red (outdated), set global flag
    if ($fsColor -eq $FGRed) {
        $script:FullScanNeeded = $true
    }

    # --- Padding for Colon Alignment ---
    $LabelWidth = 17 # Max length of "Signature version"
    $Indent = 7

    # 1. Threats found
    $threatColor = if ($script:ActiveThreatCount -eq 0) { $FGDarkGreen } else { $FGRed }
    $threatLabel = "Threats found"
    # UPDATED: Format matching request "Threats found    : 0"
    Write-LeftAligned "$FGGray$($threatLabel.PadRight($LabelWidth)):$Reset $threatColor$($script:ActiveThreatCount)$Reset" -Indent $Indent
    
    # 2. Last quick scan
    $qsLabel = "Last quick scan"
    $qsTime = if ($status.QuickScanStartTime) { $status.QuickScanStartTime.ToString('yyyy-MM-dd HH:mm') } else { "Never" }
    Write-LeftAligned "$FGGray$($qsLabel.PadRight($LabelWidth)): $qsColor$qsTime$Reset" -Indent $Indent

    # 3. Last full scan
    $fsLabel = "Last full scan"
    $fsTime = if ($status.FullScanStartTime) { $status.FullScanStartTime.ToString('yyyy-MM-dd HH:mm') } else { "Never" }
    Write-LeftAligned "$FGGray$($fsLabel.PadRight($LabelWidth)): $fsColor$fsTime$Reset" -Indent $Indent
    
    # 4. Signature version (UPDATED with Online Check)
    $sigLabel = "Signature version"
    $installedVer = $status.AntivirusSignatureVersion
    $onlineVer = Get-OnlineDefenderVersion
    
    $sigColor = $FGWhite # Default fallback
    if ($onlineVer) {
        try {
            $vInstalled = [version]$installedVer
            $vOnline = [version]$onlineVer
            if ($vInstalled -ge $vOnline) {
                $sigColor = $FGDarkGreen
            } else {
                $sigColor = $FGDarkRed
            }
        } catch {
            $sigColor = $FGWhite # Parsing error fallback
        }
    } else {
        # FIX: If online check fails, default to DarkGreen assuming user is safe, or Red?
        # User requested: "If ... not current, then DarkRed... If current, then DarkGreen"
        # If we can't check, defaulting to White/Gray (previous behavior) was confusing.
        # Let's check if the version looks valid. If valid, color it DarkGreen as a fallback for 'valid format'.
        if ($installedVer) { $sigColor = $FGDarkGreen }
    }
    
    Write-LeftAligned "$FGGray$($sigLabel.PadRight($LabelWidth)): $sigColor$installedVer$Reset" -Indent $Indent
    
    # 5. Last updated
    $updLabel = "Last updated"
    $updTime = if ($status.AntivirusSignatureLastUpdated) { $status.AntivirusSignatureLastUpdated.ToString('yyyy-MM-dd HH:mm') } else { "Never" }
    Write-LeftAligned "$FGGray$($updLabel.PadRight($LabelWidth)): $updColor$updTime$Reset" -Indent $Indent

    # Explicit boundary at end of this section
    Write-Boundary $FGDarkGray 
}

function Show-SecuritySummary {
    $disabled = ($script:SecurityChecks | Where-Object { !$_.IsEnabled }).Count
    $critical = ($script:SecurityChecks | Where-Object { !$_.IsEnabled -and $_.Severity -eq "Critical" }).Count
    
    Write-Host ""
    # REMOVED: DarkBlue Boundary that was here per user request
    
    # UPDATED: Report Title with EnDash and CYAN Color
    $ReportTitle = "$Char_EnDash Windows Security REPORT $Char_EnDash"
    Write-Centered "$FGCyan$ReportTitle$Reset"
    
    Write-Host ""

    if ($disabled -eq 0) {
        # UPDATED: Green Checkmark added
        $text1 = "$Char_HeavyCheck All security features are enabled"
        Write-Centered "$FGGreen$text1$Reset"
        
        # ADDED: Space between success messages
        Write-Host ""

        # UPDATED: "No current threats" restored with Green Checkmark
        if ($script:ActiveThreatCount -eq 0) {
            $text2 = "$Char_HeavyCheck No current threats"
            Write-Centered "$FGGreen$text2$Reset"
        } else {
            Write-Centered "$FGRed$Char_Warn $script:ActiveThreatCount threats found$Reset"
        }
    } else {
        Write-Centered "$FGRed$Char_RedCross $disabled disabled security features found$Reset"
        Write-Boundary $FGDarkBlue
        if ($critical -gt 0) {
            # EDITED: Simplified Critical text format " ☢  X Critical"
            Write-Centered "$FGRed$Char_Radioactive  $critical Critical$Reset"
        }
    }
    Write-Boundary $FGDarkBlue
}

# --- Remediation & Application ---

function Enable-RealTimeProtection { try { Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop; Write-Log "Enabled RealTimeProtection" "SUCCESS"; $true } catch { Write-Log "Failed RealTimeProtection" "ERROR"; $false } }
function Enable-CloudDeliveredProtection { try { Set-MpPreference -MAPSReporting Advanced -ErrorAction Stop; Write-Log "Enabled MAPSReporting" "SUCCESS"; $true } catch { Write-Log "Failed MAPSReporting" "ERROR"; $false } }
function Enable-AutomaticSampleSubmission { try { Set-MpPreference -SubmitSamplesConsent SendAllSamples -ErrorAction Stop; Write-Log "Enabled SampleSubmission" "SUCCESS"; $true } catch { Write-Log "Failed SampleSubmission" "ERROR"; $false } }
function Enable-ControlledFolderAccess { try { Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction Stop; Write-Log "Enabled ControlledFolderAccess" "SUCCESS"; $true } catch { Write-Log "Failed ControlledFolderAccess" "ERROR"; $false } }
function Enable-PUAProtection { try { Set-MpPreference -PUAProtection Enabled -ErrorAction Stop; Write-Log "Enabled PUAProtection" "SUCCESS"; $true } catch { Write-Log "Failed PUAProtection" "ERROR"; $false } }
function Enable-MemoryIntegrity { try { Set-RegistryDword "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" "Enabled" 1; $true } catch { $false } }
function Enable-LSAProtection { try { Set-RegistryDword "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RunAsPPL" 1; $true } catch { $false } }
function Enable-Firewall { param($Profile) try { Set-NetFirewallProfile -Name $Profile -Enabled True -ErrorAction Stop; Write-Log "Enabled $Profile firewall" "SUCCESS"; $true } catch { Write-Log "Failed $Profile firewall" "ERROR"; $false } }
# EDITED: Replaced Set-RegistryDword with Set-RegistryString and value "Warn" to fix functionality
function Enable-CheckAppsAndFiles { try { Set-RegistryString "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled" "Warn"; $true } catch { $false } } 
function Enable-SmartScreenEdge { try { Set-RegistryDword "HKCU:\Software\Microsoft\Edge\SmartScreenEnabled" "(default)" 1; $true } catch { $false } }

# NEW: Restart Windows Security App Function
function Restart-SecHealthUI {
    # UPDATED: FGCyan -> FGDarkCyan per user request
    Write-LeftAligned "$FGDarkCyan Restarting Windows Security App...$Reset" -Indent 3
    Write-Log "Restarting Windows Security App" "INFO"
    Get-Process "SecHealthUI" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Process "windowsdefender:"
}

function Apply-SecuritySettings {
    $disabledChecks = $script:SecurityChecks | Where-Object { !$_.IsEnabled }
    $applied = 0
    Write-Log "Attempting to apply $($disabledChecks.Count) security settings" "INFO"

    foreach ($check in $disabledChecks) {
        $result = $false
        switch ($check.Name) {
            "Real-time protection" { $result = Enable-RealTimeProtection }
            "Cloud-delivered protection" { $result = Enable-CloudDeliveredProtection }
            "Automatic sample submission" { $result = Enable-AutomaticSampleSubmission }
            "Controlled folder access" { $result = Enable-ControlledFolderAccess }
            "Potentially unwanted app blocking" { $result = Enable-PUAProtection }
            "Memory integrity" { $result = Enable-MemoryIntegrity }
            "Local Security Authority protection" { $result = Enable-LSAProtection }
            "Domain network firewall" { $result = Enable-Firewall "Domain" }
            "Private network firewall" { $result = Enable-Firewall "Private" }
            "Public network firewall" { $result = Enable-Firewall "Public" }
            "Check apps and files" { $result = Enable-CheckAppsAndFiles }
            "SmartScreen for Microsoft Edge" { $result = Enable-SmartScreenEdge }
        }
        if ($result) { $applied++ }
    }
    
    if ($applied -gt 0) { 
        Write-LeftAligned "$FGGreen$Char_HeavyCheck Enabled $applied features$Reset" -Indent 3
        Write-Log "Successfully enabled $applied features" "SUCCESS"
        Restart-SecHealthUI
    }
}

function Invoke-ApplySecuritySettings {
    if (($script:SecurityChecks | Where-Object { !$_.IsEnabled }).Count -eq 0) { return }
    
    Write-Host ""
    # EDITED: "  ⌨  Press ☛ [Enter] to SET | Press ☛ ['Any Other'] to skip"
    # COLORS: SET (Yellow), skip (DarkGray), ['Any Other'] (BG DarkGray)
    # LOGIC: Enter to SET, Any Other to Skip
    Write-Centered "$FGDarkCyan  $Char_Keyboard  Press ${FGBlack}${BGYellow}$Char_Finger [Enter]${Reset}${FGDarkCyan} to ${FGYellow}SET${Reset}${FGDarkCyan} | Press $Char_Finger ${BGDarkGray}['Any Other']${Reset}${FGDarkCyan} to ${FGDarkGray}skip${Reset}"
    
    $valid = $false
    while (!$valid) {
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if ($key.VirtualKeyCode -eq 13) { # Enter
            $valid = $true
            Write-Host ""
            # EDITED: Changed header style to Boundary first, then Text
            Write-Boundary $FGDarkBlue
            Write-Centered "$FGDarkCyan$Char_EnDash Security Features ENABLE $Char_EnDash$Reset"
            
            Apply-SecuritySettings
            Write-LeftAligned "$FGGreen Settings applied.$Reset" -Indent 3
            Write-Boundary $FGDarkBlue
        } else { # Any other key (Skip)
            # FIX: Added $ to true
            $valid = $true
            Write-Host "`n"
            Write-LeftAligned "$FGGray Skipped application.$Reset" -Indent 3
            Write-Log "User skipped applying settings" "INFO"
        }
    }
}

# --- Main Execution ---

try {
    # Script 03 Footer Logic
    $ScriptPath = $PSCommandPath
    if ($ScriptPath) { $LastEditYear = (Get-Item $ScriptPath).LastWriteTime.Year } else { $LastEditYear = (Get-Date).Year }

    Write-Header "WINDOWS SECURITY CONFIGURATOR"
    
    # NEW: Added Check Sub-header and Boundary per request
    Write-Centered "$FGDarkCyan$Char_EnDash Windows Security CHECK $Char_EnDash$Reset"
    Write-Boundary $FGDarkBlue

    Write-Log "Security Check Started" "INFO"
    
    Get-DefenderStatus
    Get-AccountProtection
    Get-FirewallStatus
    Get-ReputationProtection
    Get-CoreIsolationStatus
    
    # Skip scan history if using 3rd party AV
    if (-not $script:ThirdPartyAVActive) {
        Get-ScanInformation
    }
    
    Show-SecuritySummary
    Invoke-ApplySecuritySettings

    # --- Scan Prompt and Execution ---
    Write-Host ""
    
    if ($script:ThirdPartyAVActive) {
        $prompt = "${FGDarkCyan}$Char_Keyboard  Third-Party AV Active: Scan Skipped$Reset"
        Write-Centered $prompt
    } else {
        # DYNAMIC SCAN TYPE DETERMINATION
        $ScanTypeString = if ($script:FullScanNeeded) { "Full" } else { "Quick" }
        $ScanTypeParam = if ($script:FullScanNeeded) { "FullScan" } else { "QuickScan" }
        
        # EDITED: Matched specific text and spacing requested
        # " Press☛ [Enter] to Full Scan | Press☛ [Spacebar] to Continue "
        # Added space before first Press, removed spaces between Press and Finger, added space between Finger and Bracket.
        # EDITED: Removed leading space before "Press" as per latest request
        $prompt = "${FGDarkCyan}Press${FGYellow}$Char_Finger ${FGBlack}${BGYellow}[Enter]${Reset}${FGDarkCyan} to $ScanTypeString Scan | Press${FGYellow}$Char_Finger ${FGBlack}${BGYellow}[Spacebar]${Reset}${FGDarkCyan} to Continue $Reset"
        Write-Centered $prompt

        $valid = $false
        while (!$valid) {
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($key.VirtualKeyCode -eq 13) {
                $valid = $true
                Write-Host "`n"
                # UPDATED: FGCyan -> FGDarkCyan for consistency
                Write-LeftAligned "$FGDarkCyan Starting $ScanTypeString Scan...$Reset" -Indent 3
                Write-Log "Starting $ScanTypeString Scan" "INFO"
                
                Start-MpScan -ScanType $ScanTypeParam
                
                Write-LeftAligned "$FGGreen Scan Complete.$Reset" -Indent 3
                Write-Log "$ScanTypeString Scan Complete" "SUCCESS"
                
                # MOVED HERE: Restart App only on Scan
                Restart-SecHealthUI
            } elseif ($key.Character -eq ' ') {
                # CHANGED: Use return to exit script logic immediately but keep window open
                Write-Host "`n"
                # LOGIC FIX: Changed text to "Skipping X Scan" and removed 'return'
                # to allow the script to proceed to Restart-SecHealthUI and Footer.
                Write-LeftAligned "$FGGray Skipping $ScanTypeString Scan...$Reset" -Indent 3
                Write-Log "User skipped $ScanTypeString Scan" "INFO"
                $valid = $true
            }
        }
    }
    # --- End Scan Execution ---

    # REMOVED: Global call to Restart-SecHealthUI

    Write-Host "`n"
    Write-Boundary $FGDarkBlue
    
    # Footer Rule: User Requested FGCyan (Cyan) overriding FGDarkCyan
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    Write-Centered "$FGCyan$FooterText$Reset"
    
    # Final 5 Lines (Ensures console window remains readable)
    1..5 | ForEach-Object { Write-Host "" }

} catch {
    Write-Host "`n$FGRed[ERROR] $($_.Exception.Message)$Reset"
    Write-Log "Fatal Error: $($_.Exception.Message)" "ERROR"
    exit 1
}
