#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Comprehensive Windows Security Status Checker with Reporting and Remediation
.DESCRIPTION
    Retrieves and displays all Windows Security configurations with visual formatting,
    security scoring, and remediation suggestions.
    
    MATCHED FORMATTING TO scriptRULES-W11.ps1 standards.
    UPDATED: Helper functions unified with Scripts 01 & 03.
    UPDATED: Logging standardized.
    UPDATED: Subsection Headers Left-Aligned.
    UPDATED: Status lines indented by 2 additional spaces (Indent 4).
    UPDATED: Scan History indented & Threat count colored.
    UPDATED: Quick Scan skipped if third-party AV is active.
    UPDATED: Success summary lines manually centered for alignment.
    UPDATED: Scan history body now uses Indent 8 and colon alignment.
    UPDATED: Scan history section skipped entirely if third-party AV is active.

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

# --- Define Unicode Characters & ANSI Colors (Unified) ---
$Char_EmDash      = [char]0x2014
$Char_BallotCheck = [char]0x2611 # ☑
$Char_Check       = [char]0x2713
$Char_Cross       = [char]0x2718
$Char_XSquare     = [char]0x274E # ❎
$Char_Warn        = [char]0x26A0 # ⚠
$Char_Info        = [char]0x2139
$Char_Bell        = [char]::ConvertFromUtf32(0x1F514) # 🔔
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

# Colors
$Esc = [char]0x1B
$Reset = "$Esc[0m"
$Bold = "$Esc[1m"
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

# Standard Separator (Unified)
$SeparatorLine = "$FGDarkBlue" + ([string]$Char_EmDash * 60) + "$Reset"
$DoubleSeparatorLine = "$FGDarkBlue" + ([string]$Char_EmDash * 60) + "$Reset"

# Global Logging Variables
$script:LogPath = "C:\Windows\Temp\Security_$(Get-Date -Format 'yyMMdd').log"

# --- Unified Helper Functions (Shared with 01 & 03) ---

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
    $Width = 60
    $Pad = [Math]::Max(0, [Math]::Floor(($Width - $Title.Length) / 2))
    $Line = "$FGDarkBlue$([string]$Char_EmDash * $Width)$Reset"
    Write-Host $Line
    Write-Host (" " * $Pad + "$Bold$FGCyan$Title$Reset")
    
    $SubText = "Patch-W11"
    $SubIcon = "$Char_Loop"
    # Adjusted for Icon + 2 spaces + Text
    $SubPad = [Math]::Max(0, [Math]::Floor(($Width - ($SubText.Length + 4)) / 2)) 
    
    # Icon first, then 2 spaces, then Text
    Write-Host (" " * $SubPad + "$FGBlue$SubIcon  $Bold$FGDarkCyan$SubText$Reset")
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
    param([bool]$IsEnabled, [string]$Text)
    if ($IsEnabled) { return "$FGDarkGreen$Char_BallotCheck  $FGDarkCyan$Text$Reset" }
    else { return "$FGDarkRed$Char_XSquare $FGDarkCyan$Text$Reset" }
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

# --- Script 02 Specific Helpers ---

# Global variables
$script:SecurityChecks = @()
$script:RealTimeProtectionEnabled = $true
$script:ThirdPartyAVActive = $false # NEW: Explicit flag for AV check
$script:ScanStatusAllGreen = $false
$script:ActiveThreatCount = 0

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
        [string]$IconColor = $FGBlue,
        [int]$Gap = 2
    )
    Write-Host ""
    # Left-Align: Standard 2-space indent
    $Indent = "  "
    $Spacing = " " * $Gap
    Write-Host ("$Indent$IconColor$Icon$Spacing$FGWhite$Title$Reset")
    
    # REMOVED BOUNDARY LINE PER REQUEST
}

# --- Auditing Functions (Updated) ---

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
    # EDITED: Gap 2 spaces (Default)
    Write-SectionHeader "Virus & threat protection" -Icon "🛡" -IconColor $FGBlue -Gap 2

    $avInfo = Get-ThirdPartyAntivirus
    if ($avInfo.IsThirdParty) {
        Write-LeftAligned "$Char_Info Managed by: $($avInfo.ProductName)"
        $script:RealTimeProtectionEnabled = $false
        $script:ThirdPartyAVActive = $true # Set new flag
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Third-party antivirus" -IsEnabled $true -Severity "Info" -Details "Managed by: $($avInfo.ProductName)"
        Write-Log -Message "Third-party AV detected: $($avInfo.ProductName)" -Level INFO
        return
    }

    try { $preferences = Get-MpPreference -ErrorAction Stop } catch {
        Write-LeftAligned "$FGDarkRed$Char_XSquare Unable to retrieve Defender settings$Reset"
        Write-Log -Message "Failed to retrieve Defender preferences" -Level ERROR
        return
    }

    $realTimeOff = $preferences.DisableRealtimeMonitoring
    $script:RealTimeProtectionEnabled = !$realTimeOff
    $enabled = !$realTimeOff
    # UPDATED: Indent 4 for Status Lines
    Write-LeftAligned (Get-StatusLine $enabled "Real-time protection") -Indent 4
    Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Real-time protection" -IsEnabled $enabled -Severity "Critical" -Remediation "Set-MpPreference -DisableRealtimeMonitoring `$false"

    if (!$enabled) { Write-LeftAligned "$FGDarkYellow$Char_Warn Dependencies disabled$Reset" -Indent 4 }
    
    $enabled = !$preferences.DisableDevDriveScanning
    # UPDATED: Indent 4
    Write-LeftAligned (Get-StatusLine $enabled "Dev Drive protection") -Indent 4
    Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Dev Drive protection" -IsEnabled $enabled -Severity "Info" -Remediation "Set-MpPreference -DisableDevDriveScanning `$false"

    $enabled = $preferences.MAPSReporting -ne 0
    # UPDATED: Indent 4
    Write-LeftAligned (Get-StatusLine $enabled "Cloud-delivered protection") -Indent 4
    Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Cloud-delivered protection" -IsEnabled $enabled -Severity "Warning" -Remediation "Set-MpPreference -MAPSReporting Advanced"

    $enabled = $preferences.SubmitSamplesConsent -ne 0
    # UPDATED: Indent 4
    Write-LeftAligned (Get-StatusLine $enabled "Automatic sample submission") -Indent 4
    Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Automatic sample submission" -IsEnabled $enabled -Severity "Warning" -Remediation "Set-MpPreference -SubmitSamplesConsent SendAllSamples"

    try {
        $tamperProtection = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection" -ErrorAction Stop
        $enabled = ($tamperProtection -eq 1 -or $tamperProtection -eq 5)
        # UPDATED: Indent 4
        Write-LeftAligned (Get-StatusLine $enabled "Tamper protection") -Indent 4
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Tamper protection" -IsEnabled $enabled -Severity "Critical" -Remediation "Enable via Windows Security UI"
    } catch {
        # UPDATED: Indent 4
        Write-LeftAligned (Get-StatusLine $false "Tamper protection (Unknown)") -Indent 4
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Tamper protection" -IsEnabled $false -Severity "Critical"
    }

    if ($script:RealTimeProtectionEnabled) {
        $cfaEnabled = $preferences.EnableControlledFolderAccess -eq 1
        # UPDATED: Indent 4
        Write-LeftAligned (Get-StatusLine $cfaEnabled "Controlled folder access") -Indent 4
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Controlled folder access" -IsEnabled $cfaEnabled -Severity "Warning" -Remediation "Set-MpPreference -EnableControlledFolderAccess Enabled"
    }
    
    Write-Boundary $FGDarkBlue
}

function Get-AccountProtection {
    # EDITED: Gap reduced to 1 space
    Write-SectionHeader "Account protection" -Icon $Char_Person -Gap 1
    
    $helloConfigured = $false
    try { if ((Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\AccountInfo" -ErrorAction SilentlyContinue).Count -gt 0) { $helloConfigured = $true } } catch {}
    # UPDATED: Indent 4
    Write-LeftAligned (Get-StatusLine $helloConfigured "Windows Hello") -Indent 4
    Add-SecurityCheck -Category "Account Protection" -Name "Windows Hello" -IsEnabled $helloConfigured -Severity "Warning" -Remediation "Configure via Settings > Accounts"

    $dynamicLockEnabled = (Get-RegistryValue "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "EnableGoodbye") -eq 1
    # UPDATED: Indent 4
    Write-LeftAligned (Get-StatusLine $dynamicLockEnabled "Dynamic lock") -Indent 4
    Add-SecurityCheck -Category "Account Protection" -Name "Dynamic lock" -IsEnabled $dynamicLockEnabled -Severity "Info" -Remediation "Configure via Settings > Accounts"

    Write-Boundary $FGDarkBlue
}

function Get-FirewallStatus {
    # EDITED: Gap reduced to 1 space
    Write-SectionHeader "Firewall & network protection" -Icon $Char_Satellite -Gap 1

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
            # UPDATED: Indent 4
            Write-LeftAligned (Get-StatusLine $enabled "$p network firewall$suffix") -Indent 4
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
                # UPDATED: Indent 4 (Manual Line)
                Write-LeftAligned "$FGDarkRed$Char_XSquare $FGDarkCyan Wi-Fi Security (UNSECURED: $authMethod)$Reset" -Indent 4
                Add-SecurityCheck -Category "Network" -Name "Wi-Fi Security" -IsEnabled $false -Severity "Warning" -Remediation "Connect to secured network"
                Write-Log -Message "Unsecured Wi-Fi detected: $authMethod" -Level WARNING
            } else {
                # UPDATED: Indent 4 (Manual Line)
                Write-LeftAligned "$FGDarkGreen$Char_BallotCheck  $FGDarkCyan Wi-Fi Security ($authMethod)$Reset" -Indent 4
                Add-SecurityCheck -Category "Network" -Name "Wi-Fi Security" -IsEnabled $true -Severity "Info"
            }
        }
    } catch {}
    Write-Boundary $FGDarkBlue
}

function Get-ReputationProtection {
    # EDITED: Gap 2 spaces (Default)
    Write-SectionHeader "App & browser control" -Icon "🗂" -IconColor $FGBlue -Gap 2

    # Check apps and files
    $smartScreenEnabled = (Get-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen") -eq 1
    if (-not $smartScreenEnabled) {
        $val = Get-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled"
        $smartScreenEnabled = ($val -ne "Off")
    }
    # UPDATED: Indent 4
    Write-LeftAligned (Get-StatusLine $smartScreenEnabled "Check apps and files") -Indent 4
    Add-SecurityCheck -Category "App Control" -Name "Check apps and files" -IsEnabled $smartScreenEnabled -Severity "Warning" -Remediation "Set SmartScreenEnabled to Warn"

    # Edge SmartScreen
    $edgeEnabled = $true # Default assumption
    $val = Get-RegistryValue "HKCU:\Software\Microsoft\Edge\SmartScreenEnabled" "(default)"
    if ($val -ne $null -and $val -eq 0) { $edgeEnabled = $false }
    # UPDATED: Indent 4
    Write-LeftAligned (Get-StatusLine $edgeEnabled "SmartScreen for Edge") -Indent 4
    Add-SecurityCheck -Category "App Control" -Name "SmartScreen for Microsoft Edge" -IsEnabled $edgeEnabled -Severity "Warning" -Remediation "Enable Edge SmartScreen"

    # PUA
    if ($script:RealTimeProtectionEnabled) {
        try { $pua = (Get-MpPreference).PUAProtection -eq 1 } catch { $pua = $false }
        # UPDATED: Indent 4
        Write-LeftAligned (Get-StatusLine $pua "Potentially unwanted app blocking") -Indent 4
        Add-SecurityCheck -Category "App Control" -Name "Potentially unwanted app blocking" -IsEnabled $pua -Severity "Warning" -Remediation "Set-MpPreference -PUAProtection Enabled"
    }

    Write-Boundary $FGDarkBlue
}

function Get-CoreIsolationStatus {
    # EDITED: Gap 2 spaces (Default)
    Write-SectionHeader "Device security" -Icon "🖥" -IconColor $FGBlue -Gap 2

    $memInt = (Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" "Enabled") -eq 1
    # UPDATED: Indent 4
    Write-LeftAligned (Get-StatusLine $memInt "Memory integrity") -Indent 4
    Add-SecurityCheck -Category "Device Security" -Name "Memory integrity" -IsEnabled $memInt -Severity "Warning" -Remediation "Enable via Security Settings"

    $lsa = (Get-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RunAsPPL") -ge 1
    # UPDATED: Indent 4
    Write-LeftAligned (Get-StatusLine $lsa "Local Security Authority protection") -Indent 4
    Add-SecurityCheck -Category "Device Security" -Name "Local Security Authority protection" -IsEnabled $lsa -Severity "Warning" -Remediation "Set RunAsPPL to 1"

    $vdb = $true
    try { if ((Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Config" "VulnerableDriverBlocklistEnable" -ErrorAction SilentlyContinue).VulnerableDriverBlocklistEnable -eq 0) { $vdb = $false } } catch {}
    # UPDATED: Indent 4
    Write-LeftAligned (Get-StatusLine $vdb "Microsoft Vulnerable Driver Blocklist") -Indent 4
    Add-SecurityCheck -Category "Device Security" -Name "Microsoft Vulnerable Driver Blocklist" -IsEnabled $vdb -Severity "Warning" -Remediation "Enable VulnerableDriverBlocklist"

    Write-Boundary $FGDarkBlue
}

function Get-ScanInformation {
    # EDITED: Gap reduced to 1 space
    Write-SectionHeader "Scan history" -Icon $Char_Loop -Gap 1

    $status = Get-MpComputerStatus
    $now = Get-Date
    $threats = @(Get-MpThreat -ErrorAction SilentlyContinue)
    $script:ActiveThreatCount = $threats.Count
    
    # Logic for colors
    $qsColor = if ($status.QuickScanStartTime -and ($now - $status.QuickScanStartTime).Days -lt 7) { $FGGreen } else { $FGRed }
    $fsColor = if ($status.FullScanStartTime -and ($now - $status.FullScanStartTime).Days -lt 30) { $FGGreen } else { $FGRed }
    $updColor = if ($status.AntivirusSignatureLastUpdated -and ($now - $status.AntivirusSignatureLastUpdated).Days -lt 7) { $FGGreen } else { $FGRed }

    $script:ScanStatusAllGreen = ($qsColor -eq $FGGreen) -and ($fsColor -eq $FGGreen) -and ($updColor -eq $FGGreen) -and ($script:ActiveThreatCount -eq 0)

    # --- Padding for Colon Alignment ---
    $LabelWidth = 17 # Max length of "Signature version"
    $Indent = 8

    # 1. Threats found
    $threatColor = if ($script:ActiveThreatCount -eq 0) { $FGDarkGreen } else { $FGRed }
    $threatLabel = "Threats found"
    Write-LeftAligned "$FGDarkCyan$($threatLabel.PadRight($LabelWidth)):$Reset $threatColor$($script:ActiveThreatCount)$Reset" -Indent $Indent
    
    # 2. Last quick scan
    $qsLabel = "Last quick scan"
    $qsTime = if ($status.QuickScanStartTime) { $status.QuickScanStartTime.ToString('yyyy-MM-dd HH:mm') } else { "Never" }
    Write-LeftAligned "$FGDarkCyan$($qsLabel.PadRight($LabelWidth)): $qsColor$qsTime$Reset" -Indent $Indent

    # 3. Last full scan
    $fsLabel = "Last full scan"
    $fsTime = if ($status.FullScanStartTime) { $status.FullScanStartTime.ToString('yyyy-MM-dd HH:mm') } else { "Never" }
    Write-LeftAligned "$FGDarkCyan$($fsLabel.PadRight($LabelWidth)): $fsColor$fsTime$Reset" -Indent $Indent
    
    # 4. Signature version
    $sigLabel = "Signature version"
    Write-LeftAligned "$FGDarkCyan$($sigLabel.PadRight($LabelWidth)): $FGWhite$($status.AntivirusSignatureVersion)$Reset" -Indent $Indent
    
    # 5. Last updated
    $updLabel = "Last updated"
    $updTime = if ($status.AntivirusSignatureLastUpdated) { $status.AntivirusSignatureLastUpdated.ToString('yyyy-MM-dd HH:mm') } else { "Never" }
    Write-LeftAligned "$FGDarkCyan$($updLabel.PadRight($LabelWidth)): $updColor$updTime$Reset" -Indent $Indent

    Write-Boundary $FGDarkBlue
}

function Show-SecuritySummary {
    $disabled = ($script:SecurityChecks | Where-Object { !$_.IsEnabled }).Count
    $critical = ($script:SecurityChecks | Where-Object { !$_.IsEnabled -and $_.Severity -eq "Critical" }).Count
    
    Write-Host ""
    Write-Boundary $FGDarkBlue # EmDashLine
    Write-Centered "$FGCyan Windows Security features report:$Reset"
    Write-Host ""

    if ($disabled -eq 0) {
        # Lines below must be manually centered to overcome ANSI width issues in Write-Centered
        
        $text1 = "$Char_WhiteCheck All security features are enabled"
        Write-Centered "$FGGreen$text1$Reset"

        Write-Boundary $FGDarkBlue
        
        $text2 = "No current threats"
        if ($script:ActiveThreatCount -eq 0) {
            Write-Centered "$FGGreen$text2$Reset"
        } else {
            Write-Centered "$FGRed$Char_Warn $script:ActiveThreatCount threats found$Reset"
        }
    } else {
        Write-Centered "$FGRed$Char_Warn $disabled disabled security features found$Reset"
        Write-Boundary $FGDarkBlue
        if ($critical -gt 0) {
            Write-Centered "$FGRed$Char_Warn $critical Critical features disabled$Reset"
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
function Enable-CheckAppsAndFiles { try { Set-RegistryDword "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled" "Warn"; $true } catch { $false } } 
function Enable-SmartScreenEdge { try { Set-RegistryDword "HKCU:\Software\Microsoft\Edge\SmartScreenEnabled" "(default)" 1; $true } catch { $false } }

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
        Write-LeftAligned "$FGGreen$Char_Check Enabled $applied features$Reset"
        Write-Log "Successfully enabled $applied features" "SUCCESS"
        Get-Process "SecHealthUI" -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Process "windowsdefender:"
    }
}

function Invoke-ApplySecuritySettings {
    if (($script:SecurityChecks | Where-Object { !$_.IsEnabled }).Count -eq 0) { return }
    
    Write-Host ""
    Write-Centered "$FGDarkCyan$Char_Keyboard  ${FGYellow}Press ${FGYellow}$Char_Finger Enter${FGDarkCyan} to Apply Settings  |  Press ${FGYellow}$Char_Finger Spacebar${FGDarkCyan} to Exit$Reset"
    
    $valid = $false
    while (!$valid) {
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if ($key.VirtualKeyCode -eq 13) { # Enter
            $valid = $true
            Write-Host ""
            Write-Header "APPLYING SETTINGS"
            Apply-SecuritySettings
            Write-LeftAligned "$FGGreen Settings applied.$Reset"
            Write-Boundary $FGDarkBlue
        } elseif ($key.Character -eq ' ') { # Space
            $valid = true
            Write-Host "`n"
            Write-LeftAligned "$FGGray Skipped application.$Reset"
            Write-Log "User skipped applying settings" "INFO"
        }
    }
}

# --- Main Execution ---

try {
    # Script 03 Footer Logic
    $ScriptPath = $PSCommandPath
    if ($ScriptPath) { $LastEditYear = (Get-Item $ScriptPath).LastWriteTime.Year } else { $LastEditYear = (Get-Date).Year }

    Write-Host "`n"
    Write-Header "WINDOWS SECURITY CONFIGURATOR"
    Write-Log "Security Check Started" "INFO"
    
    Get-DefenderStatus
    Get-AccountProtection
    Get-FirewallStatus
    Get-ReputationProtection
    Get-CoreIsolationStatus
    
    # NEW: Skip scan history if using 3rd party AV
    if (-not $script:ThirdPartyAVActive) {
        Get-ScanInformation
    }
    
    Show-SecuritySummary
    Invoke-ApplySecuritySettings

    # --- Quick Scan Prompt and Execution ---
    Write-Host ""
    
    if ($script:ThirdPartyAVActive) {
        $prompt = "${FGDarkCyan}$Char_Keyboard  Third-Party AV Active: Quick Scan Skipped$Reset"
        Write-Centered $prompt
    } else {
        $prompt = "${FGDarkCyan}$Char_Keyboard  ${FGYellow}Press ${FGYellow}$Char_Finger Enter${FGDarkCyan} to Quick Scan  |  Press ${FGYellow}$Char_Finger Spacebar${FGDarkCyan} to Continue$Reset" # EDITED: Changed 'Close' to 'Continue'
        Write-Centered $prompt

        $valid = $false
        while (!$valid) {
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($key.VirtualKeyCode -eq 13) {
                $valid = $true
                Write-Host "`n"
                Write-LeftAligned "$FGCyan Starting Quick Scan...$Reset"
                Write-Log "Starting Quick Scan" "INFO"
                Start-MpScan -ScanType QuickScan
                Write-LeftAligned "$FGGreen Scan Complete.$Reset"
                Write-Log "Quick Scan Complete" "SUCCESS"
            } elseif ($key.Character -eq ' ') {
                # This breaks the loop, allowing the script to terminate naturally
                # without an explicit 'exit', thereby leaving the host window open.
                $valid = true
            }
        }
    }
    # --- End Quick Scan Execution ---

    Write-Host "`n"
    Write-Boundary $FGDarkBlue
    Write-Centered "$FGDarkCyan$Char_Copyright $LastEditYear, www.AIIT.support$Reset"
    
    # Final 5 Lines (Ensures console window remains readable)
    1..5 | ForEach-Object { Write-Host "" }

} catch {
    Write-Host "`n$FGRed[ERROR] $($_.Exception.Message)$Reset"
    Write-Log "Fatal Error: $($_.Exception.Message)" "ERROR"
    exit 1
}
