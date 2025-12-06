# Clears the console window as required.
Clear-Host

# Define ANSI Reset (if running in a modern terminal supporting it)
$Reset = "`e[0m"
$Bold = "`e[1m"

# --- ANSI Escape Codes for Backgrounds ---
$BGWhite = "`e[107m"   # Background Bright White
$BGLightGray = "`e[47m" # Background White (Light Gray)
$BGGrayTerminal = "`e[100m" # Background Bright Black (Often maps to Gray)
$BGDarkGray = "`e[40m" # Background Black (Often maps to Dark Gray)
$FGBlack = "`e[30m"   # Foreground Black
$FGWhite = "`e[97m"   # Foreground Bright White

# Define Emojis
$Check = "✅"
$Cross = "❎"
$Ballot = "☑"
# Removed HeavyX (✘)
$CrossMark = "❌" 
$HeavyCheck = "✔"

# Format: ANSI Fg (0), ANSI Bg (1), Color Name (2), Ballot (3), Check (4), Cross (5), CrossMark (6), HeavyCheck (7)
# Added one extra space between {3} and {4}
$LineFormat = "{0,-9} {1,-9} {2,-13} {3}  {4} {5} {6} {7}" 
$PaddingLength = 57 # Increased padding by 1 to account for the extra space

# --- Function: Show-ConsolePalette ---
# Displays a matrix of all ConsoleColor combinations
function Show-ConsolePalette {
    <#
    # Source - https://stackoverflow.com/a
    # Posted by Tim Abell, modified by community. See post 'Timeline' for change history
    # Retrieved 2025-12-06, License - CC BY-SA 4.0

    $colors = [enum]::GetValues([System.ConsoleColor])
    Foreach ($bgcolor in $colors){
        Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }
        Write-Host " on $bgcolor"
    }
    #>
}

# --- Custom Write function for the White inverted row ---
function Write-InvertedWhiteRow {
    param([string]$ansiFg, [string]$ansiBg, [string]$colorName, [string]$ballot, [string]$check, [string]$cross, [string]$crossMark, [string]$heavyCheck)
    $content = $LineFormat -f $ansiFg, $ansiBg, $colorName, $ballot, $check, $cross, $crossMark, $heavyCheck
    $paddedContent = $content.PadRight($PaddingLength)
    Write-Output "$BGWhite$FGBlack$paddedContent$Reset"
}

# --- Custom Write function for the Gray inverted row ---
function Write-InvertedGrayRow {
    param([string]$ansiFg, [string]$ansiBg, [string]$colorName, [string]$ballot, [string]$check, [string]$cross, [string]$crossMark, [string]$heavyCheck)
    $content = $LineFormat -f $ansiFg, $ansiBg, $colorName, $ballot, $check, $cross, $crossMark, $heavyCheck
    $paddedContent = $content.PadRight($PaddingLength)
    # Changed from $BGGrayTerminal (100m) to $BGLightGray (47m)
    Write-Output "$BGLightGray$FGBlack$paddedContent$Reset"
}

# --- Generic Helper for Standard Inverted Rows ---
function Write-InvertedStandardRow {
    param(
        [string]$ansiFg,
        [string]$ansiBg,
        [string]$name,
        [ConsoleColor]$bgColor,
        [ConsoleColor]$fgColor
    )
    $content = $LineFormat -f $ansiFg, $ansiBg, $name, $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck
    $padded = $content.PadRight($PaddingLength)
    Write-Host $padded -BackgroundColor $bgColor -ForegroundColor $fgColor
}

# --- Main Execution ---

# 1. Print the Matrix (Currently commented out)
Show-ConsolePalette

Write-Output "$Bold$FGWhite—— POWERSHELL COLORS (BY TEMPERATURE) ——$Reset"

# --- Header ---
# Updated format string to match $LineFormat (extra space between {3} and {4})
Write-Output ("{0,-9} {1,-9} {2,-13} {3}  {4} {5} {6} {7}" -f "ANSI Fg", "ANSI Bg", "COLOR NAME", "☑", "✅", "❎", "❌", "✔")
Write-Output ("-" * 57)

# --- Neutral Colors ---
Write-Host ($LineFormat -f "\e[97m", "\e[40m", "White", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor White
Write-Host ($LineFormat -f "\e[37m", "\e[40m", "Gray", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor Gray
Write-Host ($LineFormat -f "\e[90m", "\e[40m", "DarkGray", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor DarkGray

# --- Cool Colors ---
Write-Host ($LineFormat -f "\e[92m", "\e[40m", "Green", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor Green
Write-Host ($LineFormat -f "\e[32m", "\e[40m", "DarkGreen", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor DarkGreen
Write-Host ($LineFormat -f "\e[96m", "\e[40m", "Cyan", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor Cyan
Write-Host ($LineFormat -f "\e[36m", "\e[40m", "DarkCyan", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor DarkCyan
Write-Host ($LineFormat -f "\e[94m", "\e[40m", "Blue", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor Blue
Write-Host ($LineFormat -f "\e[34m", "\e[40m", "DarkBlue", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor DarkBlue

# --- Warm Colors ---
Write-Host ($LineFormat -f "\e[91m", "\e[40m", "Red", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor Red
Write-Host ($LineFormat -f "\e[31m", "\e[40m", "DarkRed", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor DarkRed
Write-Host ($LineFormat -f "\e[95m", "\e[40m", "Magenta", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor Magenta
Write-Host ($LineFormat -f "\e[35m", "\e[40m", "DarkMagenta", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor DarkMagenta
# Added Yellow (ANSI 93m)
Write-Host ($LineFormat -f "\e[93m", "\e[40m", "Yellow", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor Yellow
Write-Host ($LineFormat -f "\e[33m", "\e[40m", "DarkYellow", $Ballot, $Check, $Cross, $CrossMark, $HeavyCheck) -ForegroundColor DarkYellow

# --- Neutral Colors (Inverted) ---
Write-InvertedWhiteRow -ansiFg "\e[30m" -ansiBg "\e[107m" -colorName "White" -ballot $Ballot -check $Check -cross $Cross -crossMark $CrossMark -heavyCheck $HeavyCheck
# Updated Background ANSI code label to \e[47m to match the new background color
Write-InvertedGrayRow -ansiFg "\e[30m" -ansiBg "\e[47m" -colorName "Gray" -ballot $Ballot -check $Check -cross $Cross -crossMark $CrossMark -heavyCheck $HeavyCheck
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[100m" -name "DarkGray" -bgColor DarkGray -fgColor Black

# --- Cool Colors (Inverted) ---
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[102m" -name "Green" -bgColor Green -fgColor Black
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[42m" -name "DarkGreen" -bgColor DarkGreen -fgColor Black
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[106m" -name "Cyan" -bgColor Cyan -fgColor Black
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[46m" -name "DarkCyan" -bgColor DarkCyan -fgColor Black
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[104m" -name "Blue" -bgColor Blue -fgColor Black
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[44m" -name "DarkBlue" -bgColor DarkBlue -fgColor Black

# --- Warm Colors (Inverted) ---
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[101m" -name "Red" -bgColor Red -fgColor Black
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[41m" -name "DarkRed" -bgColor DarkRed -fgColor Black
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[105m" -name "Magenta" -bgColor Magenta -fgColor Black
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[45m" -name "DarkMagenta" -bgColor DarkMagenta -fgColor Black
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[103m" -name "Yellow" -bgColor Yellow -fgColor Black
Write-InvertedStandardRow -ansiFg "\e[30m" -ansiBg "\e[43m" -name "DarkYellow" -bgColor DarkYellow -fgColor Black

# Writes 5 empty lines to the console before the script exits.
Write-Output "`n`n`n`n`n"