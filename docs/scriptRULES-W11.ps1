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
    Version: 1.8
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
$Char_BallotCheck = [char]0x2611
$Char_XSquare     = [char]0x274E # ❎
$Char_NoEntry     = [char]0x26D4 # ⛔
$Char_Bell        = [char]::ConvertFromUtf32(0x1F514)
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
$FGCyan       = "$Esc[96m"  # Script Title
$FGBlue       = "$Esc[94m"  # Script Body (Bright Blue)
$FGDarkBlue   = "$Esc[34m"  # Script Boundary (Standard Blue)
$FGGreen      = "$Esc[92m"  # Script Success
$FGRed        = "$Esc[91m"  # Script Failure
$FGMagenta    = "$Esc[95m"  # Script Error
$FGYellow     = "$Esc[93m"  # Input Keypress (Bright Yellow FG)

# System Palette
$FGWhite      = "$Esc[97m"  # System Title
$FGGray       = "$Esc[37m"  # System Body
$FGDarkGray   = "$Esc[90m"  # System Boundary
$FGDarkGreen  = "$Esc[32m"  # System Enabled
$FGDarkRed    = "$Esc[31m"  # System Disabled
$FGDarkYellow = "$Esc[33m"  # System Warning

# Helper for formatted column output
function Write-Row {
    param($ColorName, $ANSI, $About, $Type, $Rep, $ColorCode)
    $CNamePadded = $ColorName.PadRight(12)
    $ANSIPadded  = $ANSI.PadRight(10)
    $AboutPadded = $About.PadRight(8)
    $TypePadded  = $Type.PadRight(10)
    
    Write-Host "$ColorCode$CNamePadded$Reset $ANSIPadded $AboutPadded $TypePadded $ColorCode$Rep$Reset"
}

# ============================================================================
# VISUAL EXAMPLES MODE (DEFAULT) - COLOR USAGE CHART
# ============================================================================
function Show-VisualExamples {
    Write-Output ""
    Write-Output "Text Color   ANSI       About    Type       Representation"
    Write-Output "----------------------------------------------------------"

    # --- SCRIPT ---
    Write-Row "Cyan"       "\e[96m"  "SCRIPT" "Title"    "[ - title - ]"    $FGCyan
    Write-Row "Blue"       "\e[94m"  "SCRIPT" "Body"     "[...text... ]"    $FGBlue
    Write-Row "DarkBlue"   "\e[34m"  "SCRIPT" "Boundary" "[$Char_EmDash]"           $FGDarkBlue
    Write-Row "Green"      "\e[92m"  "SCRIPT" "Success"  "[$Char_HeavyCheck ]"          $FGGreen
    Write-Row "Red"        "\e[91m"  "SCRIPT" "Failure"  "[$Char_RedCross]"           $FGRed
    Write-Row "Magenta"    "\e[95m"  "SCRIPT" "Error"    "[$Char_NoEntry]"           $FGMagenta
    
    # Yellow Input (Changed to Foreground per request)
    Write-Row "Yellow"     "\e[93m"  "Input"  "Keypress" "[$Char_Finger ]"          $FGYellow

    # --- SYSTEM ---
    Write-Row "White"      "\e[97m"  "System" "Title"    "[ - title - ]"    $FGWhite
    Write-Row "Gray"       "\e[37m"  "System" "Body"     "[...text... ]"    $FGGray
    Write-Row "DarkGray"   "\e[90m"  "System" "Boundary" "[$Char_EmDash]"           $FGDarkGray
    Write-Row "DarkGreen"  "\e[32m"  "System" "Enabled"  "[$Char_WhiteCheck]"           $FGDarkGreen
    Write-Row "DarkRed"    "\e[31m"  "System" "Disabled" "[$Char_XSquare]"           $FGDarkRed
    Write-Row "DarkYellow" "\e[33m"  "System" "Warning"  "[$Char_Warn ]"          $FGDarkYellow
}

# ============================================================================
# FULL RULES DOCUMENTATION MODE
# ============================================================================
function Show-FullRules {
    # Existing rules logic preserved...
    Write-Output ""
    Write-Output "Run without -ShowRules to see the Color Usage Chart."
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
