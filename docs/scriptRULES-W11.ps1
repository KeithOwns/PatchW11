#Requires -RunAsAdministrator
<#
.SYNOPSIS
    PatchW11 PowerShell Script Writing Rules and Visual Examples

.DESCRIPTION
    This script displays visual examples of PatchW11 scripting standards by default.
    Use the -ShowRules parameter to view the complete text-based rule documentation.

.PARAMETER ShowRules
    Display the complete text-based rules documentation instead of visual examples.

.EXAMPLE
    .\scriptRULES-W11.ps1
    Shows visual examples of formatting standards (default behavior)

.EXAMPLE
    .\scriptRULES-W11.ps1 -ShowRules
    Displays the complete text-based rules and standards documentation

.NOTES
    Author: PatchW11 Team
    Version: 1.0
    Repository: https://github.com/KeithOwns/PatchW11
#>

param(
    [switch]$ShowRules
)

# Set console output encoding to UTF-8 to ensure all Unicode characters display correctly
Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Define Unicode Characters (ASCII-Safe) ---
$Char_HBar        = [char]0x2501
$Char_VBar        = [char]0x2502
$Char_Check       = [char]0x2713
$Char_Cross       = [char]0x2718
$Char_Shield      = [char]::ConvertFromUtf32(0x1F6E1)
$Char_Warn        = [char]0x26A0
$Char_Info        = [char]0x2139
$Char_BallotCheck = [char]0x2611
$Char_XSquare     = [char]0x274E
$Char_NoEntry     = [char]::ConvertFromUtf32(0x1F6AB)
$Char_Bell        = [char]::ConvertFromUtf32(0x1F514)
$Char_Gear        = [char]0x2699
$Char_Square      = [char]::ConvertFromUtf32(0x1F533)
$Char_WhiteCheck  = [char]0x2705
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504)

# --- ANSI Escape Sequences for Color Formatting (PS 5.1 Compatible) ---
$Esc = [char]0x1B
$Reset = "$Esc[0m"
$Bold = "$Esc[1m"
$FGBlue = "$Esc[34m"
$FGCyan = "$Esc[36m"
$FGGreen = "$Esc[32m"
$FGYellow = "$Esc[93m"  # Bright Yellow
$FGDarkYellow = "$Esc[33m"  # DkYellow
$FGRed = "$Esc[91m"  # Bright Red
$FGDarkRed = "$Esc[31m"  # Dark Red
$FGWhite = "$Esc[97m"  # White
$FGGray = "$Esc[37m"  # Gray
$FGDarkGray = "$Esc[90m"  # Dark Gray
$BGB = "$Esc[40m$Esc[97m"  # Black BG, White FG
$BGW = "$Esc[47m$Esc[30m"  # White BG, Black FG
$BGTeal = "$Esc[46m$Esc[30m"  # Teal/Cyan BG, Black FG
$TealBG = "$Esc[40m$Esc[36m"  # Black BG, Teal/Cyan FG
$BGModernGray = "$Esc[100m"  # Bright Black BG

# --- Separator Line Character ---
$SeparatorChar = "$Char_HBar"  # U+2501 Box Drawings Heavy Horizontal
$SeparatorLine = "$FGBlue" + ($SeparatorChar * 60) + "$Reset"

# ============================================================================
# VISUAL EXAMPLES MODE (DEFAULT) - CHARACTER LIBRARY
# ============================================================================
function Show-VisualExamples {
    Write-Output ""

    # Windows logo (2x2 grid of blue squares)
    $WinSquare = "${FGBlue}█${Reset}"

    # Create the header with Windows logo on the left
    Write-Output "${WinSquare}${WinSquare}                   ${FGCyan}SCRIPT WRITING RULES${Reset}"
    Write-Output "${WinSquare}${WinSquare}                   ${FGCyan}Patch-W11 $Char_Loop${Reset}"

    # Blue separator line
    Write-Output ("${FGBlue}" + ("$Char_HBar" * 60) + "$Reset")
    Write-Output ""

    # Color Usage Guide Section (Compact)
    Write-Output "$Bold${FGCyan}Color Usage Guide$Reset"
    Write-Output ""
    
    # DkBlue


    
    # Cyan
    Write-Output "${FGCyan}Cyan     = ${TealBG}$Char_BallotCheck$Esc[40m${FGCyan} Enabled ${FGGray}| Write-StatusIcon -IsEnabled `$true$Reset"

    # DkRed
    Write-Output "${FGDarkRed}DarkRed  = ${Char_XSquare}Failure ${FGGray}| Write-StatusIcon -IsEnabled `$false$Reset"

    # Red
    Write-Output "${FGRed}Red      = ${Char_NoEntry}Errors ${FGGray}| Write-Host `"🚫 ERROR`" -Fg Red$Reset"

    # Yellow
    Write-Output "${FGYellow}Yellow   = ${Char_Bell}User Prompts ${FGGray}| Write-Host `"Message`" -Fg Yellow$Reset"

    # DkYellow
    Write-Output "${FGDarkYellow}DkYellow = $Char_Warn Warning ${FGGray}| Write-Host `"⚠ WARNING`" -Fg DarkYellow$Reset"

    # White
    Write-Output "$Esc[40m${FGWhite}White    = ${Char_Gear} Icons/Titles ${FGGray}| Write-Host `"⚙️ Title`" -Fg White$Reset"

    # Gray
    Write-Output "$Esc[40m${FGGray}Gray     = ${Char_Info} Info/Details | Write-Host `"${Char_Info} Detail`" -Fg Gray$Reset"

    # DkGray
    Write-Output "$Esc[40m${FGDarkGray}DarkGray = $Esc[100m$Esc[30m${Char_Square}$Esc[40m${FGDarkGray}Disabled ${FGGray}| Write-Host `"${Char_Square}Disabled`" -Fg DarkGray$Reset"

    # Green
    Write-Output "${FGGreen}Green    = ${Char_WhiteCheck}Success ${FGGray}| Write-Host `"✅ Complete`" -Fg Green$Reset"
    
    Write-Output ""
    # Fix: Convert char to string before multiplication
    Write-Output ("$Char_HBar" * 60)
    Write-Output ""

    # Additional information section
    Write-Output "$Bold${FGCyan}Key Scripting Rules:$Reset"
    Write-Output ""
    Write-Output "${FGGreen}[1.1]$Reset Use '$Char_HBar' (U+2501) for horizontal separator lines"
    Write-Output "      `$SeparatorChar = `"$Char_HBar`""
    Write-Output "${FGGreen}[1.2]$Reset Use '$Char_VBar' (U+2502) for vertical separator lines"
    Write-Output "${FGGreen}[1.3]$Reset All .ps1 files MUST be UTF-8 encoded"
    Write-Output "      [Console]::OutputEncoding = [Text.Encoding]::UTF8"
    Write-Output "${FGGreen}[2.1]$Reset Include #Requires -RunAsAdministrator at top"
    Write-Output "${FGGreen}[3.1]$Reset Script naming: [Verb]_[SettingName]-W11.ps1"
    Write-Output "      Example: Enable_RealTimeProtection-W11.ps1"
    Write-Output ""
    Write-Output ("$Char_HBar" * 60)
    Write-Output ""
    Write-Output "${FGCyan}View complete rules: ${FGYellow}.\scriptRULES-W11.ps1 -ShowRules$Reset"
    Write-Output ""
}

# ============================================================================
# FULL RULES DOCUMENTATION MODE
# ============================================================================
function Show-FullRules {
    # --- Helper Functions for Rules Mode ---
    function Write-RuleHeader {
        param([string]$Title)
        Write-Output ""
        Write-Output "$Bold$FGCyan$Title$Reset"
        Write-Output $SeparatorLine
    }

    function Write-RuleItem {
        param(
            [string]$RuleNumber,
            [string]$Title,
            [string]$Description,
            [string]$Example = "",
            [string]$Rationale = ""
        )

        Write-Output ""
        Write-Output "$FGGreen[$RuleNumber]$Reset $Bold$Title$Reset"
        Write-Output "  $Description"

        if ($Example) {
            Write-Output ""
            Write-Output "  ${FGYellow}Example:${Reset}"
            Write-Output "  $Example"
        }

        if ($Rationale) {
            Write-Output ""
            Write-Output "  ${FGCyan}Rationale:${Reset} $Rationale"
        }

        Write-Output $SeparatorLine
    }

    # --- Display Rules ---
    Write-Output ""
    Write-Output "$Bold$FGCyan$($Char_HBar * 60)$Reset"
    Write-Output "$Bold$FGCyan$Char_VBar         PatchW11 PowerShell Script Writing Rules        $Char_VBar$Reset"
    Write-Output "$Bold$FGCyan$($Char_HBar * 60)$Reset"
    Write-Output $SeparatorLine

    # ========================================================================
    # FORMATTING & VISUAL STANDARDS
    # ========================================================================
    Write-RuleHeader "1. FORMATTING & VISUAL STANDARDS"

    Write-RuleItem `
        -RuleNumber "1.1" `
        -Title "Use Box Drawing Characters for Horizontal Lines" `
        -Description "Always use the '$Char_HBar' character (U+2501) for horizontal separator lines, not hyphens or equals signs." `
        -Example "`$SeparatorLine = `"$Char_HBar`" * 80" `
        -Rationale "Provides consistent, professional-looking visual separation in console output across all scripts."

    Write-RuleItem `
        -RuleNumber "1.2" `
        -Title "UTF-8 Encoding Required" `
        -Description "All .ps1 files MUST be saved with UTF-8 encoding to support Unicode characters ($Char_Check $Char_Cross $Char_Shield $Char_Gear $Char_Warn)." `
        -Example "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8" `
        -Rationale "Ensures proper display of check marks, icons, and box-drawing characters across all terminals."

    Write-RuleItem `
        -RuleNumber "1.3" `
        -Title "Use Shared Visual Feedback Functions" `
        -Description "Use Write-StatusIcon() and Write-SectionHeader() for consistent visual output." `
        -Example "Write-StatusIcon -Enabled `$true -Message `"Feature enabled`" -Severity `"Success`"" `
        -Rationale "Maintains consistent color-coded severity indicators and formatting across all scripts."

    # ========================================================================
    # SCRIPT STRUCTURE & METADATA
    # ========================================================================
    Write-RuleHeader "2. SCRIPT STRUCTURE & METADATA"

    Write-RuleItem `
        -RuleNumber "2.1" `
        -Title "Require Administrator Privileges" `
        -Description "All scripts that modify system settings MUST include #Requires -RunAsAdministrator at the top." `
        -Example "#Requires -RunAsAdministrator" `
        -Rationale "Prevents runtime errors and ensures users are properly elevated before executing privileged operations."

    Write-RuleItem `
        -RuleNumber "2.2" `
        -Title "Include Comment-Based Help" `
        -Description "Every script must have a .SYNOPSIS, .DESCRIPTION, and .NOTES section in comment-based help." `
        -Example "<#`n.SYNOPSIS`n    Brief description`n.DESCRIPTION`n    Detailed description`n.NOTES`n    Author, Version`n#>" `
        -Rationale "Provides self-documenting code and enables Get-Help cmdlet usage."

    Write-RuleItem `
        -RuleNumber "2.3" `
        -Title "Strict Mode and Error Handling" `
        -Description "Enable strict mode and set consistent error action preference." `
        -Example "Set-StrictMode -Version Latest`n`$ErrorActionPreference = 'Stop'" `
        -Rationale "Catches undefined variables and ensures consistent error behavior across all scripts."

    # ========================================================================
    # NAMING CONVENTIONS
    # ========================================================================
    Write-RuleHeader "3. NAMING CONVENTIONS"

    Write-RuleItem `
        -RuleNumber "3.1" `
        -Title "Script Naming Pattern" `
        -Description "Follow the pattern: [Verb]_[SettingName]-W11.ps1" `
        -Example "Enable_RealTimeProtection-W11.ps1`nCheck_DevDrive-W11.ps1`nConfigure_Updates-W11.ps1" `
        -Rationale "Provides immediate clarity on script purpose and maintains repository organization."

    Write-RuleItem `
        -RuleNumber "3.2" `
        -Title "Approved Verbs" `
        -Description "Use standard verbs: Check, Enable, Disable, Configure, Run, Create, Open, Restart" `
        -Example "Enable_LSA-W11.ps1 (correct)`nTurnOn_LSA-W11.ps1 (incorrect)" `
        -Rationale "Follows PowerShell verb-noun conventions and maintains consistency."

    Write-RuleItem `
        -RuleNumber "3.3" `
        -Title "Function Naming Convention" `
        -Description "Use PascalCase with descriptive verbs for internal functions." `
        -Example "function Get-RegistryValue { }`nfunction Write-StatusIcon { }" `
        -Rationale "Aligns with PowerShell best practices and improves code readability."

    # ========================================================================
    # REGISTRY OPERATIONS
    # ========================================================================
    Write-RuleHeader "4. REGISTRY OPERATIONS"

    Write-RuleItem `
        -RuleNumber "4.1" `
        -Title "Use Safe Registry Helper Functions" `
        -Description "Always use Get-RegistryValue() and Set-RegistryDword() instead of direct Get-ItemProperty/Set-ItemProperty." `
        -Example "`$value = Get-RegistryValue -Path 'HKLM:\SOFTWARE\...' -Name 'Setting'" `
        -Rationale "Provides null handling, automatic path creation, and consistent error handling."

    Write-RuleItem `
        -RuleNumber "4.2" `
        -Title "Registry Path Format" `
        -Description "Use PowerShell drive notation (HKLM:\, HKCU:\) not registry hive notation." `
        -Example "HKLM:\SOFTWARE\Microsoft\Windows Defender (correct)`nHKEY_LOCAL_MACHINE\SOFTWARE\... (incorrect)" `
        -Rationale "Required for PowerShell cmdlets and maintains cross-script consistency."

    # ========================================================================
    # DEPENDENCY MANAGEMENT
    # ========================================================================
    Write-RuleHeader "5. DEPENDENCY MANAGEMENT"

    Write-RuleItem `
        -RuleNumber "5.1" `
        -Title "Check Feature Dependencies" `
        -Description "Verify prerequisite features are enabled before applying dependent settings." `
        -Example "# Real-time Protection must be ON for Controlled Folder Access`nif (-not `$rtpEnabled) { Write-Warning; return }" `
        -Rationale "Prevents configuration failures and provides clear user feedback on missing prerequisites."

    Write-RuleItem `
        -RuleNumber "5.2" `
        -Title "Detect Tamper Protection" `
        -Description "Check Tamper Protection status before attempting to modify Windows Defender settings." `
        -Example "`$tamper = Get-RegValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Features' -Name 'TamperProtection'`nif (`$tamper -eq 5) { Write-Warning 'User must disable manually' }" `
        -Rationale "Tamper Protection blocks programmatic changes and will cause Set-MpPreference to fail."

    Write-RuleItem `
        -RuleNumber "5.3" `
        -Title "Third-Party Antivirus Detection" `
        -Description "Skip Windows Defender checks when third-party AV is detected." `
        -Example "`$av = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct`nif (`$av.displayName -notmatch 'Windows Defender') { return }" `
        -Rationale "Prevents false negatives when corporate AV products replace Windows Defender."

    # ========================================================================
    # SECURITY & SEVERITY CLASSIFICATION
    # ========================================================================
    Write-RuleHeader "6. SECURITY & SEVERITY CLASSIFICATION"

    Write-RuleItem `
        -RuleNumber "6.1" `
        -Title "Severity Levels" `
        -Description "Use three severity levels: Critical (3x weight), Warning (2x weight), Info (1x weight)" `
        -Example "Critical: Firewall, Real-time Protection, Tamper Protection`nWarning: Most security features, update policies`nInfo: Optional features, informational items" `
        -Rationale "Enables weighted security scoring and prioritization of remediation efforts."

    Write-RuleItem `
        -RuleNumber "6.2" `
        -Title "Security Check Pattern" `
        -Description "Store check results using the SecurityCheck class with all required properties." `
        -Example "`$check = [SecurityCheck]@{`n    Category = 'Virus & Threat Protection'`n    Name = 'Feature Name'`n    IsEnabled = `$true`n    Severity = 'Critical'`n    Remediation = 'Set-MpPreference -FeatureName 1'`n}" `
        -Rationale "Provides consistent data structure for reporting, scoring, and remediation tracking."

    # ========================================================================
    # TESTING & VALIDATION
    # ========================================================================
    Write-RuleHeader "7. TESTING & VALIDATION"

    Write-RuleItem `
        -RuleNumber "7.1" `
        -Title "Test on Multiple Configurations" `
        -Description "Test scripts on Windows 11 Pro and Enterprise, with Tamper Protection ON/OFF, and with third-party AV." `
        -Example "VM Test Matrix: W11 Pro + Tamper ON, W11 Enterprise + Symantec AV, W11 Pro + Tamper OFF" `
        -Rationale "Ensures compatibility across common enterprise deployment scenarios."

    Write-RuleItem `
        -RuleNumber "7.2" `
        -Title "Verify Visual Output" `
        -Description "Test console output in both Windows Terminal and legacy Command Prompt/PowerShell console." `
        -Example "Check that $Char_Check $Char_Cross $Char_Shield icons render correctly in both terminals" `
        -Rationale "UTF-8 encoding and ANSI escape sequences may render differently across terminal types."

    Write-RuleItem `
        -RuleNumber "7.3" `
        -Title "Run Script Quality Validation" `
        -Description "Execute Test-ScriptQuality.ps1 before committing changes." `
        -Example "cd scripts`n.\Test-ScriptQuality.ps1" `
        -Rationale "Catches missing #Requires statements, encoding issues, and syntax errors before deployment."

    # ========================================================================
    # UI AUTOMATION (WHEN REQUIRED)
    # ========================================================================
    Write-RuleHeader "8. UI AUTOMATION STANDARDS"

    Write-RuleItem `
        -RuleNumber "8.1" `
        -Title "Load Required Assemblies" `
        -Description "Load UIAutomationClient and UIAutomationTypes assemblies for UWP UI automation." `
        -Example "Add-Type -AssemblyName UIAutomationClient`nAdd-Type -AssemblyName UIAutomationTypes" `
        -Rationale "Required for programmatic interaction with Windows Settings and Microsoft Store."

    Write-RuleItem `
        -RuleNumber "8.2" `
        -Title "Add Sufficient Delays" `
        -Description "Use Start-Sleep with adequate delays (2-5 seconds) after UI interactions." `
        -Example "Start-Process ms-settings:windowsupdate`nStart-Sleep -Seconds 3  # Allow UI to render" `
        -Rationale "UI elements may not be immediately available; premature interactions cause automation failures."

    Write-RuleItem `
        -RuleNumber "8.3" `
        -Title "Handle UI Automation Fragility" `
        -Description "Add error handling for missing UI elements and AutomationID changes." `
        -Example "if (-not `$button) { Write-Warning 'UI element not found - Windows UI may have changed'; return }" `
        -Rationale "Windows updates can change UI structure; graceful degradation prevents complete script failure."

    # ========================================================================
    # DOCUMENTATION & COMMENTS
    # ========================================================================
    Write-RuleHeader "9. DOCUMENTATION & COMMENTS"

    Write-RuleItem `
        -RuleNumber "9.1" `
        -Title "Update CLAUDE.md for Major Changes" `
        -Description "Document architectural patterns, new setter functions, and breaking changes in CLAUDE.md." `
        -Example "When adding new Apply Settings functions, update section 2 (Apply Settings Module)" `
        -Rationale "Maintains AI-assisted development context and onboarding documentation for new contributors."

    Write-RuleItem `
        -RuleNumber "9.2" `
        -Title "Inline Comments for Complex Logic" `
        -Description "Add comments for non-obvious logic, dependency checks, and workarounds." `
        -Example "# Controlled Folder Access requires Real-time Protection to be enabled first`nif (-not `$rtpEnabled) { return }" `
        -Rationale "Explains 'why' rather than 'what' for future maintainers."

    Write-RuleItem `
        -RuleNumber "9.3" `
        -Title "Avoid Emoji in Code Unless User-Requested" `
        -Description "Do not add emoji characters to code comments or output unless explicitly requested." `
        -Example "Write-Output 'Security check passed' (correct)`nWrite-Output 'Security check passed $Char_Check' (only if requested)" `
        -Rationale "Maintains professional output and avoids encoding issues in certain environments."

    # ========================================================================
    # FOOTER
    # ========================================================================
    Write-Output ""
    Write-Output $SeparatorLine
    Write-Output "$Bold$FGGreen$Char_Check End of PatchW11 Script Writing Rules$Reset"
    Write-Output $SeparatorLine
    Write-Output ""
    Write-Output "${FGCyan}To view visual examples instead, run:$Reset"
    Write-Output "  ${FGYellow}.\scriptRULES-W11.ps1$Reset"
    Write-Output ""
    Write-Output "${FGCyan}For more information, see:$Reset"
    Write-Output "  • CLAUDE.md - AI development guidance and architectural patterns"
    Write-Output "  • docs/ENHANCEMENT_GUIDE.md - Evolution and enhancement guidelines"
    Write-Output "  • README.md - User-facing documentation"
    Write-Output ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================
if ($ShowRules) {
    Show-FullRules
} else {
    Show-VisualExamples
}
