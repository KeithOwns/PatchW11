# Set encoding to UTF-8 for symbols
[Console]::OutputEncoding = `
    [System.Text.Encoding]::UTF8

Clear-Host

# Added 3 newlines after the header (`n`n`n)
Write-Host "`nPowerShell SCRIPT LEGEND -- PatchW11" -ForegroundColor DarkGreen
Write-Host "--------------------------------------------------" -ForegroundColor DarkBlue
Write-Host "`n`n`n"

# Legend mappings
# Boundary lines are exactly 50 characters long

Write-Host "DarkBlue    = " `
    -NoNewline -ForegroundColor DarkBlue
Write-Host "—" `
    -NoNewline -ForegroundColor Black -BackgroundColor DarkBlue
Write-Host " (Dash) Section boundary lines" `
    -ForegroundColor DarkBlue
Write-Host "Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "(`"─`" * 50) -Fg DarkBlue" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "Cyan        = " `
    -NoNewline -ForegroundColor Cyan
Write-Host "✓" `
    -NoNewline -ForegroundColor Black -BackgroundColor Cyan
Write-Host " (Checkmark) Enabled" `
    -ForegroundColor Cyan
Write-Host "Use: Write-StatusIcon" `
    -NoNewline -ForegroundColor Gray
Write-Host " -IsEnabled `$true" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "DarkRed     = " `
    -NoNewline -ForegroundColor DarkRed
Write-Host "✗" `
    -NoNewline -ForegroundColor Black -BackgroundColor DarkRed
Write-Host " (Cross Mark) Failure" `
    -ForegroundColor DarkRed
Write-Host "Use: Write-StatusIcon" `
    -NoNewline -ForegroundColor Gray
Write-Host " -IsEnabled `$false" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "Red         = " `
    -NoNewline -ForegroundColor Red
Write-Host "🚫" `
    -NoNewline -ForegroundColor Black -BackgroundColor Red
Write-Host " (No Entry Sign) errors" `
    -ForegroundColor Red
Write-Host "Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"" `
    -NoNewline -ForegroundColor Gray
Write-Host "🚫" `
    -NoNewline -ForegroundColor Red -BackgroundColor Black
Write-Host " ERROR`" -Fg Red" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "Yellow      = " `
    -NoNewline -ForegroundColor Yellow
Write-Host "!" `
    -NoNewline -ForegroundColor Black -BackgroundColor Yellow
Write-Host " User Prompts" `
    -ForegroundColor Yellow
Write-Host "Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"Message`" -Fg Yellow" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "DarkYellow  = " `
    -NoNewline -ForegroundColor DarkYellow
Write-Host " ⚠ " `
    -NoNewline -ForegroundColor Black -BackgroundColor DarkYellow
Write-Host " (Warning Sign) Warnings" `
    -ForegroundColor DarkYellow
Write-Host "Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`" ⚠  WARNING`" -Fg DarkYellow" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "White       = " `
    -NoNewline -ForegroundColor White
Write-Host ([char]0x2699) `
    -NoNewline -ForegroundColor White
Write-Host "  Icons / Section Titles" `
    -ForegroundColor White
Write-Host "Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"`$Icon `$Title`" -Fg White" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "Gray        = " `
    -NoNewline -ForegroundColor Gray
Write-Host "i" `
    -NoNewline -ForegroundColor Black -BackgroundColor Gray
Write-Host " Info / Context / Details" `
    -ForegroundColor Gray
Write-Host "Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"  • Detail...`" -Fg Gray" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "DarkGray    = - Hyphen (unavailable)" `
    -ForegroundColor DarkGray
Write-Host "Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"  -`" -Fg DarkGray" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "Green       = " `
    -NoNewline -ForegroundColor Green
Write-Host "✅" `
    -NoNewline -ForegroundColor White -BackgroundColor Green
Write-Host " Success / Complete" `
    -ForegroundColor Green
Write-Host "Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"✅ Complete.`" -Fg Green" `
    -ForegroundColor Gray
Write-Host ""
Write-Host ""

Write-Host "DarkGreen   = [scriptTITLE]" `
    -ForegroundColor DarkGreen
Write-Host "Use: Write-Host " `
    -NoNewline -ForegroundColor Gray
Write-Host "`"TITLE`" -Fg DarkGreen" `
    -ForegroundColor Gray

# 5 empty lines at the bottom
Write-Host "`n`n`n`n`n"
