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
    Version: 8.77 (Body Alignment Final)
    Repository: https://github.com/KeithOwns/PatchW11
#>

param(
    [switch]$ShowRules
)

# Set console output encoding to UTF-8 to ensure all Unicode characters display correctly
Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Define Unicode Characters (ASCII-Safe) ---
$Char_HeavyCheck  = [char]0x2705 # âœ… - Used for Green Success
$Char_Warn        = [char]0x26A0 # âš  - Used for DarkYellow Warning
$Char_BallotCheck = [char]0x2611 # â˜‘ - Used for DarkGreen Enabled
$Char_XSquare     = [char]0x26DD # â› - Used for DarkRed Disabled (Legacy Icon)
$Char_NoEntry     = [char]0x26D2 # â›’ - Used for Magenta Error
$Char_Keyboard    = [char]0x2328 # âŒ¨ - Used for Prompt
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504) # ðŸ”„ - Used for Sub-Header
$Char_Copyright   = [char]0x00A9 # Â© - Used for Footer
$Char_EmDash      = [char]0x2014 # â€” - Used for all boundaries (60 dashes)
$Char_EnDash      = [char]0x2013 # â€“ - Used for new White Body Title representation
$Char_Hyphen      = [char]0x002D # - - Used for new DarkCyan and Gray Text representation
$Char_RedCross    = [char]0x274E # âŽ - Used for Red Failure (SCRIPT Failure) / DarkRed Visual
$Char_Finger      = [char]0x261B # â˜› - Used for Yellow Keypress
$Char_GreaterThan = [char]0x003E # > - Used for Blue Body Icon representation
$Char_HeavyMinus  = [char]0x2796 # âž– - Used for Gray Text representation
$Char_Skip        = [char]0x23ED # â­ - Used for Skip

# --- NEW CHARACTERS FOR UPDATED MOCKUP ---
$Char_HeavyLine   = [char]0x2501 # â” - Used for main headers and footers
$Char_LightLine   = [char]0x2500 # â”€ - Used for prompt top border and legend title
$Char_Overline    = [char]0x203E # â€¾ - Used for table header separator

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
    # Added [string] type cast to DefaultString to fix .Length error on char inputs
    param($ColorName, $ANSI, $About, $Where, [string]$DefaultString, $ColorCode) 

    # Column Width Configuration
    $Width_TextColor   = 11
    # ANSI Width matches Header (ANSI:4 + Pad:3)
    $Width_ANSI        = 7  
    # Width_About matches the standardized 8-character string length
    $Width_About       = 8  
    $Width_Where       = 8  
    
    # Apply dynamic color to TextColor and pad the result (11 characters) - RIGHT ALIGNED
    $CNameUncoloredPadded = $ColorName.PadLeft($Width_TextColor)
    
    $ANSIPadded   = $ANSI.PadRight($Width_ANSI)
    # PadLeft won't add spaces if length matches $Width_About exactly.
    $AboutPadded  = $About.PadLeft($Width_About) 
    $WherePadded  = $Where.PadRight($Width_Where) # LEFT ALIGNED
    
    # Assemble the output line (5 columns + spacing for DefaultString)
    # Logic: Indent -> ColorName -> ANSI -> About -> Where -> Content
    $OutputLine = " ${ColorCode}${CNameUncoloredPadded}${Reset} $ANSIPadded$AboutPadded $WherePadded${ColorCode}$DefaultString${Reset}"
    
    Write-Host $OutputLine
}

# ============================================================================
# VISUAL EXAMPLES MODE (DEFAULT) - COLOR USAGE CHART
# ============================================================================
function Show-VisualExamples {
    param([bool]$ShowFormattingRules = $false)

    Clear-Host
    # Add empty line above the title block
    Write-Output ""

    # --- TOP TITLE ---
    # Centered Header Title Line
    $PatchW11Title = " $Char_HeavyLine PatchW11 $Char_HeavyLine"
    $PatchW11Padding = [Math]::Floor((60 - $PatchW11Title.Length) / 2)
    Write-Output (" " * $PatchW11Padding + "$Bold$FGCyan$PatchW11Title$Reset")
    
    # SCRIPT OUTPUT RULES sub-header
    $SubText = "SCRIPT OUTPUT RULES" 
    $SubPadding = [Math]::Floor((60 - $SubText.Length) / 2)
    Write-Output (" " * $SubPadding + "$Bold$FGCyan$SubText$Reset")

    # --- PART 1: SCRIPT OUTPUT LEGEND ---

    # DarkBlue Separator Line (60 Heavy Lines)
    Write-Output "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"

    # Legend Title (Centered with Light Lines)
    $LegendTitle = "${FGCyan}$Char_LightLine Script Output LEGEND $Char_LightLine$Reset"
    $LegendTitlePadding = [Math]::Floor((60 - 24) / 2)
    Write-Output (" " * $LegendTitlePadding + $LegendTitle)

    # Table Header
    Write-Output ""
    $Header_TextColor = "Color".PadLeft(11) 
    $Header_ANSI_Text = "ANSI"
    $Header_ANSI_Pad  = " " * 3
    # Header: " About  " (8 chars), "A" is at index 1
    $Header_About     = "${FGBlack}${BGWhite} About  ${Reset}" 
    $Header_Where     = "Where".PadRight(8) 
    $Header_DefaultString = "Default_String"
    
    Write-Output " ${FGGray}$Header_TextColor ${FGGray}$Header_ANSI_Text${Reset}$Header_ANSI_Pad$Header_About ${FGGray}$Header_Where$Header_DefaultString$Reset"

    # Table Header Separator (Overlines)
    Write-Output "$FGDarkGray$([string]$Char_Overline * 60)$Reset"

    # --- ROW DATA ---
    
    # 1. Cyan (Header Title)
    $CyanDefaultString = "    $Char_HeavyLine PatchW11 $Char_HeavyLine"
    # " Script " (8 chars), "S" is at index 1 (Matches Header "A")
    $CyanAbout = "${FGBlack}${BGCyan} Script ${Reset}"
    Write-Row "Cyan"       "\e[96m" $CyanAbout "Hdr/Ftr" $CyanDefaultString $FGCyan
    
    # 2. DarkBlue (Header Boundary)
    $DarkBlueDefaultString = "$([string]$Char_HeavyLine * 20)"
    $DarkBlueAbout = "${FGBlack}${BGDarkBlue} Script ${Reset}"
    Write-Row "DarkBlue"   "\e[34m" $DarkBlueAbout "Lines" $DarkBlueDefaultString $FGDarkBlue

    # 3. Green (SCRIPT Success)
    $GreenDefaultString = "   $Char_HeavyCheck Success!"
    $GreenAbout = "${FGBlack}${BGGreen} Script ${Reset}"
    Write-Row "Green"      "\e[92m" $GreenAbout "Output" $GreenDefaultString $FGGreen

    # 4. Red (SCRIPT Failure)
    $RedDefaultString = "   $Char_RedCross Failure!"
    $RedAbout = "${FGBlack}${BGRed} Script ${Reset}"
    Write-Row "Red"        "\e[91m" $RedAbout "Output" $RedDefaultString $FGRed
    
    # 5. Yellow (Input Keypress)
    $YellowContent = "    $Char_Finger ${FGBlack}${BGYellow}[Key]${Reset}"
    $YellowAbout = "${FGBlack}${BGYellow} Script ${Reset}"
    Write-Row "Yellow"     "\e[93m" $YellowAbout "Input" $YellowContent $FGYellow
    
    # 6. White (Body Title)
    $WhiteContent = "      $Char_HeavyMinus" 
    # Adjusted to 1 leading and 3 trailing spaces (Total 8 chars) to align "Body"
    $WhiteAbout = " ${FGWhite}BOLD   ${Reset}"
    Write-Row "White"      "\e[97m" $WhiteAbout "Body" $WhiteContent $FGWhite
    
    # 7. Gray (Body Text)
    $GrayContent = "      $Char_Hyphen"
    $GrayAbout = "${FGGray} regular${Reset}"
    Write-Row "Gray"       "\e[37m" $GrayAbout "Body" $GrayContent $FGGray

    # 8. DarkGray (Body Boundary)
    $DarkGrayDefaultString = "$([string]$Char_LightLine * 20)"
    $DarkGrayAbout = "${FGWhite}${BGDarkGray} System ${Reset}"
    Write-Row "DarkGray"   "\e[90m" $DarkGrayAbout "Lines" $DarkGrayDefaultString $FGDarkGray
    
    # 9. DarkGreen (System Enabled)
    $DarkGreenDefaultString = "   $Char_BallotCheck  ENABLED"
    $DarkGreenAbout = "${FGWhite}${BGDarkGreen} System ${Reset}"
    Write-Row "DarkGreen"  "\e[32m" $DarkGreenAbout "Output" $DarkGreenDefaultString $FGDarkGreen

    # 10. DarkRed (System Disabled)
    $DarkRedDefaultString = "   ${FGDarkRed}$Char_RedCross DISABLED${Reset}"
    $DarkRedAbout = "${FGWhite}${BGDarkRed} System ${Reset}"
    Write-Row "DarkRed"    "\e[31m" $DarkRedAbout "Output" $DarkRedDefaultString $FGDarkRed

    # 11. DarkYellow (System Warning)
    $DarkYellowDefaultString = "   $Char_Warn  WARNING"
    $DarkYellowAbout = "${FGWhite}${BGDarkYellow} System ${Reset}"
    Write-Row "DarkYellow" "\e[33m" $DarkYellowAbout "Output" $DarkYellowDefaultString $FGDarkYellow

    # Footer/Prompt Seperators
    Write-Output "$FGDarkGray$([string]$Char_LightLine * 60)$Reset"
    Write-Output ""
    Write-Output "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"
    
    # --- PART 2: SCRIPT OUTPUT FORMATTING ---
    if ($ShowFormattingRules) {
        $DefaultsTitle = "${FGCyan}$Char_EnDash Script Output FORMATTING $Char_EnDash$Reset"
        $LegendTitlePadding = [Math]::Floor((60 - 28) / 2)
        Write-Output (" " * $LegendTitlePadding + $DefaultsTitle)
        
        Write-Output ""
        Write-Output "  ${FGWhite}A. Text Formatting:$Reset"
        Write-Output "     ${FGGray}1. Never split whole words over multiple lines.$Reset"
        Write-Output "     ${FGGray}2. Default alignment: Center-align$Reset"
        Write-Output "     ${FGGray}3. Body Alignment: Left-align; 2 space indentation$Reset"
        Write-Output "     ${FGGray}4. Boundaries composed of (`"$Char_EmDash`" * 60)$Reset"
        Write-Output "     ${FGGray}5. Optimize output for window 60 characters in length$Reset"
        Write-Output "     ${FGGray}6. Structured Status Display (Write-FlexLine):$Reset"
        Write-Output "         Highlight positive status states (Active/On) using$Reset"
        Write-Output "         a background color (e.g., `$BGDarkGreen).$Reset"
        Write-Output "     ${FGGray}7. Always use `$FGGray for informational text that is $Reset"
        Write-Output "         not a status or title.$Reset"
    }
}

#============================================================================
# MAIN EXECUTION
#============================================================================
if ($ShowRules) {
    Show-VisualExamples -ShowFormattingRules $true
    Write-Output "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    $FooterPadding = [Math]::Floor((60 - $FooterText.Length) / 2)
    Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor Cyan
} else {
    Show-VisualExamples -ShowFormattingRules $false
    $PromptStr = "${FGWhite}$Char_Keyboard  Press${FGDarkGray} ${FGYellow}$Char_Finger [Enter]${FGDarkGray} ${FGWhite}to${FGDarkGray} ${FGYellow}EXPAND${FGDarkGray} ${FGWhite}|${FGDarkGray} or any other key ${FGWhite}to SKIP$Char_Skip${Reset}"
    $VisibleText = "$Char_Keyboard  Press $Char_Finger [Enter] to EXPAND | or any other key to SKIP$Char_Skip"
    $PromptPadding = [Math]::Max(0, [Math]::Floor((60 - $VisibleText.Length) / 2))
    $PromptCursorTop = [Console]::CursorTop
    
    Write-Output (" " * $PromptPadding + $PromptStr)
    Write-Output "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"
    Write-Output ""
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    $FooterPadding = [Math]::Floor((60 - $FooterText.Length) / 2)
    Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor Cyan

    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    if ($key.VirtualKeyCode -eq 13) { 
        Show-VisualExamples -ShowFormattingRules $true
        Write-Output "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset"
        Write-Output ""
        Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor Cyan
    } else {
        try {
            [Console]::SetCursorPosition(0, $PromptCursorTop)
            Write-Output (" " * 80)
            [Console]::SetCursorPosition(0, $PromptCursorTop + 1)
            Write-Output (" " * 80)
            [Console]::SetCursorPosition(0, $PromptCursorTop + 4)
        } catch {}
    }
}

# Final exit spacing
1..5 | ForEach-Object { Write-Output "" }