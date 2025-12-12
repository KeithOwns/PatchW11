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
    Version: 7.58 (Aligned column headers with data columns)
    Repository: https://github.com/KeithOwns/PatchW11
#>

param(
    [switch]$ShowRules
)

# Set console output encoding to UTF-8 to ensure all Unicode characters display correctly
Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Define Unicode Characters (ASCII-Safe) ---
$Char_HeavyCheck  = [char]0x2714 # ✔ - Used for Green Success
$Char_Warn        = [char]0x26A0 # ⚠ - Used for DarkYellow Warning
$Char_BallotCheck = [char]0x2611 # ☑ - Used for DarkGreen Enabled
$Char_XSquare     = [char]0x274E # ❎ - Used for DarkRed Disabled
$Char_NoEntry     = [char]0x26D4 # ⛔ - Used for Magenta Error
$Char_Keyboard    = [char]0x2328 # ⌨ - Used for Prompt
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504) # 🔄 - Used for Sub-Header
$Char_Copyright   = [char]0x00A9 # © - Used for Footer
$Char_EmDash      = [char]0x2014 # — - Used for all boundaries (60 dashes)
$Char_EnDash      = [char]0x2013 # – - Used for new White Body Title representation
$Char_Hyphen      = [char]0x002D # - - Used for new DarkCyan and Gray Text representation
$Char_RedCross    = [char]0x274C # ❌ - Used for Red Failure
$Char_Finger      = [char]0x261B # ☛ - Used for Yellow Keypress
$Char_GreaterThan = [char]0x003E # > - Used for Blue Body Icon representation

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
$FGDarkMagenta= "$Esc[35m"  # Foreground Dark Magenta (\e[35m)
$BGDarkMagenta= "$Esc[45m"  # Background Magenta (Used in new HexCode)

    # Helper for formatted column output
function Write-Row {
    param($ColorName, $ANSI, $About, $Type, $HexCode, $DefaultCharacter, $ColorCode) 

    # Column Width Configuration
    $Width_TextColor   = 11
    $Width_ANSI        = 8  # Increased by 1 to account for extra space before ANSI column
    $Width_About       = 7
    $Width_Type        = 9
    $Width_Hex         = 9 # Padding to align hex codes
    
    # Calculate padding for DefaultCharacter - RIGHT ALIGNED
    $DefaultCharColumnWidth = 11 # Minimum width to fit "DefaultChar"
    $Padding_DefaultCharacter_Left = $DefaultCharColumnWidth - 1 # Right-align: push to the right
    $Padding_DefaultCharacter_Right = 1 # Space between DefaultChar and Hex

    # Apply dynamic color to TextColor and pad the result (11 characters) - RIGHT ALIGNED
    $CNameUncoloredPadded = $ColorName.PadLeft($Width_TextColor)
    
    $ANSIPadded  = $ANSI.PadRight($Width_ANSI)
    $AboutPadded = $About.PadLeft($Width_About) # RIGHT ALIGNED
    $TypePadded  = $Type.PadRight($Width_Type)
    $HexPadded   = $HexCode # LEFT ALIGNED (no padding)

    # Assemble the output line (6 columns) - SWAPPED Hex and DefaultChar positions
    $OutputLine = "  ${ColorCode}${CNameUncoloredPadded}${Reset} $ANSIPadded$AboutPadded $TypePadded   "
    
    # Append the right-aligned DefaultCharacter content
    $OutputLine += (" " * $Padding_DefaultCharacter_Left) + "${ColorCode}$DefaultCharacter${Reset}" + (" " * $Padding_DefaultCharacter_Right)
    
    # Then append Hex at the end
    $OutputLine += " $HexPadded"

    Write-Host $OutputLine
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
    $TopTitle = "── SCRIPT OUTPUT RULES ──"
    $TitleLength = $TopTitle.Length
    
    # Calculate true center alignment (17 spaces for 60 width / 25 length)
    $TitlePadding = [Math]::Floor((60 - $TitleLength) / 2)
    
    Write-Output (" " * $TitlePadding + "$Bold$FGCyan$TopTitle$Reset")

    # --- SUB-HEADER: Patch-W11 (DarkCyan) + Loop Icon (Blue) ---
    $SubText = " Patch-W11" # Added space for icon swap
    $SubIcon = "$Char_Loop"
    $FullSubLength = $SubText.Length + $SubIcon.Length
    
    # Calculate centering padding for the sub-header (based on standard centering)
    $SubPadding = [Math]::Floor((60 - $FullSubLength) / 2)
    
    # Sub-header: Icon is first, then text. Only text is bold/DarkCyan; icon is Blue.
    Write-Output (" " * $SubPadding + "$FGBlue$SubIcon$Reset$Bold$FGDarkCyan$SubText$Reset")

    # --- PART 1: SCRIPT OUTPUT LEGEND ---

    # DarkBlue Separator Line (60 em dashes)
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset" # Boundary on its own line

    # Script Output LEGEND Title (Center-aligned and revised)
    $LegendTitle = "$Char_EnDash ${FGWhite}Script Output LEGEND$Reset $Char_EnDash"
    $LegendTitleLength = 24 # Calculated length: 1+1+20+1+1 = 24 (excluding color codes)
    $LegendTitlePadding = [Math]::Floor((60 - $LegendTitleLength) / 2)
    
    Write-Output (" " * $LegendTitlePadding + $LegendTitle)

    # Table Header (No empty line before header)
    Write-Output ""
    
    # Header: Aligned with data columns using same spacing structure
    $Header_TextColor = "TextColor".PadLeft(11)  # RIGHT ALIGNED
    $Header_ANSI = "ANSI".PadRight(7)
    $Header_About = "About".PadLeft(7)  # RIGHT ALIGNED
    $Header_Type = "Type".PadRight(9)
    $Header_Hex = "Hex" # LEFT ALIGNED (no padding)
    
    # Right-align DefaultChar header within its column space
    $DefaultCharText = "DefaultChar"
    $DefaultCharColumnWidth = 11 # Minimum width to fit "DefaultChar" (11 characters)
    $DefaultCharPadding = [Math]::Max(0, $DefaultCharColumnWidth - $DefaultCharText.Length)
    $Header_DefaultChar = (" " * $DefaultCharPadding) + $DefaultCharText
    
    Write-Output "  ${FGGray}$Header_TextColor $Header_ANSI$Header_About $Header_Type   $Header_DefaultChar $Header_Hex$Reset"

    # Table Separator (DarkGray boundary with 60 dashes) - This line runs full width
    Write-Output "$FGDarkGray$([string]$Char_EmDash * 60)$Reset"

    # --- ROW DATA (6 columns) ---
    
    # Hex and CharDefault components - NO COLON
    $HexEmDash = "0x2014 "  # Added trailing space to shift right
    $HexEnDash = "0x2013"
    
    # 1. Cyan (Header Title)
    Write-Row "Cyan"       "\e[96m"  "Header" "Title"    $HexEmDash $Char_EmDash $FGCyan
    
    # 2. DarkBlue (Header Boundary)
    Write-Row "DarkBlue"   "\e[34m"  "Header" "Boundary" $HexEmDash $Char_EmDash $FGDarkBlue
    
    # 3. DarkCyan (Output Text) - Uses Hyphen (0x2D)
    Write-Row "DarkCyan"   "\e[36m"  "Output" "Text"     "0x2D" $Char_Hyphen $FGDarkCyan
    
    # 4. Blue (Body Icon)
    Write-Row "Blue"       "\e[94m"  "Body"   "Icon"     "0x3E" $Char_GreaterThan $FGBlue 
    
    # 5. Yellow (Input Keypress)
    Write-Row "Yellow"     "\e[93m"  "Input"  "Keypress" "0x261B" $Char_Finger $FGYellow
    
    # 6. White (Body Title) - Uses EnDash (0x2013)
    Write-Row "White"      "\e[97m"  "Body"   "Title"    $HexEnDash $Char_EnDash $FGWhite
    
    # 7. Gray (Body Text) - Uses Hyphen (0x2D)
    Write-Row "Gray"       "\e[37m"  "Body"   "Text"     "0x2D" $Char_Hyphen $FGGray

    # 8. DarkGray (Body Boundary) 
    Write-Row "DarkGray"   "\e[90m"  "Body"   "Boundary" $HexEmDash $Char_EmDash $FGDarkGray
    
    # 9. Green (SCRIPT Success)
    Write-Row "Green"      "\e[92m"  "SCRIPT" "Success"  "0x2714" $Char_HeavyCheck $FGGreen

    # 10. Red (SCRIPT Failure)
    Write-Row "Red"        "\e[91m"  "SCRIPT" "Failure"  "0x274C" $Char_RedCross $FGRed

    # 11. Magenta (SCRIPT Error)
    Write-Row "Magenta"    "\e[95m"  "SCRIPT" "Error"    "0x26D4" $Char_NoEntry $FGMagenta

    # 12. DarkMagenta (SCRIPT Copyright) - Changed to Footer Copyright
    Write-Row "DarkMagenta" "\e[35m" "Footer" "Copyright" "0x00A9" $Char_Copyright $FGDarkMagenta

    # 13. DarkGreen (System Enabled)
    Write-Row "DarkGreen"  "\e[32m"  "System" "Enabled"  "0x2611 " $Char_BallotCheck $FGDarkGreen

    # 14. DarkRed (System Disabled)
    Write-Row "DarkRed"    "\e[31m"  "System" "Disabled" "0x274E " $Char_XSquare $FGDarkRed

    # 15. DarkYellow (System Warning)
    Write-Row "DarkYellow" "\e[33m"  "System" "Warning"  "0x26A0 " $Char_Warn $FGDarkYellow

    # DarkBlue Separator Line (60 em dashes) - Placed below Yellow Input row
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"

    # Added empty line as per mockup
    Write-Output ""
    
    # --- PART 2: SCRIPT OUTPUT DEFAULTS (HIDDEN BY DEFAULT) ---

    if ($ShowFormattingRules) {
        
        # DarkBlue Separator Line (60 em dashes)
        Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"
        
        # Script Output DEFAULTS Title (Center-aligned)
        $DefaultsTitle = "$Char_EnDash Script Output DEFAULTS $Char_EnDash"
        $DefaultsTitleLength = 29 # Length without ANSI codes
        $DefaultsTitlePadding = [Math]::Floor((60 - $DefaultsTitleLength) / 2)
        Write-Output (" " * $DefaultsTitlePadding + $DefaultsTitle)

        # Rules Text in DarkCyan - UPDATED BASED ON USER REQUEST
        Write-Output ""
        Write-Output "  ${FGDarkCyan}A. Text Formatting:$Reset"
        Write-Output "     ${FGDarkCyan}1. Never split whole words over multiple lines.$Reset"
        Write-Output "     ${FGDarkCyan}2. Header/Footer Alignment: Center-align$Reset"
        Write-Output "     ${FGDarkCyan}3. Body Alignment: Left-align$Reset"
        Write-Output "     ${FGDarkCyan}4. Body Indentation: $Reset"
        Write-Output "         ${FGDarkCyan}a. Icon: 1 space$Reset"
        Write-Output "         ${FGDarkCyan}b. Text: 2 spaces$Reset"
        Write-Output "     ${FGDarkCyan}5. Boundaries composed of (`"$Char_EmDash`" * 60)$Reset"
        Write-Output "     ${FGDarkCyan}6. Optimize output for window 60 characters in length$Reset"

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
    
    # Display Copyright Footer (Centered and DarkMagenta)
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    $FooterPadding = [Math]::Floor((60 - $FooterText.Length) / 2)
    Write-Output ""
    Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor DarkMagenta
    
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

    # 3. Copyright (DarkMagenta, Centered, below Prompt)
    Write-Output ""
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    $FooterPadding = [Math]::Floor((60 - $FooterText.Length) / 2)
    Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor DarkMagenta

    # 4. Wait for key
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.VirtualKeyCode -eq 13) { # Enter key (13)
        # 5. Show Rules State (Rules Visible)
        Show-VisualExamples -ShowFormattingRules $true

        # Redisplay Copyright (ALWAYS LAST)
        Write-Output ""
        Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor DarkMagenta
    }
}

# Output 5 empty lines before exit (User Requirement)
1..5 | ForEach-Object { Write-Output "" }
