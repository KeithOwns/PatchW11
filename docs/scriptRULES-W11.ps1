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

.NOTES
    Author: PatchW11 Team
    Version: 6.1
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
$Char_HeavyCheck  = [char]0x2714 # ✔
$Char_Cross       = [char]0x2718
$Char_Shield      = [char]::ConvertFromUtf32(0x1F6E1)
$Char_Warn        = [char]0x26A0 # ⚠
$Char_Info        = [char]0x2139
$Char_BallotCheck = [char]0x2611 # ☑
$Char_XSquare     = [char]0x274E # ❎
$Char_NoEntry     = [char]0x26D4 # ⛔
$Char_Bell        = [char]::ConvertFromUtf32(0x1F514)
$Char_Keyboard    = [char]0x2328 # ⌨ (Replaced Bell for Info)
$Char_Gear        = [char]0x2699
$Char_Square      = [char]0x2B1B
$Char_WhiteCheck  = [char]0x2705 # ✅
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504)
$Char_Copyright   = [char]0x00A9
$Char_EmDash      = [char]0x2014 # ——
$Char_RedCross    = [char]0x274C # ❌
$Char_Finger      = [char]0x261B # ☛

# --- ANSI Escape Sequences for Color Formatting (PS 5.1 Compatible) ---
$Esc = [char]0x1B
$Reset = "$Esc[0m"
$Bold = "$Esc[1m"

# Script Palette
$FGCyan       = "$Esc[96m"
$FGBlue       = "$Esc[94m"
$FGDarkBlue   = "$Esc[34m"
$FGGreen      = "$Esc[92m"
$FGRed        = "$Esc[91m"
$FGMagenta    = "$Esc[95m" # Used for both Magenta and DarkMagenta in chart
$FGYellow     = "$Esc[93m"
$FGDarkCyan   = "$Esc[36m"
$FGWhite      = "$Esc[97m"
$FGGray       = "$Esc[37m"
$FGDarkGray   = "$Esc[90m"
$FGDarkGreen  = "$Esc[32m"
$FGDarkRed    = "$Esc[31m"
$FGDarkYellow = "$Esc[33m"

# Helper for formatted column output
function Write-Row {
    param($ColorName, $ANSI, $About, $Type, $Rep, $ColorCode)
    
    # Column Width Configuration
    $CNamePadded = $ColorName.PadRight(10) 
    $ANSIPadded  = $ANSI.PadRight(7)       
    $AboutPadded = $About.PadRight(7)
    $TypePadded  = $Type.PadRight(9)
    
    # Output Row
    Write-Host "   $ColorCode$CNamePadded$Reset $ANSIPadded$AboutPadded$TypePadded $ColorCode$Rep$Reset "
}

# ============================================================================
# VISUAL EXAMPLES MODE (DEFAULT) - COLOR USAGE CHART
# ============================================================================
function Show-VisualExamples {
    Write-Output ""

    # --- FORMATTING RULES HEADER (CYAN) ---
    # Updated Title: SCRIPT OUTPUT DEFAULTS
    $RulesTitle = "  —— SCRIPT OUTPUT DEFAULTS ——  "
    $RulesPadding = [Math]::Floor((60 - $RulesTitle.Length) / 2)
    Write-Output (" " * $RulesPadding + "$Bold$FGCyan$RulesTitle$Reset")
    
    # --- SUB-HEADER: Patch-W11 (DarkCyan) + Loop Icon (Blue) ---
    $SubText = "Patch-W11 "
    $SubIcon = "$Char_Loop"
    $FullSubLength = $SubText.Length + $SubIcon.Length
    $SubPadding = [Math]::Floor((60 - $FullSubLength) / 2)
    Write-Output (" " * $SubPadding + "$Bold$FGDarkCyan$SubText$FGBlue$SubIcon$Reset")

    # DarkBlue Separator Line (60 em dashes)
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"
    
    # Rules Text in DarkCyan
    # Updated Section A Title to "A. Text Formatting:"
    Write-Output "${FGDarkCyan}A. Text Formatting:$Reset"
    Write-Output "${FGDarkCyan}   1. Never split whole words over multiple lines.$Reset"
    Write-Output "${FGDarkCyan}   2. Text Alignment: Center-align$Reset"
    Write-Output "${FGDarkCyan}   3. Text Indentation: 2 spaces left & right$Reset"
    Write-Output "${FGDarkCyan}   4. Boundaries composed of (`"$Char_EmDash`" * 60)$Reset"
    
    # DarkBlue Separator Line (just below formatting rules)
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"
    
    # Added two empty lines
    Write-Output ""
    Write-Output ""
    
    # Added DarkBlue Separator Line above Legend Title
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"

    # --- LEGEND TITLE ---
    $GuideTitle = " $Char_EmDash$Char_EmDash SCRIPT OUTPUT LEGEND $Char_EmDash$Char_EmDash "
    $GuidePadding = [Math]::Floor((60 - $GuideTitle.Length) / 2)
    Write-Output (" " * $GuidePadding + "$Bold$FGWhite$GuideTitle$Reset")
    
    Write-Output ""
    
    # Table Header
    Write-Output "   ${FGGray}Text Color ANSI   About  Type      Representation$Reset"
    
    # Table Separator
    Write-Output "$FGDarkGray$([string]$Char_EmDash * 60)$Reset"

    # --- ROW DATA ---
    
    # Header Rows
    Write-Row "Cyan"       "\e[96m"  "Header" "Title"    "—— [TITLE] ——"        $FGCyan
    Write-Row "DarkBlue"   "\e[34m"  "Header" "Boundary" "———————————————"      $FGDarkBlue
    
    # Body Rows
    Write-Row "White"      "\e[97m"  "Body"   "Title"    "—— [TITLE] ——"        $FGWhite
    Write-Row "DarkGray"   "\e[90m"  "Body"   "Boundary" "———————————————"      $FGDarkGray
    Write-Row "Blue"       "\e[94m"  "Body"   "Icon"     "[  Icon  ]"           $FGBlue
    
    # SCRIPT Rows
    Write-Row "DarkCyan"   "\e[36m"  "SCRIPT" "Text"     "[  Text  ]"           $FGDarkCyan
    Write-Row "DarkGreen"  "\e[32m"  "SCRIPT" "Enabled"  "$Char_BallotCheck  [Enabled]"       $FGDarkGreen
    Write-Row "DarkRed"    "\e[31m"  "SCRIPT" "Disabled" "$Char_XSquare [Disabled]"       $FGDarkRed
    Write-Row "DarkYellow" "\e[33m"  "SCRIPT" "Warning"  "$Char_Warn  [WARNING]"        $FGDarkYellow
    
    # System Rows
    Write-Row "Gray"       "\e[37m"  "System" "Text"     "[  Text  ]"           $FGGray
    Write-Row "Green"      "\e[92m"  "System" "Success"  "$Char_HeavyCheck  [Success]"        $FGGreen
    Write-Row "Red"        "\e[91m"  "System" "Failure"  "$Char_RedCross [Failure]"        $FGRed
    Write-Row "Magenta"    "\e[95m"  "System" "Error"    "$Char_NoEntry [ ERROR ]"        $FGMagenta
    
    # Input Rows
    Write-Row "DarkMagenta" "\e[95m" "Input"  "Info"     "$Char_Keyboard [ Info ]"        $FGMagenta
    Write-Row "Yellow"      "\e[93m" "Input"  "Keypress" "$Char_Finger  [Keypress]"       $FGYellow
    
    # DarkBlue Separator Line below Yellow Input row
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"

    # --- COPYRIGHT FOOTER (DarkCyan) ---
    # Two empty lines above copyright
    Write-Output ""
    Write-Output ""
    
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    $FooterPadding = [Math]::Floor((60 - $FooterText.Length) / 2)
    # Changed Footer color to DarkCyan
    Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor DarkCyan
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
    Write-Output "$Bold$FGCyan$([string]$Char_HBar * 60)$Reset"
    Write-Output "$Bold$FGCyan$Char_VBar         PatchW11 PowerShell Script Writing Rules        $Char_VBar$Reset"
    Write-Output "$Bold$FGCyan$([string]$Char_HBar * 60)$Reset"
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

    Write-RuleItem `
        -RuleNumber "1.4" `
        -Title "Semantic Color Coding" `
        -Description "Adhere to the strict color guide: Cyan=Headers, DarkBlue=Lines, Yellow=Alerts, Red=Errors, Green=Success." `
        -Example "Write-Host '[HEADER]' -Fg Cyan" `
        -Rationale "Ensures immediate visual recognition of message types across all scripts."

    Write-RuleItem `
        -RuleNumber "1.5" `
        -Title "Standard Icon Usage" `
        -Description "Use defined icons: Gear (White), Info (Gray), Bell (Yellow), Check (Green), Cross (Red)." `
        -Example "`$Char_Gear for operations, `$Char_Bell for alerts." `
        -Rationale "Provides consistent visual cues for script status and attention levels."

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

# Ensure 5 empty lines at end of output per user requirements
1..5 | ForEach-Object { Write-Output "" }
