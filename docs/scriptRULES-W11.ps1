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
    Version: 7.87 (Cyan Legend/Defaults Titles - Dashes Fixed)
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
$Char_XSquare     = [char]0x26DD # ⛝ - Used for DarkRed Disabled
$Char_NoEntry     = [char]0x26D2 # ⛒ - Used for Magenta Error
$Char_Keyboard    = [char]0x2328 # ⌨ - Used for Prompt
$Char_Loop        = [char]::ConvertFromUtf32(0x1F504) # 🔄 - Used for Sub-Header
$Char_Copyright   = [char]0x00A9 # © - Used for Footer
$Char_EmDash      = [char]0x2014 # — - Used for all boundaries (60 dashes)
$Char_EnDash      = [char]0x2013 # – - Used for new White Body Title representation
$Char_Hyphen      = [char]0x002D # - - Used for new DarkCyan and Gray Text representation
$Char_RedCross    = [char]0x274E # ❎ - Used for Red Failure
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
$FGBlack      = "$Esc[30m"  # Foreground Black (For contrast on Yellow/Cyan BG)
$BGYellow     = "$Esc[103m" # High Intensity Background Yellow
$BGCyan       = "$Esc[46m"  # Background Cyan

    # Helper for formatted column output
function Write-Row {
    # Note: HexCode argument is kept for compatibility but ignored in output
    # Added [string] type cast to DefaultString to fix .Length error on char inputs
    param($ColorName, $ANSI, $About, $Type, $HexCode, [string]$DefaultString, $ColorCode) 

    # Column Width Configuration
    $Width_TextColor   = 11
    $Width_ANSI        = 7  
    $Width_About       = 7
    $Width_Type        = 9
    
    # Width 14 to fit "Default_String" (14 chars) exactly
    $Width_DefaultString = 14 
    
    # Apply dynamic color to TextColor and pad the result (11 characters) - RIGHT ALIGNED
    $CNameUncoloredPadded = $ColorName.PadLeft($Width_TextColor)
    
    $ANSIPadded   = $ANSI.PadRight($Width_ANSI)
    $AboutPadded  = $About.PadLeft($Width_About) # RIGHT ALIGNED
    $TypePadded   = $Type.PadRight($Width_Type)

    # Calculate Centering for DefaultString
    # FIX: Strip ANSI codes before calculating length to ensure visual centering is correct
    $CleanDefaultString = $DefaultString -replace "$Esc\[[^m]*m", ""
    $ContentLength = $CleanDefaultString.Length
    
    # Calculate left padding to center the string in a 14-char field
    $PadLeftVal = [Math]::Max(0, [Math]::Floor(($Width_DefaultString - $ContentLength) / 2))
    
    # Assemble the output line (5 columns)
    # Reduced leading indentation from 2 spaces to 1 space
    $OutputLine = " ${ColorCode}${CNameUncoloredPadded}${Reset} $ANSIPadded$AboutPadded $TypePadded   "
    
    # Append the DefaultString content (Centered)
    $OutputLine += (" " * $PadLeftVal) + "${ColorCode}$DefaultString${Reset}"
    
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

    # --- TOP TITLE (Updated) ---
    $TopTitle = "── PatchW11 ──"
    $TitleLength = $TopTitle.Length
    
    # Calculate true center alignment (17 spaces for 60 width / 25 length)
    $TitlePadding = [Math]::Floor((60 - $TitleLength) / 2)
    
    Write-Output (" " * $TitlePadding + "$Bold$FGCyan$TopTitle$Reset")

    # --- SUB-HEADER (Updated) ---
    $SubText = "SCRIPT OUTPUT RULES" 
    $FullSubLength = $SubText.Length
    
    # Calculate centering padding for the sub-header (based on standard centering)
    $SubPadding = [Math]::Floor((60 - $FullSubLength) / 2)
    
    # Sub-header: Just text now, DarkCyan
    Write-Output (" " * $SubPadding + "$Bold$FGDarkCyan$SubText$Reset")

    # --- PART 1: SCRIPT OUTPUT LEGEND ---

    # DarkBlue Separator Line (60 em dashes)
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset" # Boundary on its own line

    # Script Output LEGEND Title (Center-aligned and revised)
    # FIX: Applying FGCyan to the en dashes as requested by the user.
    $LegendTitle = "${FGCyan}$Char_EnDash Script Output LEGEND $Char_EnDash$Reset"
    $LegendTitleLength = 24 # Calculated length: 1+1+20+1+1 = 24 (excluding color codes)
    $LegendTitlePadding = [Math]::Floor((60 - $LegendTitleLength) / 2)
    
    Write-Output (" " * $LegendTitlePadding + $LegendTitle)

    # Table Header (No empty line before header)
    Write-Output ""
    
    # Header: Aligned with data columns using same spacing structure
    $Header_TextColor = "Color".PadLeft(11)  # RIGHT ALIGNED
    $Header_ANSI      = "ANSI".PadRight(7)   # Renamed from ANSIFg
    $Header_About     = "About".PadLeft(7)   # RIGHT ALIGNED
    $Header_Type      = "Type".PadRight(9)
    
    # Center DefaultString Header
    $DefaultStringText = "Default_String" # Changed from DefaultString
    $Width_DefaultString = 14
    $PadLeftHeader = [Math]::Max(0, [Math]::Floor(($Width_DefaultString - $DefaultStringText.Length) / 2))
    $Header_DefaultString = (" " * $PadLeftHeader) + $DefaultStringText
    
    # 1 Space leading indentation (was 2)
    Write-Output " ${FGGray}$Header_TextColor $Header_ANSI$Header_About $Header_Type   $Header_DefaultString$Reset"

    # Table Separator (White, Indented, 56 chars) - CHANGE 2
    Write-Output "$FGWhite  $([string]$Char_EmDash * 56)  $Reset"

    # --- ROW DATA ---
    
    # Hex and CharDefault components
    $HexEmDash = "0x2014 "
    $HexEnDash = "0x2013"
    
    # Boundary String (15 dashes)
    $BoundaryString = [string]$Char_EmDash * 15

    # 1. Cyan (Header Title)
    $CyanDefaultString = "$Char_EmDash$Char_EmDash PatchW11 $Char_EmDash$Char_EmDash"
    Write-Row "Cyan"       "\e[96m" "Hdr/Ftr" "Title"    $HexEmDash $CyanDefaultString $FGCyan
    
    # 2. DarkBlue (Header Boundary)
    Write-Row "DarkBlue"   "\e[34m" "Hdr/Ftr" "Boundary" $HexEmDash $BoundaryString $FGDarkBlue

    # 3. DarkCyan (Output Text)
    Write-Row "DarkCyan"   "\e[36m" "Output" "Text"     "0x2D" $Char_Hyphen $FGDarkCyan

    # 6. White (Body Title)
    Write-Row "White"      "\e[97m" "Body"   "Title"    $HexEnDash $Char_EnDash $FGWhite
    
    # 7. Gray (Body Text)
    Write-Row "Gray"       "\e[37m" "Body"   "Text"     "0x2D" $Char_Hyphen $FGGray

    # 8. DarkGray (Body Boundary)
    Write-Row "DarkGray"   "\e[90m" "Body"   "Boundary" $HexEmDash $BoundaryString $FGDarkGray
    
    # 9. Green (SCRIPT Success)
    Write-Row "Green"      "\e[92m" "SCRIPT" "Success"  "0x2705" $Char_HeavyCheck $FGGreen

    # 10. Red (SCRIPT Failure)
    Write-Row "Red"        "\e[91m" "SCRIPT" "Failure"  "0x274E" $Char_RedCross $FGRed

    # 13. DarkGreen (System Enabled)
    Write-Row "DarkGreen"  "\e[32m" "System" "Enabled"  "0x2611 " $Char_BallotCheck $FGDarkGreen

    # 14. DarkRed (System Disabled)
    Write-Row "DarkRed"    "\e[31m" "System" "Disabled" "0x26DD" " $Char_XSquare " $FGDarkRed

    # 15. DarkYellow (System Warning)
    Write-Row "DarkYellow" "\e[33m" "System" "Warning"  "0x26A0 " $Char_Warn $FGDarkYellow

    # 4. Yellow (Input Keypress) - MOVED TO BOTTOM
    # Only the [Key] part has Black FG and Yellow BG. The finger remains Yellow FG.
    $YellowDefaultString = "$Char_Finger ${FGBlack}${BGYellow}[Key]"
    Write-Row "Yellow"     "\e[93m" "Input"  "Keypress" "0x261B" $YellowDefaultString $FGYellow

    # ADDED EMPTY LINE BELOW YELLOW - CHANGE 3
    Write-Output ""

    # DarkGray Separator Line (60 em dashes)
    Write-Output "$FGDarkGray$([string]$Char_EmDash * 60)$Reset"
    
    # --- PART 2: SCRIPT OUTPUT DEFAULTS (HIDDEN BY DEFAULT) ---

    if ($ShowFormattingRules) {
        
        # Script Output DEFAULTS Title (Center-aligned)
        # UPDATED: Changed default color to FGCyan
        # FIX: Applying FGCyan to the en dashes as requested by the user.
        $DefaultsTitle = "${FGCyan}$Char_EnDash Script Output DEFAULTS $Char_EnDash$Reset"
        $DefaultsTitleLength = 29 # Length without ANSI codes (approximate visible length: 1+1+24+1+1 = 28 but reusing var for safe measure)
        # Recalculating visible length: "– Script Output DEFAULTS –" = 26 chars
        $DefaultsTitlePadding = [Math]::Floor((60 - 26) / 2)
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
        
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================
if ($ShowRules) {
    # If -ShowRules is used, display the full content immediately
    Show-VisualExamples -ShowFormattingRules $true
    
    # Add DarkBlue Separator above Copyright
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"

    # Display Copyright Footer (Centered and Cyan)
    $FooterText = "$Char_Copyright 2025, www.AIIT.support. All Rights Reserved."
    $FooterPadding = [Math]::Floor((60 - $FooterText.Length) / 2)
    Write-Output ""
    # UPDATED: Changed to Cyan
    Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor Cyan
    
} else {
    # 1. Initial State (Rules Hidden)
    Show-VisualExamples -ShowFormattingRules $false

    # 2. Prompt (DarkCyan with Yellow highlights, Centered)
    # Updated PromptStr to use Black Text on Yellow Background for the keys
    Write-Output ""
    $PromptStr = "${FGDarkCyan}$Char_Keyboard  ${FGYellow}Press ${FGYellow}$Char_Finger ${FGBlack}${BGYellow}Enter${Reset}${FGDarkCyan} to Show rules  |  Press ${FGYellow}$Char_Finger ${FGBlack}${BGYellow}Spacebar${Reset}${FGDarkCyan} to Close$Reset"

    # Calculate centering padding
    # Calculate visible length of text without ANSI codes for centering
    $VisibleText = "$Char_Keyboard  Press $Char_Finger Enter to Show rules  |  Press $Char_Finger Spacebar to Close"
    $PromptPadding = [Math]::Floor((60 - $VisibleText.Length) / 2)

    Write-Output (" " * $PromptPadding + $PromptStr)

    # Add DarkBlue Separator above Copyright
    Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"

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

        # Add DarkBlue Separator above Copyright
        Write-Output "$FGDarkBlue$([string]$Char_EmDash * 60)$Reset"

        # Redisplay Copyright (ALWAYS LAST)
        Write-Output ""
        # UPDATED: Changed to Cyan
        Write-Host (" " * $FooterPadding + $FooterText) -ForegroundColor Cyan
    }
}

# Output 5 empty lines before exit (User Requirement)
1..5 | ForEach-Object { Write-Output "" }
