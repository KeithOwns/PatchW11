#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Comprehensive Windows Security Status Checker with Reporting and Remediation
.DESCRIPTION
    Retrieves and displays all Windows Security configurations with visual formatting,
    security scoring, export capabilities, and remediation suggestions.
    
    MATCHED FORMATTING TO scriptRULES-W11.ps1 standards.

    Features:
    - Automatic third-party antivirus detection
    - Security score calculation (0-100)
    - Visual console output with color-coded status
    - HTML and JSON export options
    - Remediation suggestions for disabled features
    - Baseline comparison mode

.PARAMETER ExportHtml
    Export the report to an HTML file
.PARAMETER ExportJson
    Export the report to a JSON file
.PARAMETER OutputPath
    Path for exported reports (default: current directory)
.PARAMETER ShowRemediation
    Display PowerShell commands to fix disabled security features
.PARAMETER CompareToBaseline
    Compare current state to a saved baseline JSON file
.PARAMETER SaveAsBaseline
    Save current state as a baseline JSON file
.NOTES
    Requires Administrator privileges
    Encoding: UTF-8 (required for proper display of icons and special characters)
    Compatible with: Windows 10/11 with Windows Defender or third-party antivirus
    Automatically detects: Symantec, McAfee, Trend Micro, Norton, and other major AV products
.EXAMPLE
    .\02_SecurityFeatures_ON-W11.ps1
    Displays the current Windows Security status
#>

param(
    [Parameter(Mandatory = $false)]
    [switch]$ExportHtml,
    
    [Parameter(Mandatory = $false)]
    [switch]$ExportJson,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ".",
    
    [Parameter(Mandatory = $false)]
    [switch]$ShowRemediation,
    
    [Parameter(Mandatory = $false)]
    [string]$CompareToBaseline,
    
    [Parameter(Mandatory = $false)]
    [string]$SaveAsBaseline
)

# --- FIX: Reset environment settings to prevent conflicts from previous scripts ---
Set-StrictMode -Off
$ErrorActionPreference = 'Continue'
# --------------------------------------------------------------------------------

# --- PatchW11 Formatting Standards (Updated to Rules V6.1) ---

# Set console output encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Define Unicode Characters
$Char_HBar        = [char]0x2501 # Not used for logic, kept for reference
$Char_VBar        = [char]0x2502
$Char_Check       = [char]0x2713
$Char_Cross       = [char]0x2718
$Char_Warn        = [char]0x26A0
$Char_Info        = [char]0x2139
$Char_Bell        = [char]::ConvertFromUtf32(0x1F514)
$Char_Gear        = [char]0x2699
$Char_Repeat      = [char]::ConvertFromUtf32(0x1F501) # 🔁
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504) # 🔄
$Char_Shield      = [char]::ConvertFromUtf32(0x1F6E1) # 🛡️
$Char_Person      = [char]::ConvertFromUtf32(0x1F464) # 👤
$Char_Satellite   = [char]::ConvertFromUtf32(0x1F4E1) # 📡
$Char_Globe       = [char]::ConvertFromUtf32(0x1F310) # 🌐
$Char_Lock        = [char]::ConvertFromUtf32(0x1F512) # 🔒
$Char_CardIndex   = [char]::ConvertFromUtf32(0x1F5C2) # 🗂️
$Char_Desktop     = [char]::ConvertFromUtf32(0x1F5A5) # 🖥️
$Char_EmDash      = [char]0x2014 # — (Em Dash)

# Color Guide Characters
$Char_BallotCheck     = [char]0x2611 # ☑
$Char_CrossMark       = [char]::ConvertFromUtf32(0x274C) # ❌
$Char_CrossMarkButton = [char]0x274E # ❎ (Originally $Char_XSquare)
$Char_Square          = [char]0x2B1B # ⬛
$Char_WhiteCheck      = [char]0x2705 # ✅
$Char_XSquare         = [char]0x274E # ❎
$Char_NoEntry         = [char]::ConvertFromUtf32(0x26D4) # 🚫

# ANSI Escape Sequences
$Esc = [char]0x1B
$Reset = "$Esc[0m"
$Bold = "$Esc[1m"
$FGCyan = "$Esc[96m"
$FGDarkCyan = "$Esc[36m"
$FGGreen = "$Esc[92m"
$FGYellow = "$Esc[93m"
$FGDarkYellow = "$Esc[33m"
$FGRed = "$Esc[91m"
$FGDarkRed = "$Esc[31m"
$FGWhite = "$Esc[97m"
$FGGray = "$Esc[37m"
$FGBlue = "$Esc[94m"     # Updated to Light Blue for Icons
$FGDarkBlue = "$Esc[34m" # Updated for Lines
$FGBlack = "$Esc[30m"
$FGDarkGray = "$Esc[90m"
$FGDarkGreen = "$Esc[32m" # Added for Enabled State
$FGDarkMagenta = "$Esc[95m" # Added for Input Info

# Background Styles
$BGTeal     = "$Esc[46m$FGBlack"  # DarkCyan BG
$BGDarkGray = "$Esc[100m$FGBlack" # DarkGray BG

# Standard Separator (Updated to DarkBlue Em Dashes per Rule A.4)
$SeparatorLine = "$FGDarkBlue" + ([string]$Char_EmDash * 60) + "$Reset"

# Double Separator (Updated to DarkBlue Em Dashes)
$DoubleSeparatorLine = "$FGDarkBlue" + ([string]$Char_EmDash * 60) + "$Reset"

# Em Dash Separator (Redundant but kept for compatibility)
$EmDashLine = "$FGDarkBlue" + ([string]$Char_EmDash * 60) + "$Reset"

# --- Helper Functions (Formatted) ---

function Write-StatusIcon {
    <#
    .SYNOPSIS
        Displays a visual status indicator matching 01 script style
    #>
    param(
        [Parameter(Mandatory)]
        [bool]$IsEnabled,
        
        [Parameter(Mandatory = $false)]
        [string]$Severity = "Warning"
    )
    
    if ($IsEnabled) {
        # Enabled: DarkGreen check (Rule: SCRIPT Enabled)
        # Indented by 5 spaces
        Write-Host "     $FGDarkGreen$Char_BallotCheck $Reset" -NoNewline
        Write-Host " " -NoNewline
    } else {
        # Disabled: DarkRed Cross Mark Button (Rule: SCRIPT Disabled)
        # Indented by 5 spaces
        Write-Host "     $FGDarkRed$Char_CrossMarkButton$Reset" -NoNewline
        Write-Host " " -NoNewline
    }
}

function Write-SectionHeader {
    <#
    .SYNOPSIS
        Displays a formatted, centered section header matching 01 script style
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        
        [Parameter(Mandatory = $false)]
        [string]$Icon = $Char_Shield,

        [Parameter(Mandatory = $false)]
        # Updated: Default icon color to Blue (Rule: Body Icon)
        [string]$IconColor = $FGBlue
    )
    
    Write-Host ""
    
    # Calculate Center Padding (Target 60 chars)
    $ContentLength = $Title.Length + $Icon.Length + 1 # +1 for space
    $Padding = [math]::Max(0, [math]::Floor((60 - $ContentLength) / 2))
    $Spaces = " " * $Padding

    # White Header Title (Rule: Body Title)
    Write-Host "$Spaces$IconColor$Icon $FGWhite$Title$Reset"
    
    # Use standard DarkBlue separator
    Write-Host $SeparatorLine
}

# Global variables for tracking results
$script:SecurityChecks = @()
$script:BaselineData = $null
$script:RealTimeProtectionEnabled = $true  # Track if real-time protection is on
$script:ScanStatusAllGreen = $false # Track scan status for summary display

# Security check result class
class SecurityCheck {
    [string]$Category
    [string]$Name
    [bool]$IsEnabled
    [string]$Severity  # Critical, Warning, Info
    [string]$Remediation
    [string]$Details
}

function Get-RegValue {
    <#
    .SYNOPSIS
        Safely retrieves a registry value with error handling
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $false)]
        $DefaultValue
    )
    
    try { 
        return Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction Stop 
    }
    catch { 
        return $DefaultValue 
    }
}

function Add-SecurityCheck {
    <#
    .SYNOPSIS
        Adds a security check result to the global tracking array
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Category,
        
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $true)]
        [bool]$IsEnabled,
        
        [Parameter(Mandatory = $false)]
        [string]$Severity = "Warning",
        
        [Parameter(Mandatory = $false)]
        [string]$Remediation = "",
        
        [Parameter(Mandatory = $false)]
        [string]$Details = ""
    )
    
    $check = [SecurityCheck]@{
        Category = $Category
        Name = $Name
        IsEnabled = $IsEnabled
        Severity = $Severity
        Remediation = $Remediation
        Details = $Details
    }
    
    $script:SecurityChecks += $check
}

function Get-ThirdPartyAntivirus {
    <#
    .SYNOPSIS
        Detects if third-party antivirus software is managing virus protection
    #>
    try {
        $antivirusProducts = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName "AntiVirusProduct" -ErrorAction Stop

        foreach ($av in $antivirusProducts) {
            if ($av.displayName -notmatch "Defender|Windows Security") {
                $productState = $av.productState
                if ($productState) {
                    return [PSCustomObject]@{
                        IsThirdParty = $true
                        ProductName = $av.displayName
                    }
                }
            }
        }
        return [PSCustomObject]@{ IsThirdParty = $false; ProductName = "Windows Defender" }
    } catch {
        return [PSCustomObject]@{ IsThirdParty = $false; ProductName = "Windows Defender" }
    }
}

function Get-DefenderStatus {
    <#
    .SYNOPSIS
        Retrieves and displays Windows Defender virus and threat protection status
    #>
    param()

    # MANUAL HEADER FORMATTING (Specific Request to Swap Lines and Center Align the Main Title)
    
    # 0. ADDED: Separator ABOVE title (DarkBlue)
    Write-Host ([string]$Char_EmDash * 60) -ForegroundColor DarkBlue

    # 1. Print "— Windows Security features —" (Centered) - Header Title is Cyan (Rule)
    $HeaderTitle = "$Char_EmDash Windows Security features $Char_EmDash"
    $HeaderPadding = [math]::Max(0, [math]::Floor((60 - $HeaderTitle.Length) / 2))
    Write-Host (" " * $HeaderPadding) -NoNewline
    Write-Host $HeaderTitle -ForegroundColor Cyan

    # 2. Print Separator (Below title) - UPDATED to DarkGray per request
    Write-Host ([string]$Char_EmDash * 60) -ForegroundColor DarkGray
    
    # 3. Print "🛡 Virus & threat protection" (LEFT ALIGNED per request)
    $Title = " Virus & threat protection "
    $Icon = $Char_Shield
    $IconColor = $FGBlue # Rule: Body Icon
    
    # CHANGED: Left Align with 2 space indent
    $Spaces = "  "
    
    # Rule: Body Title is White
    Write-Host "$Spaces$IconColor$Icon $FGWhite$Title$Reset"

    # Check for third-party antivirus software
    $avInfo = Get-ThirdPartyAntivirus

    if ($avInfo.IsThirdParty) {
        Write-Host "  $Char_Info " -NoNewline -ForegroundColor Cyan
        Write-Host "Managed by third-party software: " -NoNewline -ForegroundColor White
        Write-Host "$($avInfo.ProductName)" -ForegroundColor Green
        Write-Host "    Windows Defender checks skipped (third-party antivirus active)" -ForegroundColor Gray

        $script:RealTimeProtectionEnabled = $false

        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Third-party antivirus" -IsEnabled $true -Severity "Info" `
            -Remediation "N/A - Managed by $($avInfo.ProductName)" `
            -Details "Managed by: $($avInfo.ProductName)"
        return
    }

    try {
        $preferences = Get-MpPreference -ErrorAction Stop
    } catch {
        Write-Host "`n  $FGRed$Char_XSquare Unable to retrieve Windows Defender settings$Reset"
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Defender Module Status" -IsEnabled $false -Severity "Critical" `
            -Remediation "Ensure Windows Defender service is running" `
            -Details "Failed to load Windows Defender preferences"
        return
    }

    $realTimeOff = $preferences.DisableRealtimeMonitoring
    $script:RealTimeProtectionEnabled = !$realTimeOff

    $enabled = !$realTimeOff
    Write-StatusIcon $enabled -Severity "Critical"
    # CHANGED: Text color to DarkCyan (Rule: SCRIPT Text)
    Write-Host "Real-time protection" -ForegroundColor DarkCyan
    Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Real-time protection" -IsEnabled $enabled -Severity "Critical" `
        -Remediation "Set-MpPreference -DisableRealtimeMonitoring `$false" `
        -Details "REQUIRED for: Controlled Folder Access, Behavior Monitoring, Network Protection"
    
    if (!$enabled) {
        # Warning Text: DarkYellow
        Write-Host "  $FGDarkYellow$Char_Warn Several features require Real-time protection$Reset"
    }
    
    $enabled = !$preferences.DisableDevDriveScanning
    if (!$script:RealTimeProtectionEnabled -and $enabled) {
        Write-StatusIcon $false -Severity "Info"
        # CHANGED: Text color to DarkCyan
        Write-Host "Dev Drive protection" -ForegroundColor DarkCyan
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Dev Drive protection" -IsEnabled $false -Severity "Info" `
            -Remediation "Enable Real-time protection first" `
            -Details "Requires Real-time protection"
    } else {
        Write-StatusIcon $enabled -Severity "Info"
        # CHANGED: Text color to DarkCyan
        Write-Host "Dev Drive protection" -ForegroundColor DarkCyan
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Dev Drive protection" -IsEnabled $enabled -Severity "Info" `
            -Remediation "Set-MpPreference -DisableDevDriveScanning `$false" `
            -Details "Scans developer drives for threats"
    }
    
    $enabled = $preferences.MAPSReporting -ne 0
    Write-StatusIcon $enabled -Severity "Warning"
    # CHANGED: Text color to DarkCyan
    Write-Host "Cloud-delivered protection" -NoNewline -ForegroundColor DarkCyan
    if (!$script:RealTimeProtectionEnabled -and $enabled) {
        Write-Host " (limited effectiveness)" -ForegroundColor DarkGray
    } else { Write-Host "" }
    Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Cloud-delivered protection" -IsEnabled $enabled -Severity "Warning" `
        -Remediation "Set-MpPreference -MAPSReporting Advanced" `
        -Details "Enables cloud-based protection"

    $sampleSubmissionConsent = $preferences.SubmitSamplesConsent
    $enabled = $sampleSubmissionConsent -ne 0
    Write-StatusIcon $enabled -Severity "Warning"
    # CHANGED: Text color to DarkCyan
    Write-Host "Automatic sample submission" -ForegroundColor DarkCyan
    Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Automatic sample submission" -IsEnabled $enabled -Severity "Warning" `
        -Remediation "Set-MpPreference -SubmitSamplesConsent SendAllSamples" `
        -Details "Sends suspicious files to Microsoft"

    try {
        $tamperProtection = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection" -ErrorAction Stop
        $enabled = ($tamperProtection -eq 1 -or $tamperProtection -eq 5)
        Write-StatusIcon $enabled -Severity "Critical"
        # CHANGED: Text color to DarkCyan
        Write-Host "Tamper protection" -ForegroundColor DarkCyan
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Tamper protection" -IsEnabled $enabled -Severity "Critical" `
            -Remediation "Enable via Windows Security UI" `
            -Details "Prevents malicious apps from changing settings"
    } catch {
        Write-Host " ? " -NoNewline -ForegroundColor Yellow
        # CHANGED: Text color to DarkCyan
        Write-Host "Tamper protection (Unable to determine)" -ForegroundColor DarkCyan
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Tamper protection" -IsEnabled $false -Severity "Critical" `
            -Details "Unable to determine status"
    }

    if ($script:RealTimeProtectionEnabled) {
        $cfaEnabled = $preferences.EnableControlledFolderAccess -eq 1
        Write-StatusIcon $cfaEnabled -Severity "Warning"
        # CHANGED: Text color to DarkCyan
        Write-Host "Controlled folder access" -ForegroundColor DarkCyan
        Add-SecurityCheck -Category "Virus & Threat Protection" -Name "Controlled folder access" -IsEnabled $cfaEnabled -Severity "Warning" `
            -Remediation "Set-MpPreference -EnableControlledFolderAccess Enabled" `
            -Details "Protects important folders from ransomware"
    }

    # ADDED: Separator line at the end of the section (divides from Account Protection)
    Write-Host $SeparatorLine
}

function Get-AccountProtection {
    param()
    
    # MANUAL HEADER FORMATTING (Matched to 'Virus & threat protection')
    $Title = "Account protection "
    $Icon = $Char_Person
    $IconColor = $FGBlue # Rule: Body Icon
    $Spaces = "  "
    
    Write-Host "$Spaces$IconColor$Icon $FGWhite$Title$Reset"
    
    $helloConfigured = $false
    try {
        $accountInfo = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\AccountInfo" -ErrorAction Stop
        if ($accountInfo.Count -gt 0) { $helloConfigured = $true }
    } catch { }
    
    Write-StatusIcon $helloConfigured -Severity "Warning"
    # CHANGED: Text color to DarkCyan
    Write-Host "Windows Hello" -ForegroundColor DarkCyan
    Add-SecurityCheck -Category "Account Protection" -Name "Windows Hello" -IsEnabled $helloConfigured -Severity "Warning" `
        -Remediation "Configure via Settings > Accounts" `
        -Details "Biometric authentication"

    $dynamicLockEnabled = $false
    try {
        $dynamicLock = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "EnableGoodbye" -ErrorAction Stop
        if ($dynamicLock -eq 1) { $dynamicLockEnabled = $true }
    } catch { }
    
    Write-StatusIcon $dynamicLockEnabled -Severity "Info"
    # CHANGED: Text color to DarkCyan
    Write-Host "Dynamic lock" -ForegroundColor DarkCyan
    Add-SecurityCheck -Category "Account Protection" -Name "Dynamic lock" -IsEnabled $dynamicLockEnabled -Severity "Info" `
        -Remediation "Configure via Settings > Accounts > Dynamic lock" `
        -Details "Locks PC when paired device leaves range"

    $userSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $enrolledFactors = 0
    try { 
        $enrolledFactors = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\AccountInfo\$userSID" -Name "EnrolledFactors" -ErrorAction SilentlyContinue 
    } catch { }
    
    $enabled = $enrolledFactors -eq 2
    Write-StatusIcon $enabled -Severity "Info"
    # CHANGED: Text color to DarkCyan
    Write-Host "Facial recognition" -ForegroundColor DarkCyan
    Add-SecurityCheck -Category "Account Protection" -Name "Facial recognition" -IsEnabled $enabled -Severity "Info" `
        -Remediation "Configure via Settings > Accounts" `
        -Details "Face recognition for sign-in"

    # ADDED: Separator line at the end of the section (divides from Firewall)
    Write-Host $SeparatorLine
}

function Get-FirewallStatus {
    param()
    
    # MANUAL HEADER FORMATTING (Matched to previous sections)
    $Title = "Firewall & network protection"
    $Icon = $Char_Satellite
    $IconColor = $FGBlue # Rule: Body Icon
    $Spaces = "  "
    
    Write-Host "$Spaces$IconColor$Icon $FGWhite$Title$Reset"
    
    $activeNetworks = @{}
    try {
        $profiles = Get-NetConnectionProfile -ErrorAction Stop
        foreach ($profile in $profiles) {
            $profileName = switch ($profile.NetworkCategory) {
                'DomainAuthenticated' { 'Domain' }
                'Private'             { 'Private' }
                'Public'              { 'Public' }
            }
            if ($profileName) { $activeNetworks[$profileName] = $profile.Name }
        }
    } catch { }

    function Test-FirewallProfile {
        param([string]$Name, [string]$DisplayName)
        try {
            $profile = Get-NetFirewallProfile -Name $Name -ErrorAction Stop
            $enabled = $profile.Enabled
            $networkName = $activeNetworks[$Name]
            $suffix = ""
            if ($networkName) { $suffix = " ($networkName)" }

            Write-StatusIcon $enabled -Severity "Critical"
            # CHANGED: Text color to DarkCyan
            Write-Host "$DisplayName network" -NoNewline -ForegroundColor DarkCyan
            
            # UPDATED: Domain/Suffix text color to Gray per request
            Write-Host $suffix -ForegroundColor Gray
            
            Add-SecurityCheck -Category "Firewall & Network Protection" -Name "$DisplayName network firewall" -IsEnabled $enabled -Severity "Critical" `
                -Remediation "Set-NetFirewallProfile -Profile $Name -Enabled True" `
                -Details "Firewall for $DisplayName profile"
        } catch {
            Write-Host " ? " -NoNewline -ForegroundColor Yellow
            # CHANGED: Text color to DarkCyan
            Write-Host "$DisplayName network (Unknown)" -ForegroundColor DarkCyan
            Add-SecurityCheck -Category "Firewall & Network Protection" -Name "$DisplayName network firewall" -IsEnabled $false -Severity "Critical" `
                -Details "Unable to determine status"
        }
    }

    Test-FirewallProfile -Name Domain -DisplayName "Domain"
    Test-FirewallProfile -Name Private -DisplayName "Private"
    Test-FirewallProfile -Name Public -DisplayName "Public"

    # --- INTEGRATED WI-FI SECURITY CHECK ---
    try {
        # Get WLAN details filtering for Authentication
        $netshOutput = netsh wlan show interfaces | Select-String -Pattern "Authentication"
        
        if ($netshOutput) {
            $authMethod = $netshOutput -split ':' | Select-Object -Last 1 | ForEach-Object { $_.Trim() }
            
            # Check for unsecured (Open, None, Unsecured)
            # Exclude "WPA2-Open" which some drivers report for WPA2
            $isUnsecured = ($authMethod -match "Open|None|Unsecured" -and $authMethod -notmatch "WPA2-Open")
            
            if ($isUnsecured) {
                # UPDATED: Demoted from Critical to Warning as requested
                Write-StatusIcon $false -Severity "Warning"
                # CHANGED: Text color to DarkCyan
                Write-Host "Wi-Fi Security" -NoNewline -ForegroundColor DarkCyan
                Write-Host " (UNSECURED: $authMethod)" -ForegroundColor Red
                
                # UPDATED: Severity set to Warning
                Add-SecurityCheck -Category "Firewall & Network Protection" -Name "Wi-Fi Security" -IsEnabled $false -Severity "Warning" `
                    -Remediation "Connect to a secured network (WPA2/WPA3)" `
                    -Details "Current Wi-Fi network ($authMethod) is unsecured"
            } else {
                # Secure
                Write-StatusIcon $true -Severity "Info"
                # CHANGED: Text color to DarkCyan
                Write-Host "Wi-Fi Security" -NoNewline -ForegroundColor DarkCyan
                # CHANGED: Text color to DarkCyan for secure networks as requested
                Write-Host " ($authMethod)" -ForegroundColor DarkCyan
                
                Add-SecurityCheck -Category "Firewall & Network Protection" -Name "Wi-Fi Security" -IsEnabled $true -Severity "Info" `
                    -Remediation "" `
                    -Details "Connected to secured Wi-Fi: $authMethod"
            }
        }
        # If no output, likely no active Wi-Fi connection, skip silently or log info
    } catch {
        # Silent fail for network check to avoid clutter
    }
    
    # ADDED: Separator line at the end of the section (divides from Reputation)
    Write-Host $SeparatorLine
}

function Get-ReputationProtection {
    param()

    # MANUAL HEADER FORMATTING (Matched to previous sections)
    $Title = " App & browser control"
    $Icon = $Char_CardIndex
    $IconColor = $FGBlue # Rule: Body Icon
    $Spaces = "  "
    
    Write-Host "$Spaces$IconColor$Icon $FGWhite$Title$Reset"
    
    $preferences = $null
    if ($script:RealTimeProtectionEnabled) {
        try { $preferences = Get-MpPreference -ErrorAction Stop } catch { }
    }

    # Check apps and files
    $policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $userPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    $enabled = $false
    $controlMethod = "Unknown"

    $policyValue = Get-ItemProperty -Path $policyPath -Name "EnableSmartScreen" -ErrorAction SilentlyContinue
    if ($null -ne $policyValue) {
        $controlMethod = "Group Policy"
        $enabled = $policyValue.EnableSmartScreen -eq 1
    } else {
        $userValue = Get-ItemProperty -Path $userPath -Name "SmartScreenEnabled" -ErrorAction SilentlyContinue
        $controlMethod = "Local Setting"
        if ($null -ne $userValue -and $userValue.SmartScreenEnabled -eq "Off") { $enabled = $false } else { $enabled = $true }
    }
    
    Write-StatusIcon $enabled -Severity "Warning"
    # CHANGED: Text color to DarkCyan
    Write-Host "Check apps and files" -ForegroundColor DarkCyan
    # CHANGED: Category name to "App & browser control"
    Add-SecurityCheck -Category "App & browser control" -Name "Check apps and files" -IsEnabled $enabled -Severity "Warning" `
        -Remediation "Set-ItemProperty -Path '$userPath' -Name 'SmartScreenEnabled' -Value 'Warn'" `
        -Details "SmartScreen checks downloads"
    
    $checkAppsAndFilesEnabled = $enabled

    # SmartScreen for Edge
    $RegPath_MachinePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    $RegPath_UserPolicy    = "HKCU:\SOFTWARE\Policies\Microsoft\Edge"
    $RegPath_UserSetting   = "HKCU:\Software\Microsoft\Edge\SmartScreenEnabled"
    $enabled = $false
    $IsConfigured = $false

    if (Test-Path $RegPath_MachinePolicy) {
        $val = Get-ItemProperty -Path $RegPath_MachinePolicy -Name "SmartScreenEnabled" -ErrorAction SilentlyContinue
        if ($null -ne $val) { $IsConfigured = $true; $enabled = $val.SmartScreenEnabled -eq 1 }
    }
    if (-not $IsConfigured -and (Test-Path $RegPath_UserPolicy)) {
        $val = Get-ItemProperty -Path $RegPath_UserPolicy -Name "SmartScreenEnabled" -ErrorAction SilentlyContinue
        if ($null -ne $val) { $IsConfigured = $true; $enabled = $val.SmartScreenEnabled -eq 1 }
    }
    if (-not $IsConfigured -and (Test-Path $RegPath_UserSetting)) {
        $val = Get-ItemProperty -Path $RegPath_UserSetting -Name "(default)" -ErrorAction SilentlyContinue
        if ($null -ne $val) { $IsConfigured = $true; $enabled = $val.'(default)' -eq 1 }
    }
    if (-not $IsConfigured) { $enabled = $true } # Default ON

    Write-StatusIcon $enabled -Severity "Warning"
    # CHANGED: Text color to DarkCyan
    Write-Host "SmartScreen for Microsoft Edge" -ForegroundColor DarkCyan
    # CHANGED: Category name to "App & browser control"
    Add-SecurityCheck -Category "App & browser control" -Name "SmartScreen for Microsoft Edge" -IsEnabled $enabled -Severity "Warning" `
        -Remediation "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Edge\SmartScreenEnabled' -Name '(default)' -Value 1" `
        -Details "SmartScreen for Edge"

    $smartScreenEdgeEnabled = $enabled

    # PUA Protection
    if ($script:RealTimeProtectionEnabled -and $smartScreenEdgeEnabled) {
        $enabled = $false
        if ($preferences) { $enabled = $preferences.PUAProtection -eq 1 }
        Write-StatusIcon $enabled -Severity "Warning"
        # Renamed as requested
        # CHANGED: Text color to DarkCyan
        Write-Host "Potentially unwanted app blocking" -ForegroundColor DarkCyan
        # CHANGED: Category name to "App & browser control"
        Add-SecurityCheck -Category "App & browser control" -Name "Potentially unwanted app blocking" -IsEnabled $enabled -Severity "Warning" `
            -Remediation "Set-MpPreference -PUAProtection Enabled" `
            -Details "Blocks potentially unwanted apps"
    }

    # Store Apps
    $storeSmartScreen = Get-RegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -DefaultValue 1
    $enabled = $storeSmartScreen -ne 0
    Write-StatusIcon $enabled -Severity "Info"
    # CHANGED: Text color to DarkCyan
    Write-Host "SmartScreen for Microsoft Store apps" -ForegroundColor DarkCyan
    # CHANGED: Category name to "App & browser control"
    Add-SecurityCheck -Category "App & browser control" -Name "SmartScreen for Microsoft Store apps" -IsEnabled $enabled -Severity "Info" `
        -Remediation "Set registry EnableWebContentEvaluation to 1" `
        -Details "SmartScreen for Store apps"
        
    # ADDED: Separator line at the end of the section (divides from Core Isolation)
    Write-Host $SeparatorLine
}

function Get-EdgePUABlockDownloadsEnabled {
    param()
    try {
        $policyVal = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'SmartScreenPuaEnabled' -ErrorAction Stop
        if ($null -ne $policyVal) { return ($policyVal -ne 0) }
    } catch { }
    try {
        $userNamed = Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Edge' -Name 'SmartScreenPuaEnabled' -ErrorAction Stop
        if ($null -ne $userNamed) { return ($userNamed -ne 0) }
    } catch { }
    try {
        $edgeSmartScreen = Get-RegValue -Path "HKCU:\Software\Microsoft\Edge\SmartScreen" -Name "Enabled" -DefaultValue 1
        if ($edgeSmartScreen -eq 0) { return $false }
    } catch { }
    return $false
}

function Get-CoreIsolationStatus {
    param()
    
    # MANUAL HEADER FORMATTING (Matched to previous sections)
    $Title = " Device security"
    $Icon = $Char_Desktop
    $IconColor = $FGBlue # Rule: Body Icon
    $Spaces = "  "
    
    Write-Host "$Spaces$IconColor$Icon $FGWhite$Title$Reset"
    
    $memIntegrity = Get-RegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -DefaultValue 0
    $enabled = $memIntegrity -eq 1
    Write-StatusIcon $enabled -Severity "Warning"
    # CHANGED: Text color to DarkCyan
    Write-Host "Memory integrity" -ForegroundColor DarkCyan
    # CHANGED: Category name to "Device security"
    Add-SecurityCheck -Category "Device security" -Name "Memory integrity" -IsEnabled $enabled -Severity "Warning" `
        -Remediation "Enable via Windows Security > Device security" `
        -Details "Hardware-based code integrity"

    $kernelStackProt = Get-RegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks" -Name "Enabled" -DefaultValue 0
    $enabled = $kernelStackProt -ge 1
    Write-StatusIcon $enabled -Severity "Info"
    # CHANGED: Text color to DarkCyan
    Write-Host "Kernel-mode Hardware-enforced Stack" -ForegroundColor DarkCyan
    # CHANGED: Category name to "Device security"
    Add-SecurityCheck -Category "Device security" -Name "Kernel-mode Hardware-enforced Stack" -IsEnabled $enabled -Severity "Info" `
        -Remediation "Requires compatible CPU and Win11 22H2+" `
        -Details "Hardware-based kernel stack protection"

    $lsaProtection = Get-RegValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -DefaultValue 0
    $enabled = $lsaProtection -ge 1
    Write-StatusIcon $enabled -Severity "Warning"
    # CHANGED: Text color to DarkCyan
    Write-Host "Local Security Authority protection" -ForegroundColor DarkCyan
    # CHANGED: Category name to "Device security"
    Add-SecurityCheck -Category "Device security" -Name "Local Security Authority protection" -IsEnabled $enabled -Severity "Warning" `
        -Remediation "Set registry RunAsPPL to 1" `
        -Details "Protects LSA process"

    $vdbRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Config"
    $enabled = $false
    try {
        $vdbValue = Get-ItemProperty -Path $vdbRegPath -Name "VulnerableDriverBlocklistEnable" -ErrorAction Stop
        if ($vdbValue.VulnerableDriverBlocklistEnable -eq 1) { $enabled = $true }
    } catch {
        # On modern systems, typically enabled by default if key missing
        $enabled = $true
    }

    Write-StatusIcon $enabled -Severity "Warning"
    # CHANGED: Text color to DarkCyan
    Write-Host "Microsoft Vulnerable Driver Blocklist" -ForegroundColor DarkCyan
    # CHANGED: Category name to "Device security"
    Add-SecurityCheck -Category "Device security" -Name "Microsoft Vulnerable Driver Blocklist" -IsEnabled $enabled -Severity "Warning" `
        -Remediation "Set VulnerableDriverBlocklistEnable to 1" `
        -Details "Blocks known vulnerable drivers"
        
    # ADDED: Separator line at the end of the section (divides from Scan Info or Summary)
    Write-Host $SeparatorLine
}

function Get-ScanInformation {
    param()

    $status = Get-MpComputerStatus
    $now = Get-Date

    # ADDED: Check for active threats
    $threats = @(Get-MpThreat -ErrorAction SilentlyContinue)
    $script:ActiveThreatCount = $threats.Count

    $quickScanColor = "Red"; $quickScanTime = $status.QuickScanStartTime
    if ($quickScanTime) { if (($now - $quickScanTime).Days -lt 7) { $quickScanColor = "Green" } elseif (($now - $quickScanTime).Days -lt 30) { $quickScanColor = "Yellow" } }

    $fullScanColor = "Red"; $fullScanTime = $status.FullScanStartTime
    if ($fullScanTime) { if (($now - $fullScanTime).Days -lt 30) { $fullScanColor = "Green" } }

    $lastUpdateColor = "Red"; $lastUpdatedTime = $status.AntivirusSignatureLastUpdated
    if ($lastUpdatedTime) { if (($now - $lastUpdatedTime).Days -lt 7) { $lastUpdateColor = "Green" } }

    # UPDATED: AllGreen logic now includes Threat Count check
    $allGreen = ($quickScanColor -eq "Green") -and ($fullScanColor -eq "Green") -and ($lastUpdateColor -eq "Green") -and ($script:ActiveThreatCount -eq 0)
    $script:ScanStatusAllGreen = $allGreen

    # MANUAL HEADER FORMATTING (Matched to previous sections)
    $Title = "Scan history"
    $Icon = $Char_Loop
    $IconColor = $FGBlue # Rule: Body Icon
    $Spaces = "  "
    
    Write-Host "$Spaces$IconColor$Icon $FGWhite$Title$Reset"

    # ADDED: Threats found line
    if ($script:ActiveThreatCount -gt 0) {
        Write-Host "  Threats found:        " -NoNewline -ForegroundColor Gray
        Write-Host "$script:ActiveThreatCount" -ForegroundColor Red
    } else {
        Write-Host "  Threats found:        " -NoNewline -ForegroundColor Gray
        Write-Host "0" -ForegroundColor Green
    }

    if ($quickScanTime) {
        # Text color is Gray (System Text)
        Write-Host "  Last quick scan:      " -NoNewline -ForegroundColor Gray
        Write-Host "$($quickScanTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor $quickScanColor
    } else {
        # Text color is Gray
        Write-Host "  Last quick scan:      " -NoNewline -ForegroundColor Gray
        Write-Host "-" -ForegroundColor DarkGray
    }

    if ($fullScanTime) {
        # Text color is Gray
        Write-Host "  Last full scan:       " -NoNewline -ForegroundColor Gray
        Write-Host "$($fullScanTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor $fullScanColor
    } else {
        # Text color is Gray
        Write-Host "  Last full scan:       " -NoNewline -ForegroundColor Gray
        Write-Host "-" -ForegroundColor DarkGray
    }

    # Text color is Gray
    Write-Host "  Signature version:    " -NoNewline -ForegroundColor Gray
    Write-Host $status.AntivirusSignatureVersion -ForegroundColor White

    if ($lastUpdatedTime) {
        # Text color is Gray
        Write-Host "  Last updated:         " -NoNewline -ForegroundColor Gray
        Write-Host "$($lastUpdatedTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor $lastUpdateColor
    } else {
        # Text color is Gray
        Write-Host "  Last updated:         " -NoNewline -ForegroundColor Gray
        Write-Host "-" -ForegroundColor DarkGray
    }
    
    # ADDED: Separator line at the end of the section
    Write-Host $SeparatorLine
}

function Get-SecurityScore {
    param()
    $totalChecks = $script:SecurityChecks.Count
    if ($totalChecks -eq 0) { return 0 }
    
    $weightedScore = 0; $maxWeight = 0
    foreach ($check in $script:SecurityChecks) {
        $weight = switch ($check.Severity) { "Critical" { 3 } "Warning" { 2 } default { 1 } }
        $maxWeight += $weight
        if ($check.IsEnabled) { $weightedScore += $weight }
    }
    if ($maxWeight -eq 0) { return 0 }
    return [math]::Round(($weightedScore / $maxWeight) * 100)
}

function Show-SecuritySummary {
    param()
    
    $score = Get-SecurityScore
    $enabled = ($script:SecurityChecks | Where-Object { $_.IsEnabled }).Count
    $disabled = ($script:SecurityChecks | Where-Object { !$_.IsEnabled }).Count
    $critical = ($script:SecurityChecks | Where-Object { !$_.IsEnabled -and $_.Severity -eq "Critical" }).Count
    
    Write-Host "`n" -NoNewline
    
    if ($disabled -eq 0) {
        # All enabled state - NEW CENTERED FORMAT v3
        
        # 1. Em Dash Separator (REPLACED HYPHENS with DarkBlue EmDashes)
        Write-Host $EmDashLine
        
        # 2. Header Text: "Windows Security features report:" (Centered) - Cyan (Header Title)
        $text1 = "Windows Security features report:"
        $pad1 = [math]::Max(0, [math]::Floor((60 - $text1.Length) / 2))
        Write-Host (" " * $pad1) -NoNewline
        Write-Host $text1 -ForegroundColor Cyan
        
        # 3. Empty Line
        Write-Host ""
        
        # 4. Status Text 1: "All security features are enabled" (Centered)
        # UPDATED: Added "are" to text
        $text2 = "All security features are enabled"
        $pad2 = [math]::Max(0, [math]::Floor((60 - $text2.Length) / 2))
        # Reduce padding slightly to account for the checkmark width
        $pad2 = [math]::Max(0, $pad2 - 2) 
        Write-Host (" " * $pad2) -NoNewline
        # Checkmark icon (Green)
        Write-Host "$FGGreen$Char_WhiteCheck $text2$Reset"
        
        # REMOVED: "0 disabled security features found" line as requested
        
        # 5. Double Separator (DarkBlue)
        Write-Host $DoubleSeparatorLine
        
        # 6. Threat Text: "No current threats" OR "Threats found" (Centered)
        if ($script:ScanStatusAllGreen -and $script:RealTimeProtectionEnabled) {
            $text3 = "No current threats"
            $pad3 = [math]::Max(0, [math]::Floor((60 - $text3.Length) / 2))
            Write-Host (" " * $pad3) -NoNewline
            Write-Host "$FGGreen$text3$Reset"
        } elseif ($script:ActiveThreatCount -gt 0) {
            # ADDED: Threat warning even if features are enabled
            $text3 = "$Char_Warn  $script:ActiveThreatCount threats found"
            $pad3 = [math]::Max(0, [math]::Floor((60 - $text3.Length) / 2))
            Write-Host (" " * $pad3) -NoNewline
            Write-Host "$text3" -ForegroundColor Red
        }
        
        # 7. Bottom Standard Separator (DarkBlue)
        Write-Host $SeparatorLine

    } else {
        # Mixed state (Disabled features found)
        
        # 1. Em Dash Separator
        Write-Host $EmDashLine
        
        # 2. Header Text: "Windows Security features report:" (Centered) - Cyan
        $text1 = "Windows Security features report:"
        $pad1 = [math]::Max(0, [math]::Floor((60 - $text1.Length) / 2))
        Write-Host (" " * $pad1) -NoNewline
        Write-Host $text1 -ForegroundColor Cyan
        
        # 3. Empty Line
        Write-Host ""
        
        # 4. Status Text: "⚠  X disabled security features found" (Centered)
        $msgColor = "Red"
        
        # UPDATED: Check specifically for Wi-Fi Security failure
        $wiFiCheck = $script:SecurityChecks | Where-Object { $_.Name -eq "Wi-Fi Security" -and !$_.IsEnabled }
        
        if ($disabled -eq 1 -and $null -ne $wiFiCheck) {
            # Special message for Unsecure Wi-Fi
            $text2 = "$Char_Warn  Connected to unsecure Wi-Fi"
            $msgColor = "DarkYellow"
        } elseif ($disabled -eq 1) {
            # Added extra space after $Char_Warn
            $text2 = "$Char_Warn  1 disabled security feature found"
        } else {
            # Added extra space after $Char_Warn
            $text2 = "$Char_Warn  $disabled disabled security features found"
        }

        $pad2 = [math]::Max(0, [math]::Floor((60 - $text2.Length) / 2))
        Write-Host (" " * $pad2) -NoNewline
        Write-Host $text2 -ForegroundColor $msgColor
        
        # ADDED: Threat warning for mixed state
        if ($script:ActiveThreatCount -gt 0) {
            Write-Host ""
            $textThreats = "$Char_Warn  $script:ActiveThreatCount threats found"
            $padThreats = [math]::Max(0, [math]::Floor((60 - $textThreats.Length) / 2))
            Write-Host (" " * $padThreats) -NoNewline
            Write-Host "$textThreats" -ForegroundColor Red
        }

        # 5. Double Separator (DarkBlue)
        Write-Host $DoubleSeparatorLine
    }

    if ($critical -gt 0) {
        # UPDATED: Critical summary format and color as requested
        if ($critical -eq 1) {
            # Singular case handling
            Write-Host "  $Char_Warn  $critical Critical security feature is disabled" -ForegroundColor Red
        } else {
            # Plural case matching the request
            Write-Host "  $Char_Warn  $critical Critical security features are disabled" -ForegroundColor Red
        }
    } 
    # Removed empty else block logic that printed empty line or separator again
}

function Show-RemediationSteps {
    param()
    $disabledChecks = $script:SecurityChecks | Where-Object { !$_.IsEnabled -and $_.Remediation -ne "" }
    if ($disabledChecks.Count -eq 0) { return }
    
    Write-Host "`n$Char_Gear REMEDIATION STEPS" -ForegroundColor DarkGreen
    Write-Host $SeparatorLine
    Write-Host "Run the following commands to enable disabled features:`n" -ForegroundColor Gray
    
    $criticalChecks = $disabledChecks | Where-Object { $_.Severity -eq "Critical" }
    if ($criticalChecks.Count -gt 0) {
        Write-Host "CRITICAL:" -ForegroundColor Red
        foreach ($check in $criticalChecks) {
            Write-Host "  # $($check.Name)" -ForegroundColor Gray
            Write-Host "  $($check.Remediation)" -ForegroundColor Yellow
            Write-Host ""
        }
    }
    
    $warningChecks = $disabledChecks | Where-Object { $_.Severity -eq "Warning" }
    if ($warningChecks.Count -gt 0) {
        Write-Host "RECOMMENDED:" -ForegroundColor Yellow
        foreach ($check in $warningChecks) {
            Write-Host "  # $($check.Name)" -ForegroundColor Gray
            Write-Host "  $($check.Remediation)" -ForegroundColor White
            Write-Host ""
        }
    }
}

# --- Enabling Functions (Required for Apply-SecuritySettings) ---

function Enable-RealTimeProtection {
    try {
        Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Enable-TamperProtection {
    # UPDATED: Specific formatting as requested
    Write-Host "     $FGDarkRed$Char_CrossMark Tamper protection NOT ENABLED$Reset"
    
    # Mixed color output for the warning line
    Write-Host " $Char_Bell Requires Manual Enablement (" -NoNewline -ForegroundColor Yellow
    Write-Host "Windows Security $Char_Shield " -NoNewline -ForegroundColor DarkCyan
    Write-Host ")   $Char_Bell" -ForegroundColor Yellow
    
    return $false
}

function Enable-WiFiSecurity {
    # ADDED: Specific formatting for VPN requirement
    Write-Host "     $FGDarkRed$Char_CrossMark Wi-Fi Security NOT ENABLED$Reset"
    
    # Mixed color output for the warning line
    Write-Host " $Char_Bell Requires Manual Enablement (" -NoNewline -ForegroundColor Yellow
    Write-Host "Enable VPN $Char_Shield " -NoNewline -ForegroundColor DarkCyan
    Write-Host ")   $Char_Bell" -ForegroundColor Yellow
    
    return $false
}

function Enable-CloudDeliveredProtection {
    try {
        Set-MpPreference -MAPSReporting Advanced -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Enable-AutomaticSampleSubmission {
    try {
        Set-MpPreference -SubmitSamplesConsent SendAllSamples -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Enable-ControlledFolderAccess {
    try {
        Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Enable-CheckAppsAndFiles {
    try {
        $userPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
        if (-not (Test-Path $userPath)) { New-Item -Path $userPath -Force | Out-Null }
        Set-ItemProperty -Path $userPath -Name "SmartScreenEnabled" -Value "Warn" -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Enable-SmartScreenEdge {
    try {
        $PrefPath = "HKCU:\Software\Microsoft\Edge\SmartScreenEnabled"
        if (-not (Test-Path $PrefPath)) { New-Item -Path $PrefPath -Force | Out-Null }
        Set-ItemProperty -Path $PrefPath -Name "(default)" -Value 1 -Type DWord -Force
        return $true
    } catch { return $false }
}

function Enable-PUAProtection {
    try {
        # Updated text to match new name
        Write-Host "`n  • Potentially unwanted app blocking..." -ForegroundColor Cyan -NoNewline
        Set-MpPreference -PUAProtection Enabled -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Enable-SmartScreenStoreApps {
    try {
        $userPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost"
        if (-not (Test-Path $userPath)) { New-Item -Path $userPath -Force | Out-Null }
        Set-ItemProperty -Path $userPath -Name "EnableWebContentEvaluation" -Value 1 -Type DWord -Force
        return $true
    } catch { return $false }
}

function Enable-MemoryIntegrity {
    try {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
        if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
        Set-ItemProperty -Path $regPath -Name "Enabled" -Value 1 -Type DWord -Force
        return $true
    } catch { return $false }
}

function Enable-KernelStackProtection {
    try {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks"
        if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
        Set-ItemProperty -Path $regPath -Name "Enabled" -Value 1 -Type DWord -Force
        return $true
    } catch { return $false }
}

function Enable-LSAProtection {
    try {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        Set-ItemProperty -Path $regPath -Name "RunAsPPL" -Value 1 -Type DWord -Force
        return $true
    } catch { return $false }
}

function Enable-SmartAppControl {
    Write-Host "  Requires Clean Install/Factory Reset" -ForegroundColor Yellow
    return $false
}

function Enable-DynamicLock {
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
        Set-ItemProperty -Path $regPath -Name "EnableGoodbye" -Value 1 -Type DWord -Force
        return $true
    } catch { return $false }
}

function Enable-FirewallProfile {
    param([string]$ProfileName)
    try {
        Set-NetFirewallProfile -Name $ProfileName -Enabled True -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Restart-SecurityApp {
    Write-Host "`n  Restarting Windows Security app..." -ForegroundColor Cyan
    # Kill the process
    Get-Process "SecHealthUI" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    # Restart via URI
    Start-Process "windowsdefender:" 
}

function Apply-SecuritySettings {
    $settingsApplied = 0
    $settingsFailed = 0
    $failedNames = @()
    $disabledChecks = $script:SecurityChecks | Where-Object { !$_.IsEnabled }

    foreach ($check in $disabledChecks) {
        $result = $false
        switch ($check.Name) {
            "Real-time protection" { $result = Enable-RealTimeProtection }
            "Tamper protection" { $result = Enable-TamperProtection }
            "Cloud-delivered protection" { $result = Enable-CloudDeliveredProtection }
            "Automatic sample submission" { $result = Enable-AutomaticSampleSubmission }
            "Controlled folder access" { $result = Enable-ControlledFolderAccess }
            "Check apps and files" { $result = Enable-CheckAppsAndFiles }
            "SmartScreen for Microsoft Edge" { $result = Enable-SmartScreenEdge }
            # Updated name
            "Potentially unwanted app blocking" { $result = Enable-PUAProtection }
            "SmartScreen for Microsoft Store apps" { $result = Enable-SmartScreenStoreApps }
            "Memory integrity" { $result = Enable-MemoryIntegrity }
            "Kernel-mode Hardware-enforced Stack" { $result = Enable-KernelStackProtection }
            "Local Security Authority protection" { $result = Enable-LSAProtection }
            "Smart App Control" { $result = Enable-SmartAppControl }
            "Dynamic lock" { $result = Enable-DynamicLock }
            "Domain network firewall" { $result = Enable-FirewallProfile -ProfileName "Domain" }
            "Private network firewall" { $result = Enable-FirewallProfile -ProfileName "Private" }
            "Public network firewall" { $result = Enable-FirewallProfile -ProfileName "Public" }
            # ADDED: Wi-Fi Security case
            "Wi-Fi Security" { $result = Enable-WiFiSecurity }
        }
        if ($result) { 
            $settingsApplied++ 
        } else { 
            $settingsFailed++ 
            $failedNames += $check.Name
        }
    }

    if ($settingsApplied -gt 0) { Write-Host "    ✓ ENABLED" -ForegroundColor Green }
    
    if ($failedNames.Count -gt 0) {
        foreach ($name in $failedNames) {
            # UPDATED: Skip Tamper protection and Wi-Fi Security in summary as they have their own alerts
            if ($name -ne "Tamper protection" -and $name -ne "Wi-Fi Security") {
                # Changed icon to No Entry (🚫) and confirmed Red color
                Write-Host "    $FGRed$Char_NoEntry $name$Reset"
            }
        }
    }
}

function Invoke-ApplySecuritySettings {
    param()
    $disabledChecks = $script:SecurityChecks | Where-Object { !$_.IsEnabled }
    if ($disabledChecks.Count -eq 0) { return }

    Write-Host "`n" -NoNewline
    # REMOVED: Header block "APPLY RECOMMENDED SETTINGS" and separators as requested

    Write-Host "  Would you like to apply recommended settings?" -ForegroundColor Cyan

    # UPDATED: Interactive selection to match footer style (Input Info = DarkMagenta, Key = Yellow)
    Write-Host ""
    Write-Host "  Press " -NoNewline -ForegroundColor DarkMagenta
    Write-Host "Enter" -NoNewline -ForegroundColor Yellow
    Write-Host " to Apply recommended settings" -ForegroundColor DarkMagenta

    # UPDATED: Spacebar is now the primary exit/skip option, replacing Esc functionality
    Write-Host "  Press " -NoNewline -ForegroundColor DarkMagenta
    Write-Host "Spacebar" -NoNewline -ForegroundColor Yellow
    Write-Host " to Exit without applying settings" -ForegroundColor DarkMagenta

    $validInput = $false
    while (-not $validInput) {
        # FIX: ReadKey must be INSIDE the loop to prevent infinite looping on invalid keys
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        # Check for Enter (13)
        if ($key.VirtualKeyCode -eq 13) {
            $validInput = $true
            Write-Host "" # Newline
            
            Write-Host "`n  $FGGreen$Char_WhiteCheck Applying recommended security settings...$Reset"
            Write-Host $SeparatorLine
            Apply-SecuritySettings
            
            # --- NEW: Restart Security App after applying settings ---
            Restart-SecurityApp
            # ---------------------------------------------------------
            
            Write-Host "`n" -NoNewline
            Write-Host $SeparatorLine
            Write-Host "  $FGGreen$Char_WhiteCheck Settings applied successfully!$Reset"
            Write-Host $SeparatorLine
        
        # Check for Spacebar (Skip)
        } elseif ($key.Character -eq ' ') {
            $validInput = $true
            Write-Host "" # Newline
            Write-Host "`n  - Exiting without applying settings" -ForegroundColor Gray
            
        }
        # REMOVED: Esc check (27)
        # Loop continues for any other key
    }
}

# --- Main execution ---
try {
    # --- Determine Copyright Year ---
    $ScriptPath = $PSCommandPath
    if ($ScriptPath) {
        $LastEditYear = (Get-Item $ScriptPath).LastWriteTime.Year
    } else {
        $LastEditYear = (Get-Date).Year
    }
    $CopyrightLine = "© $LastEditYear, www.AIIT.support. All Rights Reserved."

    Clear-Host
    Write-Host "`n" -NoNewline
    
    # Updated Main Title Block
    # 60 chars. "——  WINDOWS SECURITY CONFIGURATOR ——" is roughly 36 chars.
    # (60 - 36) / 2 = 12 spaces padding.
    # CHANGED: Title text to Cyan (Header)
    Write-Host "            $FGCyan——  WINDOWS SECURITY CONFIGURATOR ——$Reset"
    # "Patch-W11 🔄" is ~12 chars. (60-12)/2 = 24 spaces.
    # CHANGED: "Patch-W11" color to DarkCyan (Sub-Header) and Blue Loop
    Write-Host "                        $FGDarkCyan Patch-W11 $FGBlue$Char_Loop$Reset"
    
    # Copyright Line (Centered) - DarkCyan (Footer)
    $padCopyright = [math]::Max(0, [math]::Floor((60 - $CopyrightLine.Length) / 2))
    Write-Host (" " * $padCopyright) -NoNewline
    Write-Host "$FGDarkCyan$CopyrightLine$Reset"

    # DarkBlue Separator
    Write-Host $DoubleSeparatorLine

    # Run checks with extra spacing added
    
    # Added two extra empty lines here as requested
    Write-Host ""
    Write-Host ""
    
    Get-DefenderStatus
    
    # MOVED: Get-AccountProtection to be immediately after Get-DefenderStatus
    Get-AccountProtection
    
    Get-FirewallStatus
    
    Get-ReputationProtection
    
    Get-CoreIsolationStatus

    # ADDED: Show Scan History immediately on load (Suggestion #1)
    Get-ScanInformation
    
    Show-SecuritySummary
    Invoke-ApplySecuritySettings

    if ($ShowRemediation) { Show-RemediationSteps }
    
    if ($ExportHtml) {
        $htmlPath = Join-Path $OutputPath "SecurityReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
        # Export-ToHtml logic
        Write-Host "HTML Export not fully implemented in this view"
    }
    
    # REMOVED: "ADDITIONAL OPTIONS" header as requested
    
    # UPDATED: Key instructions per request (Input Info=DarkMagenta, Key=Yellow)
    # Line 1: "  Press " (DarkMagenta) + "Enter" (Yellow) + " to Run a quick scan" (DarkMagenta)
    Write-Host "  Press " -NoNewline -ForegroundColor DarkMagenta
    Write-Host "Enter" -NoNewline -ForegroundColor Yellow
    Write-Host " to Run a quick scan" -ForegroundColor DarkMagenta
    
    # Line 2: "  Press " (DarkMagenta) + "Spacebar" (Yellow) + " to Close" (DarkMagenta)
    # Replaces the old Esc line
    Write-Host "  Press " -NoNewline -ForegroundColor DarkMagenta
    Write-Host "Spacebar" -NoNewline -ForegroundColor Yellow
    Write-Host " to Close" -ForegroundColor DarkMagenta

    $validInput = $false
    while (-not $validInput) {
        # FIX: ReadKey must be INSIDE the loop to prevent infinite looping on invalid keys
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        # UPDATED: Key check for Enter (VirtualKeyCode 13)
        if ($key.VirtualKeyCode -eq 13) {
            $validInput = $true # Ensure loop exits after selection
            # REMOVED: Open-EdgeSecuritySettings (Reverted opening logic)
            Write-Host "  Starting quick scan..." -ForegroundColor Cyan
            try { 
                Start-MpScan -ScanType QuickScan -ErrorAction Stop
                Write-Host "  $FGGreen$Char_WhiteCheck Quick scan completed$Reset"
                
                # --- MOVED: THREAT STATUS CHECK ---
                if ($script:RealTimeProtectionEnabled) {
                    Write-Host ""
                    Get-ScanInformation
                    
                    # Check global status from scan
                    if ($script:ScanStatusAllGreen) {
                        Write-Host "     $FGGreen No current threats$Reset"
                    }
                }
                # ----------------------------------

            } catch { Write-Host "  Error: $_" }
        } elseif ($key.Character -eq ' ') { # Spacebar
            $validInput = $true
            Write-Host "" # Newline
            Write-Host "  Closing..." -ForegroundColor Gray
            # exit will happen after footer
        }
        # REMOVED: Esc check (27)
    }

    # Footer
    Write-Host "`n" -NoNewline
    # Changed to DarkBlue Em Dash line as requested
    Write-Host $DoubleSeparatorLine
    
    # Copyright Line (Centered) - Reusing variable - DarkCyan
    Write-Host (" " * $padCopyright) -NoNewline
    Write-Host "$FGDarkCyan$CopyrightLine$Reset"
    
    # Removed trailing empty line and second separator
    
    # FINAL: 5 Empty Lines before exit per standards
    Write-Host "`n`n`n`n`n"

} catch {
    Write-Host "`n[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
