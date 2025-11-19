# Set encoding to UTF-8 to ensure symbols (✓, ⊘, ✗) display correctly
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host

# Added 3 newlines after the header (`n`n`n)
Write-Host "`nPowerShell SCRIPT LEGEND -- PatchW11"
Write-Host "==================================================`n`n`n"

# Legend mappings formatted as "ColorName = Description"
# Boundary lines are exactly 50 characters long
Write-Host "DarkBlue  = Section boundary lines (50 chars) ----" -ForegroundColor DarkBlue
Write-Host ""
Write-Host ""
Write-Host "DarkGreen = Main Script Title / Major Section" -ForegroundColor DarkGreen
Write-Host ""
Write-Host ""
Write-Host "DarkCyan  = ✓ Checkmark (Enabled)" -ForegroundColor DarkCyan
Write-Host ""
Write-Host ""
Write-Host "DarkGray  = - Hyphen (Not Available) / Info" -ForegroundColor DarkGray
Write-Host ""
Write-Host ""
Write-Host "DarkRed   = ✗ Cross Mark (Disabled)" -ForegroundColor DarkRed
Write-Host ""
Write-Host ""
Write-Host "Gray      = System Info / Minor Details" -ForegroundColor Gray
Write-Host ""
Write-Host ""
Write-Host "Green     = Positive System Status / Success" -ForegroundColor Green
Write-Host ""
Write-Host ""
Write-Host "Cyan      = Section Titles / @ (Icons) / Headers" -ForegroundColor Cyan
Write-Host ""
Write-Host ""
Write-Host "Red       = Negative System Status / Critical" -ForegroundColor Red
Write-Host ""
Write-Host ""
Write-Host "Yellow    = User Prompt > / Warnings" -ForegroundColor Yellow
Write-Host ""
Write-Host ""
Write-Host "White     = Script Information / Standard Text" -ForegroundColor White

# 5 empty lines at the bottom
Write-Host "`n`n`n`n`n"