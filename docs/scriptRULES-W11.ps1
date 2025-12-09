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
    Version: 7.16 (Removed empty line above titles)
    Repository: https://github.com/KeithOwns/PatchW11
#>

param(
    [switch]$ShowRules
)

# Set console output encoding to UTF-8 to ensure all Unicode characters display correctly
Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Define Unicode Characters (ASCII-Safe) ---
# NOTE: The mockup uses the regular U+2014 EM DASH (—) for the boundary lines,
# which is slightly different from the U+2501 BOX DRAWINGS HEAVY HORIZONTAL (━) used previously.
$Char_HBar        = [char]0x2501 # Not used in mockup, but kept
$Char_VBar        = [char]0x2502 # Not used in mockup, but kept
$Char_Check       = [char]0x2713 # Not used in mockup, but kept
$Char_HeavyCheck  = [char]0x2714 # ✔ - Used for Green Success
$Char_Cross       = [char]0x2718 # Not used in mockup, but kept
$Char_Shield      = [char]::ConvertFromUtf32(0x1F6E1) # Not used in mockup, but kept
$Char_Warn        = [char]0x26A0 # ⚠ - Used for DarkYellow Warning
$Char_Info        = [char]0x2139 # Not used in mockup, but kept
$Char_BallotCheck = [char]0x2611 # ☑ - Used for DarkGreen Enabled
$Char_XSquare     = [char]0x274E # ❎ - Used for DarkRed Disabled
$Char_NoEntry     = [char]0x26D4 # ⛔ - Used for Magenta Error
$Char_Bell        = [char]::ConvertFromUtf32(0x1F514) # Not used in mockup, but kept
$Char_Keyboard    = [char]0x2328 # ⌨ - Used for Prompt
$Char_Gear        = [char]0x2699 # Not used in mockup, but kept
$Char_Square      = [char]0x2B1B # Not used in mockup, but kept
$Char_WhiteCheck  = [char]0x2705 # ✅ - Not used in mockup, but kept
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504) # 🔄 - Used for Sub-Header
$Char_Copyright   = [char]0x00A9 # © - Used for Footer
$Char_EmDash      = [char]0x2014 # — - Used for all boundaries (60 dashes)
$Char_RedCross    = [char]0x274C # ❌ - Used for Red Failure
$Char_Finger      = [char]0x261B # ☛ - Used for Yellow Keypress

# --- ANSI Escape Sequences for Color Formatting (PS 5.1 Compatible) ---
$Esc = [char]0x1B
$Reset = "$Esc[0m"
$Bold = "$Esc[1m"

# Script Palette
$FGCyan       = "$Esc[96m"  # Header Title
$FGBlue       = "$Esc[94m"  # Body Icon
$FGDarkBlue   = "$Esc[34m"  # Header Boundary
$FGGreen      = "$Esc[92m"  # SCRIPT Success
$FGRed        = "$Esc[91m"  # SCRIPT Failure
$FGMagenta    = "$Esc[95m"  # SCRIPT Error
$FGYellow     = "$Esc[93m"  # Input Keypress
$FGDarkCyan   = "$Esc[36m"  # Output Text
$FGWhite      = "$Esc[97m"  # Body Title
$FGGray       = "$Esc[37m"  # Body Text
$FGDarkGray   = "$Esc[90m"  # Body Boundary
$FGDarkGreen  = "$Esc[32m"  # System Enabled
$FGDarkRed    = "$Esc[31m"  # System Disabled
$FGDarkYellow = "$Esc[33m"  # System Warning
$FGDarkMagenta= "$Esc[35m"  # Dark Magenta - Removed from use, kept for safety

# Helper for formatted column output
function Write-Row {
    param($ColorName, $ANSI, $About, $Type, $Hex, $Rep, $ColorCode)

    # Column Width Configuration adjusted to match mockup spacing
    # TextColor: 11
    # ANSI: 7
    # About: 7
    # Type: 9
    # Hex: 7
    $CNamePadded = $ColorName.PadRight(11)
    $ANSIPadded  = $ANSI.PadRight(7)
    $AboutPadded = $About.PadRight(7)
    $TypePadded  = $Type.PadRight(9)
    $HexPadded   = $Hex.PadRight(7)

    # Output Row - Adjusted padding to achieve exact mockup alignment
    Write-Host "  $ColorCode$CNamePadded$Reset $ANSIPadded$AboutPadded$TypePadded$HexPadded$ColorCode$Rep$Reset"
}

# ============================================================================
# VISUAL EXAMPLES MODE (DEFAULT) - COLOR USAGE CHART
# ============================================================================
function Show-VisualExamples {
    param([bool]$ShowFormattingRules = $false)

    Clear-Host
    # Add empty line above the title block, as requested
    Write-Output ""

    # --- TOP TITLE ---
    $TopTitle = "—— SCRIPT OUTPUT RULES ——"
    $TopPadding = [Math]::Floor((60 - $TopTitle.Length) / 2)
    Write-Output (" " * $TopPadding + "$Bold$FGCyan$TopTitle$Reset")

    # --- SUB-HEADER: Patch-W11 (DarkCyan) + Loop Icon (Blue) ---
    $SubText = "Patch-W11 "
    $SubIcon = "$Char_Loop"
    $FullSubLength = $SubText.Length + $SubIcon.Length
    
    # Calculate centering padding for the sub-header
    # Width is 60 characters
    $SubPadding = [Math]::Floor((60 - $FullSubLength) / 2)
    
    Write-Output (" " * $SubPadding + "$Bold$FGDarkCyan$SubText$FGBlue$SubIcon$Reset")

    # Add empty line below the header block, as requested
    Write-Output ""

    # --- PART 1: SCRIPT OUTPUT LEGEND ---

    # DarkBlue Separator Line (60 em dashes)
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset" # Boundary on its own line

    # REMOVED: Write-Output "" (Empty line above title)

    # Script Output LEGEND Title (Indented by 1 space, unstyled)
    Write-Output " Script Output LEGEND" 

    # Table Header (This empty line separates the title from the table header)
    Write-Output ""
    Write-Output "  ${FGGray}TextColor  ANSI   About  Type     Hex    Representation$Reset"

    # Table Separator (DarkGray boundary with 60 dashes)
    Write-Output "$FGDarkGray$([string]$Char_EmDash * 60)$Reset"

    # --- ROW DATA (Adjusted Representation field for alignment) ---

    # Header Rows (Representation padded to fit the table width)
    Write-Row "Cyan"       "\e[96m"  "Header" "Title"    "0x2014" "  —— [TITLE] ——  "      $FGCyan
    Write-Row "DarkBlue"   "\e[34m"  "Header" "Boundary" "0x2014" "————————————————"     $FGDarkBlue # 16 dashes

    # Body Rows (Representation padded to fit the table width)
    Write-Row "White"      "\e[97m"  "Body"   "Title"    "0x20*1" " [Title]        "      $FGWhite
    Write-Row "DarkGray"   "\e[90m"  "Body"   "Boundary" "0x2014" "————————————————"     $FGDarkGray # 16 dashes
    Write-Row "Blue"       "\e[94m"  "Body"   "Icon"     "0x20*2" "  [Icon  ]      "      $FGBlue
    Write-Row "Gray"       "\e[37m"  "Body"   "Text"     "0x20*3" "     [Text]     "      $FGGray

    # SCRIPT Status Rows
    Write-Row "Green"      "\e[92m"  "SCRIPT" "Success"  "0x2714" "$Char_HeavyCheck  [Success]    " $FGGreen
    Write-Row "Red"        "\e[91m"  "SCRIPT" "Failure"  "0x274C" "$Char_RedCross [Failure]    " $FGRed
    Write-Row "Magenta"    "\e[95m"  "SCRIPT" "Error"    "0x26D4" "$Char_NoEntry  [ERROR]     " $FGMagenta

    # System Status Rows
    Write-Row "DarkGreen"  "\e[32m"  "System" "Enabled"  "0x2611" "$Char_BallotCheck  [Enabled]    " $FGDarkGreen
    Write-Row "DarkRed"    "\e[31m"  "System" "Disabled" "0x274E" "$Char_XSquare  [Disabled]   " $FGDarkRed
    Write-Row "DarkYellow" "\e[33m"  "System" "Warning"  "0x26A0" "$Char_Warn  [WARNING]    " $FGDarkYellow

    # Output/Text Rows (Representation padded to fit the table width)
    Write-Row "DarkCyan"   "\e[36m"  "Output" "Text"     "0x20*3" "     [Text]     "      $FGDarkCyan

    # Input Rows
    Write-Row "Yellow"     "\e[93m"  "Input"  "Keypress" "0x261B" "$Char_Finger  [Keypress]   " $FGYellow

    # DarkBlue Separator Line (60 em dashes) - Placed below Yellow Input row
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"

    # Added empty line as per mockup
    Write-Output ""
    
    # --- PART 2: SCRIPT OUTPUT DEFAULTS (HIDDEN BY DEFAULT) ---

    if ($ShowFormattingRules) {
        
        # DarkBlue Separator Line (60 em dashes)
        Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"
        
        # REMOVED: Write-Output "" (Empty line above title)

        # Script Output DEFAULTS Title (Indented by 1 space, unstyled)
        Write-Output " Script Output DEFAULTS"

        # Rules Text in DarkCyan - Updated structure based on mockup
        Write-Output ""
        Write-Output "  ${FGDarkCyan}A. Text Formatting:$Reset"
        Write-Output "     ${FGDarkCyan}1. Never split whole words over multiple lines.$Reset"
        Write-Output "     ${FGDarkCyan}2. Header Alignment: Center-align$Reset"
        Write-Output "     ${FGDarkCyan}3. Body Alignment: Left-align$Reset"
        Write-Output "     ${FGDarkCyan}4. Body Indentation: $Reset"
        # Using a TAB character (`t) for indentation on sub-points to match mockup's appearance
        Write-Output "`t${FGDarkCyan}a. Title: 1 space $Reset"
        Write-Output "`t${FGDarkCyan}b. Icon : 2 spaces$Reset"
        Write-Output "`t${FGDarkCyan}c. Text : 3 spaces$Reset"
        # Escape the double quote (") in the string
        Write-Output "     ${FGDarkCyan}5. Boundaries composed of (`"$Char_EmDash`" * 60)$Reset"

        # DarkBlue Separator Line (just below formatting rules)
        Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================
if ($ShowRules) {
    # If -ShowRules is used, display the full content immediately
    Show-VisualExamples -ShowFormattingRules $true
    
    # Display Copyright Footer (Centered and DarkCyan)
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    $FooterPadding = [Math]::Floor((60 - $FooterText.Length) / 2)
    Write-Output ""
    Write-Output (" " * $FooterPadding + $FooterText) -ForegroundColor DarkCyan
    
} else {
    # 1. Initial State (Rules Hidden)
    Show-VisualExamples -ShowFormattingRules $false

    # 2. Prompt (DarkCyan with Yellow highlights, Centered)
    Write-Output ""
    $PromptStr = "${FGDarkCyan}$Char_Keyboard  ${FGYellow}Press ${FGYellow}$Char_Finger Enter${FGDarkCyan} to Show rules  |  Press ${FGYellow}$Char_Finger Spacebar${FGDarkCyan} to Close$Reset"

    # Calculate centering padding
    # Calculate visible length of text without ANSI codes for centering
    $VisibleText = "$Char_Keyboard  Press $Char_Finger Enter to Show rules  |  Press $Char_Finger Spacebar to Close"
    $PromptPadding = [Math]::Floor((60 - $VisibleText.Length) / 2)

    Write-Output (" " * $PromptPadding + $PromptStr)

    # 3. Copyright (DarkCyan, Centered, below Prompt)
    Write-Output ""
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    $FooterPadding = [Math]::Floor((60 - $FooterText.Length) / 2)
    Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor DarkCyan

    # 4. Wait for key
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.VirtualKeyCode -eq 13) { # Enter key (13)
        # 5. Show Rules State (Rules Visible)
        Show-VisualExamples -ShowFormattingRules $true

        # Redisplay Copyright (ALWAYS LAST)
        Write-Output ""
        Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor DarkCyan
    }
}

# Output 5 empty lines before exit (User Requirement)
1..5 | ForEach-Object { Write-Output "" }
