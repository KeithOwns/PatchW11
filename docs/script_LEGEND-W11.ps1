# Set encoding to UTF-8 for symbols
[Console]::OutputEncoding = `
    [System.Text.Encoding]::UTF8

Clear-Host

# Added 3 newlines after the header (`n`n`n)
Write-Host "`nPowerShell SCRIPT LEGEND -- PatchW11"
Write-Host ("=" * 50)
Write-Host "`n`n`n"

# Legend mappings
# Boundary lines are exactly 50 characters long

Write-Host "DarkBlue  = Section boundary lines" `
    -ForegroundColor DarkBlue
Write-Host "            (50 chars) ----" `
    -ForegroundColor DarkBlue
Write-Host "            Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "(`"─`" * 50) -Fg DarkBlue" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "Cyan      = Section Titles / Icons" `
    -ForegroundColor Cyan
Write-Host "            Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"`$Icon `$Title`" -Fg Cyan" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "DarkCyan  = ✓ Checkmark (Success)" `
    -ForegroundColor DarkCyan
Write-Host "            Use: Write-StatusIcon" `
    -NoNewline -ForegroundColor Gray
Write-Host " -IsEnabled `$true" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "DarkRed   = ✗ Cross Mark (Failure)" `
    -ForegroundColor DarkRed
Write-Host "            Use: Write-StatusIcon" `
    -NoNewline -ForegroundColor Gray
Write-Host " -IsEnabled `$false" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "Yellow    = Warnings / User Prompts" `
    -ForegroundColor Yellow
Write-Host "            Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"  ⚠ Message`" -Fg Yellow" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "White     = Standard Text / Config" `
    -ForegroundColor White
Write-Host "            Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"Description`" -Fg White" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "Gray      = Info / Context / Details" `
    -ForegroundColor Gray
Write-Host "            Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"  • Detail...`" -Fg Gray" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "Green     = Success / Footer Text" `
    -ForegroundColor Green
Write-Host "            Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"  ✓ Done`" -Fg Green" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "DarkGreen = Main Script Title" `
    -ForegroundColor DarkGreen
Write-Host "            Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"TITLE`" -Fg DarkGreen" `
    -ForegroundColor Gray

# 5 empty lines at the bottom
Write-Host "`n`n`n`n`n"
