# Clear the window as per your instructions
Clear-Host

# 1. Connected Lines (Seamless)
$connectedLines = @(
    [PSCustomObject]@{ Hex = "0x2014"; Visual = ([string][char]0x2014 * 20); Name = "Em Dash" }
    [PSCustomObject]@{ Hex = "0x005F"; Visual = ("_" * 20); Name = "Low Line" }
    [PSCustomObject]@{ Hex = "0x268A"; Visual = ([string][char]0x268A * 20); Name = "Monogram Yang" }
    [PSCustomObject]@{ Hex = "0x2500"; Visual = ([string][char]0x2500 * 20); Name = "Box Light" }
    [PSCustomObject]@{ Hex = "0x2501"; Visual = ([string][char]0x2501 * 20); Name = "Box Heavy" }
    [PSCustomObject]@{ Hex = "0x2017"; Visual = ([string][char]0x2017 * 20); Name = "Double Low" }
    [PSCustomObject]@{ Hex = "0x2550"; Visual = ([string][char]0x2550 * 20); Name = "Box Double" }
)

# 2. Broken Lines (Gaps)
# Increased padding in other names to pull the 'Heavy Minus' columns left
$brokenLines = @(
    [PSCustomObject]@{ Hex = "0x002D"; Visual = ("-" * 20); Name = "Hyphen-Minus             " }
    [PSCustomObject]@{ Hex = "0x2010"; Visual = ([string][char]0x2010 * 20); Name = "Hyphen                   " }
    [PSCustomObject]@{ Hex = "0x2013"; Visual = ([string][char]0x2013 * 20); Name = "En Dash                  " }
    [PSCustomObject]@{ Hex = "0x2212"; Visual = ([string][char]0x2212 * 20); Name = "Math Minus               " }
    [PSCustomObject]@{ Hex = "0x00AF"; Visual = ([string][char]0x00AF * 20); Name = "Overline                 " }
    [PSCustomObject]@{ Hex = "0xFF0D"; Visual = ([string][char]0xFF0D * 10); Name = "Fullwidth Hyphen           " }
    [PSCustomObject]@{ Hex = "0x2796"; Visual = ([string][char]0x2796 * 10); Name = "Heavy Minus" }
)

Write-Host "--- Connected Line Comparison ---" -ForegroundColor Cyan
$connectedLines | Format-Table -AutoSize

Write-Host "--- Broken Line Comparison ---" -ForegroundColor Yellow
$brokenLines | Format-Table -AutoSize

# Print 5 empty lines at the bottom before exiting
1..5 | ForEach-Object { Write-Host "" }