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
    Version: 7.10
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
$Char_Keyboard    = [char]0x2328 # ⌨
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
$FGCyan       = "$Esc[96m"  # Header Title
$FGBlue       = "$Esc[94m"  # Body Icon
$FGDarkBlue   = "$Esc[34m"  # Header Boundary
$FGGreen      = "$Esc[92m"  # System Success
$FGRed        = "$Esc[91m"  # System Failure
$FGMagenta    = "$Esc[95m"  # System Error / Input Info
$FGYellow     = "$Esc[93m"  # Input Keypress
$FGDarkCyan   = "$Esc[36m"  # SCRIPT Text
$FGWhite      = "$Esc[97m"  # Body Title
$FGGray       = "$Esc[37m"  # System Text
$FGDarkGray   = "$Esc[90m"  # Body Boundary
$FGDarkGreen  = "$Esc[32m"  # SCRIPT Enabled
$FGDarkRed    = "$Esc[31m"  # SCRIPT Disabled
$FGDarkYellow = "$Esc[33m"  # SCRIPT Warning
$FGDarkMagenta= "$Esc[35m"  # Dark Magenta

# Helper for formatted column output
function Write-Row {
    param($ColorName, $ANSI, $About, $Type, $Hex, $Rep, $ColorCode)
    
    # Column Width Configuration
    $CNamePadded = $ColorName.PadRight(10) 
    $ANSIPadded  = $ANSI.PadRight(7)       
    $AboutPadded = $About.PadRight(7)
    $TypePadded  = $Type.PadRight(9)
    $HexPadded   = $Hex.PadRight(8)
    
    # Output Row
    Write-Host "  $ColorCode$CNamePadded$Reset $ANSIPadded$AboutPadded$TypePadded$HexPadded$ColorCode$Rep$Reset "
}

# ============================================================================
# VISUAL EXAMPLES MODE (DEFAULT) - COLOR USAGE CHART
# ============================================================================
function Show-VisualExamples {
    param([bool]$ShowFormattingRules = $false)

    Clear-Host
    Write-Output ""

    # --- TOP TITLE ---
    # " —— SCRIPT OUTPUT RULES —— " (Centered)
    $TopTitle = " —— SCRIPT OUTPUT RULES —— "
    $TopPadding = [Math]::Floor((60 - $TopTitle.Length) / 2)
    Write-Output (" " * $TopPadding + "$Bold$FGCyan$TopTitle$Reset")
    
    # --- SUB-HEADER: Patch-W11 (DarkCyan) + Loop Icon (Blue) ---
    $SubText = "Patch-W11 "
    $SubIcon = "$Char_Loop"
    $FullSubLength = $SubText.Length + $SubIcon.Length
    $SubPadding = [Math]::Floor((60 - $FullSubLength) / 2)
    Write-Output (" " * $SubPadding + "$Bold$FGDarkCyan$SubText$FGBlue$SubIcon$Reset")
    
    # --- PART 1: SCRIPT OUTPUT LEGEND ---
    
    # DarkBlue Separator Line (60 em dashes) - Placed above Legend Title
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"

    # Title
    $GuideTitle = " $Char_EmDash$Char_EmDash SCRIPT OUTPUT LEGEND $Char_EmDash$Char_EmDash "
    $GuidePadding = [Math]::Floor((60 - $GuideTitle.Length) / 2)
    Write-Output (" " * $GuidePadding + "$Bold$FGWhite$GuideTitle$Reset")
    
    # Added empty lines
    Write-Output ""
    
    # Table Header
    Write-Output "  ${FGGray}Text Color ANSI   About  Type     Hex     Representation$Reset"
    
    # Table Separator
    Write-Output "$FGDarkGray$([string]$Char_EmDash * 60)$Reset"

    # --- ROW DATA ---
    
    # Header Rows
    Write-Row "Cyan"       "\e[96m"  "Header" "Title"    "0x2014" "—— [TITLE] ——"        $FGCyan
    Write-Row "DarkBlue"   "\e[34m"  "Header" "Boundary" "0x2014" "———————————————"      $FGDarkBlue
    
    # Body Rows
    Write-Row "White"      "\e[97m"  "Body"   "Title"    "0x2014" "—— [TITLE] ——"        $FGWhite
    Write-Row "DarkGray"   "\e[90m"  "Body"   "Boundary" "0x2014" "———————————————"      $FGDarkGray
    Write-Row "Blue"       "\e[94m"  "Body"   "Icon"     "0x005B" "[  Icon  ]"           $FGBlue
    
    # SCRIPT Rows
    Write-Row "DarkCyan"   "\e[36m"  "SCRIPT" "Text"     "0x005B" "[  Text  ]"           $FGDarkCyan
    Write-Row "DarkGreen"  "\e[32m"  "SCRIPT" "Enabled"  "0x2611" "$Char_BallotCheck  [Enabled]"       $FGDarkGreen
    Write-Row "DarkRed"    "\e[31m"  "SCRIPT" "Disabled" "0x274E" "$Char_XSquare [Disabled]"       $FGDarkRed
    Write-Row "DarkYellow" "\e[33m"  "SCRIPT" "Warning"  "0x26A0" "$Char_Warn  [WARNING]"        $FGDarkYellow
    
    # System Rows
    Write-Row "Gray"       "\e[37m"  "System" "Text"     "0x005B" "[  Text  ]"           $FGGray
    Write-Row "Green"      "\e[92m"  "System" "Success"  "0x2714" "$Char_HeavyCheck  [Success]"        $FGGreen
    Write-Row "Red"        "\e[91m"  "System" "Failure"  "0x274C" "$Char_RedCross [Failure]"        $FGRed
    Write-Row "Magenta"    "\e[95m"  "System" "Error"    "0x26D4" "$Char_NoEntry [ ERROR ]"        $FGMagenta
    
    # Input Rows
    # DarkMagenta row removed
    Write-Row "Yellow"     "\e[93m"  "Input"  "Keypress" "0x261B" "$Char_Keyboard  [$Char_Finger Keypress]"       $FGYellow
    
    # DarkBlue Separator Line below Yellow Input row
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"

    # Added two empty lines
    Write-Output ""
    Write-Output ""

    # --- PART 2: SCRIPT OUTPUT DEFAULTS (HIDDEN BY DEFAULT) ---

    if ($ShowFormattingRules) {
        # DarkBlue Separator Line (60 em dashes) - Placed above Defaults Title
        Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"

        # --- FORMATTING RULES HEADER (CYAN) ---
        $RulesTitle = "  —— SCRIPT OUTPUT DEFAULTS ——  "
        $RulesPadding = [Math]::Floor((60 - $RulesTitle.Length) / 2)
        Write-Output (" " * $RulesPadding + "$Bold$FGCyan$RulesTitle$Reset")
        
        # Rules Text in DarkCyan - Added 2 spaces indentation
        Write-Output "  ${FGDarkCyan}A. Text Formatting:$Reset"
        Write-Output "  ${FGDarkCyan}   1. Never split whole words over multiple lines.$Reset"
        Write-Output "  ${FGDarkCyan}   2. Header Alignment: Center-align$Reset"
        Write-Output "  ${FGDarkCyan}   3. Body Alignment: Left-align$Reset"
        Write-Output "  ${FGDarkCyan}   4. Body Indentation: Minimum of 2 spaces left & right$Reset"
        Write-Output "  ${FGDarkCyan}   5. Boundaries composed of (`"$Char_EmDash`" * 60)$Reset"
        
        # DarkBlue Separator Line (just below formatting rules)
        Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"
    } 
    # Else: Do not show defaults section
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================
if ($ShowRules) {
    Show-FullRules
    1..5 | ForEach-Object { Write-Output "" }
} else {
    # 1. Initial State (Rules Hidden)
    Show-VisualExamples -ShowFormattingRules $false
    
    # 2. Prompt (DarkCyan with Yellow highlights)
    Write-Output ""
    # REMOVED leading space to ensure fit (60 chars exactly)
    # Changed DarkMagenta to DarkCyan as requested
    $PromptStr = "${FGDarkCyan}$Char_Keyboard  ${FGYellow}Press ${FGYellow}$Char_Finger Enter${FGDarkCyan} to Show rules  |  Press ${FGYellow}$Char_Finger Spacebar${FGDarkCyan} to Close$Reset"
    
    # Calculate centering padding
    # REMOVED leading space to ensure fit (60 chars exactly)
    $VisibleText = "$Char_Keyboard  Press $Char_Finger Enter to Show rules  |  Press $Char_Finger Spacebar to Close"
    $PromptPadding = [Math]::Floor((60 - $VisibleText.Length) / 2)
    
    Write-Output (" " * $PromptPadding + $PromptStr)
    
    # 3. Copyright (DarkCyan, below Prompt)
    Write-Output ""
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    $FooterPadding = [Math]::Floor((60 - $FooterText.Length) / 2)
    Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor DarkCyan
    
    # 4. Wait for key
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.VirtualKeyCode -eq 13) { # Enter key
        # 5. Show Rules State (Rules Visible)
        Show-VisualExamples -ShowFormattingRules $true
        
        # Redisplay Copyright (ALWAYS LAST)
        Write-Output ""
        Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor DarkCyan
        
        # Script ends naturally here (no exit), keeping window open if run from prompt
    }
    
    # Script ends naturally here (no exit)
}
# Output 5 empty lines before exit (User Requirement)
1..5 | ForEach-Object { Write-Output "" }
