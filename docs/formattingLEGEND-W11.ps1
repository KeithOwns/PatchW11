# Set console output encoding to UTF-8 to ensure all Unicode and Emoji
# characters display correctly in the PowerShell console.
Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- ANSI Escape Sequences for Color Inversion ---
$Reset = "`e[0m"

# Specific sequences for background/foreground
$BGB = "`e[40m`e[97m" # Black BG, White FG (B)
$BGW = "`e[47m`e[30m" # White BG, Black FG (W)
# Dark blue foreground
$FGDarkBlue = "`e[34m"

# Define the data for the chart as an array of custom objects
$SymbolData = @(
    [PSCustomObject]@{ Symbol = "🗸"; Unicode = "U+1F5F8"; Name = "Light Check Mark" }
    [PSCustomObject]@{ Symbol = "✓"; Unicode = "U+2713"; Name = "Check Mark" }
    [PSCustomObject]@{ Symbol = "✔"; Unicode = "U+2714"; Name = "Heavy Check Mark" }
    [PSCustomObject]@{ Symbol = "🗹"; Unicode = "U+1F5F9"; Name = "Ballot Box with Bold Check" }
    [PSCustomObject]@{ Symbol = "☑"; Unicode = "U+2611"; Name = "Ballot Box with Check" }
    [PSCustomObject]@{ Symbol = "✅"; Unicode = "U+2705"; Name = "White Heavy Check Mark" }
)

# --- Manual Output with Fixed Padding (Fixes ANSI formatting issue) ---

# Define 8-character width for the Symbol column
$SymbolColumnWidth = 8

# New white background line for 8 spaces
$WhiteBackgroundLine8 = "`e[47m`e[30m" + (" " * $SymbolColumnWidth) + $Reset
# Empty line below (8 spaces) - REMOVED "|"
$EmptyLine8NoPipe = (" " * $SymbolColumnWidth)

# 1. Print Header (adjusting for 8-char width)
Write-Output " Unicode | Symbol"

# NEW: Add line of 50 dark blue Em Dashes ("—")
Write-Output "$FGDarkBlue$((('—') * 50))$Reset"

# 3. Loop through data and print manually formatted strings
for ($i = 0; $i -lt $SymbolData.Count; $i++) {
    $Data = $SymbolData[$i]
    
    # Prepare Unicode column, padded on the LEFT for right alignment (7 characters wide)
    $UnicodeColumn = $Data.Unicode.PadLeft(7)
    
    # Swapped order: Secondary symbol (B BG) then Primary symbol (W BG)
    $Symbol1 = $BGB + $Data.Symbol + " " # Symbol 1 is Secondary (2 chars wide)
    $Symbol2 = $BGW + $Data.Symbol + " " # Symbol 2 is Primary (2 chars wide)

    # --- Print White Separator ABOVE the data row ---
    Write-Output "         | $WhiteBackgroundLine8"

    # --- Formatting for Rows 0 and 1 (U+1F5F8 and U+2713) ---
    if ($i -le 1) {
        
        # Both U+1F5F8 (Index 0) and U+2713 (Index 1) use the {WBBBWWWB} pattern and SWAPPED symbols.
        $SymbolColumnContent = (
            $BGW + " " +       # 1. W (Space)
            $BGB + " " +       # 2. B (Space)
            $BGB + $Data.Symbol + # 3. B (Symbol 1) - Inverted
            $BGB + " " +       # 4. B (Space)
            $BGW + " " +       # 5. W (Space)
            $BGW + $Data.Symbol + # 6. W (Symbol 2) - Primary
            $BGW + " " +       # 7. W (Space)
            $BGB + " "        # 8. B (Space)
        )
        
        # Total colored width is 8. No padding needed.
        $SymbolColumnOutput = $SymbolColumnContent + $Reset
        
        # Output the data row (SWAPPED ORDER: Unicode then Symbol)
        Write-Output " $UnicodeColumn | $SymbolColumnOutput"
        
        # Print the white line BELOW (8 spaces)
        Write-Output "         | $WhiteBackgroundLine8"
        
        # Print the empty line below
        Write-Output " $EmptyLine8NoPipe" 

    } else {
        # --- Custom 8-char formatting for U+2714, U+1F5F9, U+2611, U+2705 (Indices 2, 3, 4, 5) ---
        
        # General content pattern for rows 2, 3: [s] [$$] [s] [s] [$$] [s] (6 colored chars)
        $SymbolColumnContent = (
            $BGB + " " +         # 1. s (B)
            $Symbol1 +           # 2. $$ (2 chars wide) - Swapped symbol order (B BG)
            ($BGB + " ") +      # 3. s (B) - Default: space after Symbol1
            $BGW + " " +         # 4. s (W)
            $Symbol2 +           # 5. $$ (2 chars wide)
            $BGW + " "          # 6. s (W)
        )
        
        # Custom logic for U+2611 (Index 4) - 7-char pattern {WWWWBBB}
        if ($i -eq 4) {
             $SymbolColumnContent = (
                # 1. W (Space) - Prepend
                $BGW + " " +
                # 2. W (Primary Symbol)
                $BGW + $Data.Symbol +
                # 3. W (Space) - First space after symbol
                $BGW + " " +
                # 4. W (Space) - Second space after symbol
                $BGW + " " +
                # 5. B (Space)
                $BGB + " " +
                # 6. B (Secondary Symbol)
                $BGB + $Data.Symbol +
                # 7. B (Space)
                $BGB + " "
            )
            # Row 4 content is now 7 colored characters. Needs 1 reset space.
            $Padding = " "
        }
        
        # Custom logic for U+2705 (Index 5) - Trimmed padding
        if ($i -eq 5) {
            # Symbol 1 (First Checkmark) uses BGB (Black BG)
            # Symbol 2 (Second Checkmark) uses BGW (White BG)
            # The pattern is: [s B] [$$ B] [s W] [$$ W] [s W] (6 colored chars)
            $SymbolColumnContent = (
                $BGB + " " +         # 1. s (B)
                $Symbol1 +           # 2. $$ (2 chars wide) - Black BG
                $BGW + " " +         # 3. s (W)
                
                # CHANGED: Symbol 2 (check mark) with White BG
                ($BGW + $Data.Symbol) + 
                # NEW: Space after second checkmark with White BG
                ($BGW + " ") 
            )
            # Row 5 content is 6 colored characters. Needs 2 reset spaces.
            $Padding = "  "
        }
        
        # Determine Padding (to make total width 8)
        $Padding = "  " # Default for Rows 2, 3, 5 (6 colored chars + 2 reset spaces = 8)
        if ($i -eq 4) {
            # Row 4 (U+2611) now has 7 colored characters. Needs 1 reset space.
            $Padding = " "
        }
        
        $SymbolColumnOutput = $SymbolColumnContent + $Reset + $Padding
        
        # Output the data row (SWAPPED ORDER: Unicode then Symbol)
        Write-Output " $UnicodeColumn | $SymbolColumnOutput"
        
        # Print the white line BELOW (8 spaces)
        Write-Output "         | $WhiteBackgroundLine8"
        
        # 3. Print the empty line below
        Write-Output " $EmptyLine8NoPipe" 
    }
}