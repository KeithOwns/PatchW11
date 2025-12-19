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
    Version: 8.70 (Consistency Update)
    Repository: https://github.com/KeithOwns/PatchW11
#>

param(
    [switch]$ShowRules
)

# Set console output encoding to UTF-8 to ensure all Unicode characters display correctly
Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Define Unicode Characters (ASCII-Safe) ---
$Char_HeavyCheck  = [char]0x2705 # ✅ - Used for Green Success
$Char_Warn        = [char]0x26A0 # ⚠ - Used for DarkYellow Warning
$Char_BallotCheck = [char]0x2611 # ☑ - Used for DarkGreen Enabled
$Char_XSquare     = [char]0x26DD # ⛝ - Used for DarkRed Disabled (Legacy Icon)
$Char_NoEntry     = [char]0x26D2 # ⛒ - Used for Magenta Error
$Char_Keyboard    = [char]0x2328 # ⌨ - Used for Prompt
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504) # 🔄 - Used for Sub-Header
$Char_Copyright   = [char]0x00A9 # © - Used for Footer
$Char_EmDash      = [char]0x2014 # — - Used for all boundaries (60 dashes)
$Char_EnDash      = [char]0x2013 # – - Used for new White Body Title representation
$Char_Hyphen      = [char]0x002D # - - Used for new DarkCyan and Gray Text representation
$Char_RedCross    = [char]0x274E # ❎ - Used for Red Failure (SCRIPT Failure) / DarkRed Visual
$Char_Finger      = [char]0x261B # ☛ - Used for Yellow Keypress
$Char_GreaterThan = [char]0x003E # > - Used for Blue Body Icon representation
$Char_HeavyMinus  = [char]0x2796 # ➖ - Used for Gray Text representation

# --- NEW CHARACTERS FOR UPDATED MOCKUP ---
$Char_HeavyLine   = [char]0x2501 # ━ - Used for main headers and footers
$Char_LightLine   = [char]0x2500 # ─ - Used for prompt top border and legend title
$Char_Overline    = [char]0x203E # ‾ - Used for table header separator

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
$FGBlack      = "$Esc[30m"  # Foreground Black (For contrast on Yellow/Cyan BG)
$BGYellow     = "$Esc[103m" # High Intensity Background Yellow
$BGWhite      = "$Esc[107m" # High Intensity Background White
$BGCyan       = "$Esc[106m" # High Intensity Background Cyan (BrightCyan)
$BGDarkRed    = "$Esc[41m"  # NEW: Background Dark Red
$BGDarkBlue   = "$Esc[44m"  # Background Dark Blue (New)
$BGDarkGreen  = "$Esc[42m"  # Background Dark Green (for System Enabled Text)
$BGDarkCyan   = "$Esc[46m"  # Background Dark Cyan (for Rule A.7 text)
$BGDarkGray   = "$Esc[100m" # Background Dark Gray
$BGGreen      = "$Esc[102m" # High Intensity Background Green (Matches FGGreen 92m style)
$BGRed        = "$Esc[101m" # High Intensity Background Red (Matches FGRed 91m style)
$BGDarkYellow = "$Esc[43m"  # Background Dark Yellow (ANSI Standard)

# Helper for formatted column output
function Write-Row {
    # Cleaned up parameters: Removed unused $Type and $HexCode
    # Added [string] type cast to DefaultString to fix .Length error on char inputs
    param($ColorName, $ANSI, $About, $Where, [string]$DefaultString, $ColorCode) 

    # Column Width Configuration
    $Width_TextColor   = 11
    # EDITED: Reduced ANSI width from 8 to 7 to shift following columns left
    $Width_ANSI        = 7  
    $Width_About       = 9  
    $Width_Where       = 8  
    
    # Apply dynamic color to TextColor and pad the result (11 characters) - RIGHT ALIGNED
    $CNameUncoloredPadded = $ColorName.PadLeft($Width_TextColor)
    
    $ANSIPadded   = $ANSI.PadRight($Width_ANSI)
    # Note: AboutPadded logic here assumes visible length. Since we pass full ANSI strings, 
    # PadLeft won't add spaces if length > 9. We handle padding INSIDE the input strings.
    $AboutPadded  = $About.PadLeft($Width_About) 
    $WherePadded  = $Where.PadRight($Width_Where) # LEFT ALIGNED
    
    # Assemble the output line (5 columns + spacing for DefaultString)
    # Added a space between $AboutPadded and $WherePadded to prevent merging (e.g. "ScriptHdr")
    # EDITED: Reduced to 1 space to align with Header (which was shifted left in 8.67)
    $OutputLine = " ${ColorCode}${CNameUncoloredPadded}${Reset} $ANSIPadded$AboutPadded $WherePadded${ColorCode}$DefaultString${Reset}"
    
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
    # DELETED: Removed "── PatchW11 ──" line as per user request
    # Note: Only blank line remains.

    # --- SUB-HEADER (Updated) ---
    
    # NEW: Add " ━ PatchW11 ━" line above "SCRIPT OUTPUT RULES"
    # Using the Heavy Line style from Mockup
    $PatchW11Title = " $Char_HeavyLine PatchW11 $Char_HeavyLine"
    $PatchW11Length = $PatchW11Title.Length
    $PatchW11Padding = [Math]::Floor((60 - $PatchW11Length) / 2)
    
    # Print the added PatchW11 title line (Cyan)
    Write-Output (" " * $PatchW11Padding + "$Bold$FGCyan$PatchW11Title$Reset")
    
    # USER REQUEST 8.30: All text in Fg Cyan on default Bg for "SCRIPT OUTPUT RULES"
    $SubText = "SCRIPT OUTPUT RULES" 
    $FullSubLength = $SubText.Length
    
    # Calculate centering padding for the sub-header (based on standard centering)
    $SubPadding = [Math]::Floor((60 - $FullSubLength) / 2)
    
    # Sub-header: Changed from DarkCyan to Cyan ($FGCyan)
    Write-Output (" " * $SubPadding + "$Bold$FGCyan$SubText$Reset")

    # --- PART 1: SCRIPT OUTPUT LEGEND ---

    # DarkBlue Separator Line (60 Heavy Lines) - UPDATED TO MOCKUP
    Write-Output "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset" # Boundary on its own line

    # Script Output LEGEND Title (Center-aligned and revised)
    # UPDATED: Using Light Lines ($Char_LightLine) instead of EnDash
    $LegendTitle = "${FGCyan}$Char_LightLine Script Output LEGEND $Char_LightLine$Reset"
    $LegendTitleLength = 24 # Calculated length approx
    $LegendTitlePadding = [Math]::Floor((60 - $LegendTitleLength) / 2)
    
    Write-Output (" " * $LegendTitlePadding + $LegendTitle)

    # Table Header (No empty line before header)
    Write-Output ""
    
    # Header: Aligned with data columns using same spacing structure
    $Header_TextColor = "Color".PadLeft(11)  # RIGHT ALIGNED
    
    # EDITED: ANSI Header split to ensure padding spaces are Default color (not Gray)
    $Header_ANSI_Text = "ANSI"
    # EDITED: Reduced padding to 4 spaces (Shift Left)
    $Header_ANSI_Pad  = " " * 4 

    # EDITED: "  About " (shifted text right by 1 space inside block)
    $Header_About     = "${FGBlack}${BGWhite}  About ${Reset}" 
    # EDITED: Changed PadRight from 9 to 8 to match data column width reduction
    $Header_Where     = "Where".PadRight(8)  # LEFT ALIGNED

    # Center DefaultString Header
    $DefaultStringText = "Default_String" # Changed from DefaultString
    
    # EDITED: Removed leading space to shift column left by 1 character
    $Header_DefaultString = "$DefaultStringText"
    
    # 1 Space leading indentation (matches Write-Row prefix)
    # Added space between Header_About and Header_Where to match Write-Row logic
    # Re-added ${FGGray} after Header_About to ensure subsequent text remains gray
    # NEW EDIT: Removed one extra space between $Header_ANSI_Pad and $Header_About as requested
    # EDITED: Reduced to 1 space between Header_About and Header_Where (shifted left)
    Write-Output " ${FGGray}$Header_TextColor ${FGGray}$Header_ANSI_Text${Reset}$Header_ANSI_Pad$Header_About ${FGGray}$Header_Where$Header_DefaultString$Reset"

    # Table Separator (White/DarkGray, Indented, 60 chars) - UPDATED TO OVERLINE
    # Mockup shows: ‾‾‾‾‾‾‾‾‾‾‾‾...
    Write-Output "$FGDarkGray$([string]$Char_Overline * 60)$Reset"

    # --- ROW DATA (Rearranged) ---
    
    # Hex and CharDefault components
    $HexEmDash = "0x2014 "
    $HexEnDash = "0x2013"
    
    # 1. Cyan (Header Title)
    # UPDATED: Centered over 20-char lines (4 spaces padding)
    $CyanDefaultString = "    $Char_HeavyLine PatchW11 $Char_HeavyLine"
    # UPDATED: About column "  Script " -> 2 spaces lead, 1 space trail
    $CyanAbout = "${FGBlack}${BGCyan}  Script ${Reset}"
    Write-Row "Cyan"       "\e[96m" $CyanAbout "Hdr/Ftr" $CyanDefaultString $FGCyan
    
    # 2. DarkBlue (Header Boundary)
    # UPDATED: 20 Heavy Lines (0 spaces)
    $DarkBlueDefaultString = "$([string]$Char_HeavyLine * 20)"
    # UPDATED: About column "  Script " -> 2 spaces lead, 1 space trail
    # EDITED: Matches Cyan pattern
    $DarkBlueAbout = "${FGBlack}${BGDarkBlue}  Script ${Reset}"
    Write-Row "DarkBlue"   "\e[34m" $DarkBlueAbout "Lines" $DarkBlueDefaultString $FGDarkBlue

    # 3. DarkCyan (Output Text)
    # DELETED: "DarkCyan \e[36m Script  ☛ ⌨ ⏭️" line removed completely per request.
    
    # 4. Green (SCRIPT Success) - MOVED UP
    # EDITED: "   ✅ Success!" (3 spaces)
    $GreenDefaultString = "   $Char_HeavyCheck Success!"
    # UPDATED: About column "  Script " -> 2 spaces lead, 1 space trail
    $GreenAbout = "${FGBlack}${BGGreen}  Script ${Reset}"
    Write-Row "Green"      "\e[92m" $GreenAbout "Output" $GreenDefaultString $FGGreen

    # 5. Red (SCRIPT Failure) - MOVED UP
    # EDITED: "   ❎ Failure!" (3 spaces)
    $RedDefaultString = "   $Char_RedCross Failure!"
    # UPDATED: About column "  Script " -> 2 spaces lead, 1 space trail
    $RedAbout = "${FGBlack}${BGRed}  Script ${Reset}"
    Write-Row "Red"        "\e[91m" $RedAbout "Output" $RedDefaultString $FGRed
    
    # 6. Yellow (Input Keypress) - MOVED UP
    # EDITED: "    ☛ [Key]" (4 spaces)
    $YellowDefaultString = "Yellow \e[93m  script    ☛ [Key]"
    $YellowContent = "    $Char_Finger ${FGBlack}${BGYellow}[Key]${Reset}"
    # UPDATED: About column "  Script " -> 2 spaces lead, 1 space trail
    $YellowAbout = "${FGBlack}${BGYellow}  Script ${Reset}"
    Write-Row "Yellow"     "\e[93m" $YellowAbout "Input" $YellowContent $FGYellow
    
    # 7. White (Body Title) - MOVED DOWN
    # UPDATED: Centered in 14-char col "      ➖" (6 spaces padding)
    # CLEANUP: Changed "Bold  " to "Bold" to fix alignment (PadLeft pushes pure text to right)
    $WhiteContent = "      $Char_HeavyMinus" 
    # UPDATED: Added one space trailing to match visual width of 9 chars
    # Previous: "   ${FGWhite}BOLD ${Reset}" (Width 8)
    # New: "   ${FGWhite}BOLD  ${Reset}" (Width 9)
    $WhiteAbout = "   ${FGWhite}BOLD  ${Reset}"
    Write-Row "White"      "\e[97m" $WhiteAbout "Body" $WhiteContent $FGWhite
    
    # 8. Gray (Body Text) - MOVED DOWN
    # UPDATED: "      -" (6 spaces)
    $GrayContent = "      $Char_Hyphen"
    # UPDATED: Added one space trailing to match visual width of 9 chars
    # Previous: "${FGGray} regular${Reset}" (Width 8)
    # New: "${FGGray} regular ${Reset}" (Width 9)
    $GrayAbout = "${FGGray} regular ${Reset}"
    Write-Row "Gray"       "\e[37m" $GrayAbout "Body" $GrayContent $FGGray

    # 9. DarkGray (Body Boundary) - MOVED DOWN
    # UPDATED: 20 Light Lines (0 spaces)
    $DarkGrayDefaultString = "$([string]$Char_LightLine * 20)"
    # UPDATED: About column "  System " -> 2 spaces lead, 1 space trail
    # Fg White for "System" as requested.
    $DarkGrayAbout = "${FGWhite}${BGDarkGray}  System ${Reset}"
    Write-Row "DarkGray"   "\e[90m" $DarkGrayAbout "Lines" $DarkGrayDefaultString $FGDarkGray
    
    # 10. DarkGreen (System Enabled) - MOVED DOWN
    # EDITED: "   ☑  ENABLED" (3 spaces)
    $DarkGreenDefaultString = "   $Char_BallotCheck  ENABLED"
    # UPDATED: About column "  System " -> 2 spaces lead, 1 space trail
    $DarkGreenAbout = "${FGWhite}${BGDarkGreen}  System ${Reset}"
    Write-Row "DarkGreen"  "\e[32m" $DarkGreenAbout "Output" $DarkGreenDefaultString $FGDarkGreen

    # 11. DarkRed (System Disabled) - MOVED DOWN
    # EDITED: "   ❎ DISABLED" (3 spaces)
    $DarkRedDefaultString = "   ${FGDarkRed}$Char_RedCross DISABLED${Reset}"
    # UPDATED: About column "  System " -> 2 spaces lead, 1 space trail
    $DarkRedAbout = "${FGWhite}${BGDarkRed}  System ${Reset}"
    Write-Row "DarkRed"    "\e[31m" $DarkRedAbout "Output" $DarkRedDefaultString $FGDarkRed

    # 12. DarkYellow (System Warning) - MOVED DOWN
    # EDITED: "   ⚠  WARNING" (3 spaces)
    $DarkYellowDefaultString = "   $Char_Warn  WARNING"
    # UPDATED: About column "  System " -> 2 spaces lead, 1 space trail
    $DarkYellowAbout = "${FGWhite}${BGDarkYellow}  System ${Reset}"
    Write-Row "DarkYellow" "\e[33m" $DarkYellowAbout "Output" $DarkYellowDefaultString $FGDarkYellow

    # EDITED: Add Fg DarkGray LIGHT LINE boundary line just below the 'DarkYellow' line (Mockup Prompt Top)
    Write-Output "$FGDarkGray$([string]$Char_LightLine * 60)$Reset"

    # ADDED EMPTY LINE BELOW YELLOW - CHANGE 3
    Write-Output ""

    # EDITED: Change the ... boundary just above the "Script Output FORMATTING" line to Fg DarkBlue HEAVY LINE.
    Write-Output "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"
    
    # --- PART 2: SCRIPT OUTPUT DEFAULTS (HIDDEN BY DEFAULT) ---

    if ($ShowFormattingRules) {
        
        # Script Output DEFAULTS Title (Center-aligned)
        # FIX: Applying FGCyan to the en dashes as requested by the user.
        # EDITED: "Script Output DEFAULTS" to "Script Output FORMATTING"
        $DefaultsTitle = "${FGCyan}$Char_EnDash Script Output FORMATTING $Char_EnDash$Reset"
        $DefaultsTitleLength = 26 # Adjusted length for visual centering of the text part
        $LegendTitlePadding = [Math]::Floor((60 - 28) / 2) # Adjusted padding
        Write-Output (" " * $LegendTitlePadding + $DefaultsTitle)
        
        # Rules Text in DarkCyan - UPDATED BASED ON USER REQUEST
        # EDITED: All text in Formatting section to Fg Gray, EXCEPT "A. Text Formatting:" which is White.
        Write-Output ""
        Write-Output "  ${FGWhite}A. Text Formatting:$Reset"
        Write-Output "     ${FGGray}1. Never split whole words over multiple lines.$Reset"
        # EDITED: Combined Rule 2 and 3
        Write-Output "     ${FGGray}2. Default alignment: Center-align$Reset"
        # EDITED: Deleted old rule 3 placeholder
        # EDITED: Combined Rule 4 and 5
        Write-Output "     ${FGGray}3. Body Alignment: Left-align; 2 space indentation$Reset"
        # Renumbered subsequent rules
        Write-Output "     ${FGGray}4. Boundaries composed of (`"$Char_EmDash`" * 60)$Reset"
        Write-Output "     ${FGGray}5. Optimize output for window 60 characters in length$Reset"
        # Rules A.7 and A.8 renumbered to A.8 and A.9 respectively.
        # FIX: Correcting Fg/Bg of the parenthesis in Rule A.8
        # REWRITTEN RULE 6 per user request
        # REWRITTEN AGAIN to prevent mid-word wrapping and ensure it makes sense
        # "Highlight" was split before. Moving it to the next line.
        # Line 1: "6. Structured Status Display (Write-FlexLine):"
        # Line 2: "    Highlight positive status states (Active/On) using"
        # Line 3: "    a background color (e.g., $BGDarkGreen)."
        
        Write-Output "     ${FGGray}6. Structured Status Display (Write-FlexLine):$Reset"
        Write-Output "         ${FGGray}Highlight positive status states (Active/On) using$Reset"
        Write-Output "         ${FGGray}a background color (e.g., `$BGDarkGreen).$Reset"
        
        # BUG FIX: Changed \$FGGray to `$FGGray to properly display the variable name text
        Write-Output "     ${FGGray}7. Always use ${FGGray}`$FGGray${FGGray} for informational text that is $Reset"
        Write-Output "         ${FGGray}not a status or title.$Reset"
        
    }
}

#============================================================================
# MAIN EXECUTION
#============================================================================
if ($ShowRules) {
    # If -ShowRules is used, display the full content immediately
    Show-VisualExamples -ShowFormattingRules $true
    
    # Add DarkBlue Separator above Copyright - HEAVY LINE
    Write-Output "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"

    # Display Copyright Footer (Centered and Cyan)
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    $FooterPadding = [Math]::Floor((60 - $FooterText.Length) / 2)
    # UPDATED: Changed to Cyan
    Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor Cyan
    
} else {
    # 1. Initial State (Rules Hidden)
    Show-VisualExamples -ShowFormattingRules $false

    # 2. Prompt (MATCHED TO 02 SCRIPT STYLING)
    # "⌨  Press ☛ [Enter] to EXPAND | or any other key to Close"
    
    # EDITED: "Show rules" to "EXPAND" (Yellow on Default Bg)
    # EDITED: "⌨" and "[Enter]" to White Foreground ($FGWhite)
    # EDITED: "[Enter]" to Black Text on Yellow Background ($FGBlack$BGYellow)
    # EDITED: "key" to Gray ($FGGray) on Default Bg
    # UPDATED: Changed all previously DarkCyan parts to Gray
    $PromptStr = "${FGWhite}$Char_Keyboard  ${FGGray}Press ${FGYellow}$Char_Finger${Reset} ${FGBlack}${BGYellow}[Enter]${Reset}${FGGray} to ${FGYellow}EXPAND${FGGray} ${FGGray}|${FGGray} or ${FGGray}any other ${FGGray}key${Reset}${FGGray} to ${FGGray}Close${Reset}"

    # Calculate centering padding
    # Calculate visible length of text without ANSI codes for centering
    $VisibleText = "$Char_Keyboard  Press $Char_Finger [Enter] to EXPAND | or any other key to Close"
    
    # ERROR FIX: Added [Math]::Max(0, ...) to ensure padding is never negative
    $PromptPadding = [Math]::Max(0, [Math]::Floor((60 - $VisibleText.Length) / 2))

    # Save cursor position before printing prompt to allow clearing later if needed
    $PromptCursorTop = [Console]::CursorTop
    
    Write-Output (" " * $PromptPadding + $PromptStr)

    # Add DarkBlue Separator above Copyright - HEAVY LINE
    Write-Output "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"

    # 3. Copyright (Cyan, Centered, below Prompt)
    Write-Output ""
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    $FooterPadding = [Math]::Floor((60 - $FooterText.Length) / 2)
    # UPDATED: Changed to Cyan
    Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor Cyan

    # 4. Wait for key
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.VirtualKeyCode -eq 13) { # Enter key (13)
        # 5. Show Rules State (Rules Visible)
        Show-VisualExamples -ShowFormattingRules $true

        # Add DarkBlue Separator above Copyright - HEAVY LINE
        Write-Output "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"

        # Redisplay Copyright (ALWAYS LAST)
        Write-Output ""
        # UPDATED: Changed to Cyan
        Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor Cyan
    } else {
        # User pressed any other key to Close/Exit
        
        # Move cursor back to the start of the prompt line
        try {
            # Clear Prompt line (PromptCursorTop)
            [Console]::SetCursorPosition(0, $PromptCursorTop)
            Write-Output (" " * 80)
            
            # Clear Separator line (next line)
            [Console]::SetCursorPosition(0, $PromptCursorTop + 1)
            Write-Output (" " * 80)
            
            # Leave the Copyright lines (Top+2, Top+3) ALONE.
            # We specifically want to clear prompt/boundary but keep footer.
            
            # Reset cursor position to PromptCursorTop so script exits cleanly without text overlap
            # Actually, typically you want the cursor BELOW the footer on exit.
            # Footer is at Top+3. So set cursor to Top+4.
            [Console]::SetCursorPosition(0, $PromptCursorTop + 4)
            
        } catch {
            # Fallback if console manipulation fails (e.g. ISE)
        }
    }
}

# Output 5 empty lines before exit (User Requirement)
1..5 | ForEach-Object { Write-Output "" }
