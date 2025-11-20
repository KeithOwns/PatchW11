# Set console output encoding to UTF-8 to ensure all Unicode and Emoji
# characters display correctly on the PowerShell console.
Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- ANSI Escape Sequences for Color Inversion ---
$Reset = "`e[0m"

# Specific sequences for background/foreground
$BGB = "`e[40m`e[97m" # Black BG, White FG (B)
$BGW = "`e[47m`e[30m" # White BG, Black FG (W)
# New variable for Dark Blue Background (REMOVED, now using $BGB or BlackSpace)
$BGDarkBlue = "`e[44m`e[97m" # Dark Blue BG, White FG
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

# NEW: Separator pattern {B B B B D W W W} -> {B B B B B W W W}
$SeparatorPattern = (
    $BGB + " " + $BGB + " " + $BGB + " " + $BGB + " " + # B B B B
    $BGB + " " +                                        # D -> B
    $BGW + " " + $BGW + " " + $BGW + " "                # W W W
) + $Reset

# Empty line below (8 spaces) - REMOVED "|"
$EmptyLine8NoPipe = (" " * $SymbolColumnWidth)

# 1. Print Header (adjusting for 8-char width)
Write-Output " Unicode | Symbol"

# NEW: Add line of 50 dark blue Em Dashes ("—") - FGDarkBlue remains
Write-Output "$FGDarkBlue$((('—') * 50))$Reset"

# 3. Loop through data and print manually formatted strings
for ($i = 0; $i -lt $SymbolData.Count; $i++) {
    $Data = $SymbolData[$i]
    
    # Prepare Unicode column, padded on the LEFT for right alignment (7 characters wide)
    $UnicodeColumn = $Data.Unicode.PadLeft(7)
    
    # Swapped order: Secondary symbol (B BG) then Primary symbol (W BG)
    $Symbol1_Char = $BGB + $Data.Symbol  # Symbol 1 is Secondary (1 char wide)
    $Symbol2_Char = $BGW + $Data.Symbol  # Symbol 2 is Primary (1 char wide)
    
    # DarkBlueSeparator is now BlackSpace (B)
    $DarkBlueSeparator = $BGB + " " 
    $BlackSpace = $BGB + " " # Black space (B), 1 char wide
    $WhiteSpace = $BGW + " " # New White space (W), 1 char wide

    # --- Print Separator Pattern ABOVE the data row ---
    Write-Output "         | $SeparatorPattern"

    # --- Formatting for Rows 0 and 1 (U+1F5F8 and U+2713) ---
    if ($i -le 1) {
        
        # Custom logic for U+1F5F8 (Index 0) and U+2713 (Index 1) - SHIFT FIRST SYMBOL RIGHT
        if ($i -le 1) {
            # New Structure: [B s] [B s] [B S1] [B s] [B s] [W s] [W S2] [W s] (8 colored chars)
             $SymbolColumnContent = (
                $BGB + " " +          # 1. B (Space) - Empty
                $BGB + " " +          # 2. B (Space) - Empty (Shifted from pos 2)
                $BGB + $Data.Symbol + # 3. B (Symbol 1) - Inverted (Now in pos 3)
                $BlackSpace +         # 4. Black Space (B)
                $DarkBlueSeparator +  # 5. DARK BLUE SEPARATOR (Now B)
                $WhiteSpace +         # 6. NEW: White Space (W)
                $BGW + $Data.Symbol + # 7. W (Symbol 2) - Primary
                $BGW + " "            # 8. W (Space)
            )
        }
        
        # Total colored width is 8. No padding needed.
        $SymbolColumnOutput = $SymbolColumnContent + $Reset
        
        # Output the data row (SWAPPED ORDER: Unicode then Symbol)
        Write-Output " $UnicodeColumn ${FGDarkBlue}|${Reset} $SymbolColumnOutput"
        
        # Print the Separator Pattern BELOW (8 spaces)
        Write-Output "         | $SeparatorPattern"
        
        # Print the empty line below
        Write-Output " $EmptyLine8NoPipe" 

    } else {
        # --- Custom 8-char formatting for U+2714, U+1F5F9, U+2611, U+2705 (Indices 2, 3, 4, 5) ---
        
        # Default content pattern for rows 2, 3: [s B] [S1 B] [s B] [NEW B s] [B s] [W s] [S2 W] [s W] (8 colored chars)
        $SymbolColumnContent = (
            $BGB + " " +          # 1. s (B)
            $BGB + $Data.Symbol + # 2. S1 (B)
            ($BGB + " ") +        # 3. s (B) - Padding space for S1
            $BlackSpace +         # 4. Black Space (B)
            $DarkBlueSeparator +  # 5. DARK BLUE SEPARATOR (Now B)
            $WhiteSpace +         # 6. NEW: White Space (W)
            $BGW + $Data.Symbol + # 7. S2 (W)
            $BGW + " "            # 8. s (W)
        )

        # Custom logic for U+1F5F9 (Index 3) - APPLY SHIFT
        if ($i -eq 3) {
            # New Structure: [B s] [B s] [B S1] [B s] [B s] [W s] [W S2] [W s] (8 colored chars)
            $SymbolColumnContent = (
                $BGB + " " +          # 1. B (Space) - Empty
                $BGB + " " +          # 2. B (Space) - Empty (Shifted from pos 2)
                $BGB + $Data.Symbol + # 3. B (Symbol 1) - Inverted (Now in pos 3)
                $BlackSpace +         # 4. Black Space (B)
                $DarkBlueSeparator +  # 5. DARK BLUE SEPARATOR (Now B)
                $WhiteSpace +         # 6. NEW: White Space (W)
                $BGW + $Data.Symbol + # 7. W (Symbol 2) - Primary
                $BGW + " "            # 8. W (Space)
            )
        }
        
        # Custom logic for U+2611 (Index 4) - Pattern {B W W B B B B B} (8 colored chars) - NOT SWAPPED
        if ($i -eq 4) {
            $SymbolColumnContent = (
                $BGB + " " +                 # 1. B (Space)
                ($BGW + $Data.Symbol) +      # 2. W (S1 - Primary Symbol)
                $BGW + " " +                 # 3. W (Space)
                $BGB + " " +                 # 4. B (Space)
                $DarkBlueSeparator +         # 5. D -> B (Black Separator)
                $BGB + " " +                 # 6. B (Space)
                ($BGB + $Data.Symbol) +      # 7. B (S2 - Secondary Symbol)
                $BGB + " "                   # 8. B (Space)
            )
            # Row 4 content is 8 colored characters. Needs 0 reset space.
            $Padding = ""
        }
        
        # Custom logic for U+2705 (Index 5) - Trimmed padding
        if ($i -eq 5) {
            # Pattern: [s B] [S1 B] [B s] [B s] [W s] [S2 W] [s W] (7 colored chars)
            $SymbolColumnContent = (
                $BGB + " " +          # 1. s (B)
                $BGB + $Data.Symbol + # 2. S1 (B)
                $BlackSpace +         # 3. Black Space (B)
                $DarkBlueSeparator +  # 4. DARK BLUE SEPARATOR (Now B)
                $WhiteSpace +         # 5. NEW: White Space (W)
                ($BGW + $Data.Symbol) + # 6. S2 (W) - White BG
                ($BGW + " ")          # 7. s (W) - Trailing space
            )
            # Row 5 content is 7 colored characters. Needs 1 reset space.
            $Padding = " "
        }
        
        # Determine Padding (to make total width 8)
        $Padding = "" # Default for Rows 2, 3 (8 colored chars + 0 reset spaces = 8)
        
        # Override if custom padding is needed
        if ($i -eq 4) { $Padding = "" }
        if ($i -eq 5) { $Padding = " " } # 7 colored chars + 1 reset space = 8
        
        # If row 3 used the custom shift logic, it needs 0 padding (it's 8 chars wide)
        if ($i -eq 3) { $Padding = "" }

        $SymbolColumnOutput = $SymbolColumnContent + $Reset + $Padding
        
        # Output the data row (SWAPPED ORDER: Unicode then Symbol)
        Write-Output " $UnicodeColumn ${FGDarkBlue}|${Reset} $SymbolColumnOutput"
        
        # Print the Separator Pattern BELOW (8 spaces)
        Write-Output "         | $SeparatorPattern"
        
        # 3. Print the empty line below
        Write-Output " $EmptyLine8NoPipe" 
    }
}
