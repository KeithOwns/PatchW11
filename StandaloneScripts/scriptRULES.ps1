#Requires -RunAsAdministrator
<#
.SYNOPSIS
    WinAuto PowerShell Script Writing Rules and Visual Examples

.DESCRIPTION
    This script displays visual examples of WinAuto scripting standards by default.
    Includes the latest Script Output DEFAULTS and standardized visual legend.
    This version is STANDALONE and inlines the standard WinAuto UI helper functions.

.PARAMETER ShowRules
    Display the complete text-based rules documentation instead of visual examples.

.EXAMPLE
    .\scriptRULES.ps1
    Shows visual examples of formatting standards (default behavior)

.NOTES
    Author: WinAuto Team
    Version: 2.1.0 (Standardized Output)
    Repository: https://github.com/KeithOwns/WinAuto
#>

param(
    [switch]$ShowRules
)

# --- INITIAL SETUP ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Clear-Host

# --- GLOBAL RESOURCES (Inlined from wa.ps1) ---
# Centralized definition of ANSI colors and Unicode characters.

# --- ANSI Escape Sequences ---
$Esc = [char]0x1B
$Reset = "$Esc[0m"
$Bold = "$Esc[1m"

# Script Palette (Foreground)
$FGCyan = "$Esc[96m"
$FGDarkBlue = "$Esc[34m"
$FGGreen = "$Esc[92m"
$FGRed = "$Esc[91m"
$FGYellow = "$Esc[93m"
$FGDarkGray = "$Esc[90m"
$FGDarkRed = "$Esc[31m"
$FGDarkGreen = "$Esc[32m"
$FGWhite = "$Esc[97m"
$FGGray = "$Esc[37m"
$FGDarkYellow = "$Esc[33m"
$FGBlack = "$Esc[30m"

# Script Palette (Background)
$BGDarkGreen = "$Esc[42m"
$BGDarkGray = "$Esc[100m"
$BGYellow = "$Esc[103m"
$BGRed = "$Esc[41m"
$BGWhite = "$Esc[107m"

# --- Unicode Icons & Characters ---
$Char_HeavyCheck = "[v]" 
$Char_Warn = "!" 
$Char_BallotCheck = "[v]" 

$Char_Copyright = "(c)" 
$Char_Finger = "->" 
$Char_CheckMark = "v" 
$Char_FailureX = "x" 
$Char_RedCross = "x"
$Char_Hyphen = "-" 
$Char_EnDash = "-"

# --- FORMATTING HELPERS (Inlined from wa.ps1) ---
function Get-VisualWidth {
    param([string]$String)
    $Width = 0
    $Chars = $String.ToCharArray()
    for ($i = 0; $i -lt $Chars.Count; $i++) {
        if ([char]::IsHighSurrogate($Chars[$i])) { $Width += 2; $i++ } else { $Width += 1 }
    }
    return $Width
}

function Set-ConsoleSnapRight {
    param([int]$Columns = 60)
    try {
        $code = 'using System; using System.Runtime.InteropServices; namespace WinAutoNative { [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left; public int Top; public int Right; public int Bottom; } public class ConsoleUtils { [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow(); [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint); [DllImport("user32.dll")] public static extern int GetSystemMetrics(int nIndex); [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect); } }'
        if (-not ([System.Management.Automation.PSTypeName]"WinAutoNative.ConsoleUtils").Type) {
            Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
        }
        $buffer = $Host.UI.RawUI.BufferSize
        $window = $Host.UI.RawUI.WindowSize
        $targetHeight = $Host.UI.RawUI.MaxWindowSize.Height
        
        # 1. Set Width/Buffer
        if ($Columns -ne $window.Width) {
            if ($Columns -lt $window.Width) {
                $window.Width = $Columns; $Host.UI.RawUI.WindowSize = $window
                $buffer.Width = $Columns; $Host.UI.RawUI.BufferSize = $buffer
            }
            else {
                $buffer.Width = $Columns; $Host.UI.RawUI.BufferSize = $buffer
                $window.Width = $Columns; $Host.UI.RawUI.WindowSize = $window
            }
        }

        if ($buffer.Height -lt $targetHeight) {
            $buffer.Height = $targetHeight
            $Host.UI.RawUI.BufferSize = $buffer
        }
        $window.Height = $targetHeight
        $Host.UI.RawUI.WindowSize = $window

        # 2. Position Adjustment
        $hWnd = [WinAutoNative.ConsoleUtils]::GetConsoleWindow()
        $screenW = [WinAutoNative.ConsoleUtils]::GetSystemMetrics(0) # SM_CXSCREEN
        $screenH = [WinAutoNative.ConsoleUtils]::GetSystemMetrics(1) # SM_CYSCREEN
        
        # Get actual pixel width after column resize
        $rect = New-Object WinAutoNative.RECT
        if ([WinAutoNative.ConsoleUtils]::GetWindowRect($hWnd, [ref]$rect)) {
            $pixelW = $rect.Right - $rect.Left
            $targetX = $screenW - $pixelW
            
            # Snap to Right with fixed width
            [WinAutoNative.ConsoleUtils]::MoveWindow($hWnd, $targetX, 0, $pixelW, $screenH, $true) | Out-Null
        }
    }
    catch {}
}

Set-ConsoleSnapRight -Columns 60

function Write-Centered {
    param([string]$Text, [int]$Width = 60, [string]$Color)
    $cleanText = $Text -replace "$Esc\[[0-9;]*m", ""
    $padLeft = [Math]::Floor(($Width - $cleanText.Length) / 2)
    if ($padLeft -lt 0) { $padLeft = 0 }
    if ($Color) { Write-Host (" " * $padLeft + "$Color$Text$Reset") }
    else { Write-Host (" " * $padLeft + $Text) }
}

function Write-LeftAligned {
    param([string]$Text, [int]$Indent = 2)
    Write-Host (" " * $Indent + $Text)
}

function Write-Boundary {
    param([string]$Color = $FGDarkBlue)
    Write-Host ("  " + "$Color$([string]'_' * 56)$Reset")
}

function Write-Header {
    param([string]$Title)
    Clear-Host
    Write-Host ""
    $WinAutoTitle = "WinAuto"
    Write-Centered "$Bold$FGCyan$WinAutoTitle$Reset"
    Write-Centered "$Bold$FGCyan$($Title.ToUpper())$Reset"
    Write-Boundary
}

function Write-Footer {
    Write-Boundary
    $FooterText = "$Char_Copyright 2026 www.AIIT.support"
    Write-Centered "$FGCyan$FooterText$Reset"
}

function Write-FlexLine {
    param([string]$LeftIcon, [string]$LeftText, [string]$RightText, [bool]$IsActive, [int]$Width = 60, [string]$ActiveColor = "$BGDarkGreen")
    $Circle = "*"
    if ($IsActive) {
        $LeftDisplay = "$FGGray$LeftIcon $FGGray$LeftText$Reset"
        $RightDisplay = "$ActiveColor  $Circle$Reset$FGGray$RightText$Reset  "
        $LeftRaw = "$LeftIcon $LeftText"; $RightRaw = "  $Circle$RightText  " 
    }
    else {
        $LeftDisplay = "$FGDarkGray$LeftIcon $FGDarkGray$LeftText$Reset"
        $RightDisplay = "$BGDarkGray$FGBlack$Circle  $Reset${FGDarkGray}Off$Reset "
        $LeftRaw = "$LeftIcon $LeftText"; $RightRaw = "$Circle  Off "
    }
    $SpaceCount = $Width - ($LeftRaw.Length + $RightRaw.Length + 3) - 1
    if ($SpaceCount -lt 1) { $SpaceCount = 1 }
    Write-Host ("   " + $LeftDisplay + (" " * $SpaceCount) + $RightDisplay)
}

function Write-BodyTitle {
    param([string]$Title)
    Write-LeftAligned "$FGWhite$Bold$Title$Reset"
}

# --- LOGIC ---

function Show-Legend {
    Write-Centered "$FGCyan$Char_Hyphen Script Output LEGEND $Char_Hyphen$Reset"
    Write-Host ""

    # Header/Footer
    Write-LeftAligned "Header/Footer : $FGCyan WinAuto (Cyan)$Reset" 6
    Write-LeftAligned "Boundary      : $FGDarkBlue $([string]'_'*15)$Reset" 6

    # Status Types
    Write-LeftAligned "Success       : $FGGreen$Char_CheckMark Action Completed$Reset" 6
    Write-LeftAligned "Failure       : $FGRed$Char_RedCross Action Failed$Reset" 6
    Write-LeftAligned "Warning       : $FGDarkYellow$Char_Warn Warning Message$Reset" 6
    Write-LeftAligned "Input Request : $FGYellow$Char_Finger Press [Key]$Reset" 6
    
    Write-LeftAligned "Active Item   : $FGGray$Char_HeavyCheck Enabled Feature$Reset" 6
    Write-LeftAligned "Inactive Item : $FGDarkGray[ ] Disabled Feature$Reset" 6
}

function Show-FormattingRules {
    Write-Host ""
    Write-Boundary
    Write-Centered "$FGCyan$Char_Hyphen Script Output DEFAULTS $Char_Hyphen$Reset"
    Write-Host ""
    
    Write-BodyTitle "A. Development Standards"
    Write-LeftAligned "${FGGray}1. Encoding: UTF-8 with BOM.$Reset" 5
    Write-LeftAligned "${FGGray}2. Admin: Include #Requires -RunAsAdministrator.$Reset" 5
    Write-LeftAligned "${FGGray}3. Width: 60 (Center) / 56 (Boundary)$Reset" 5
    Write-LeftAligned "${FGGray}4. Safe Chars: Use only standard encoding chars.$Reset" 5
    
    Write-Host ""
    Write-BodyTitle "B. Text & UI Formatting"
    Write-LeftAligned "${FGGray}1. General: No split words. Left-align (2-space).$Reset" 5
    Write-LeftAligned "${FGGray}2. Headers: Cyan text only.$Reset" 5
    Write-LeftAligned "3. Indent Body text: 2 spaces. Legend: 6 spaces."
    Write-LeftAligned "4. Section Titles: Left-Aligned."
    Write-LeftAligned "5. Status: Active (Green BG), Inactive (D.Gray)."
    
    Write-Host ""
    Write-Centered "${FGCyan}- C. Dashboard & Menu Layout -${Reset}"
    Write-Host ""
    
    Write-LeftAligned "1. Indentation: Menu items indent 2 spaces."
    Write-LeftAligned "2. Numbering: `'1.Name`' (No space after dot)."
    Write-LeftAligned "3. Grid: Use DarkBlue `|` pipes for boundaries."
    Write-LeftAligned "4. Spacing: Pad bottoms; tight headers."

    Write-Host ""
    Write-Centered "${FGCyan}- D. Window Behavior -${Reset}"
    Write-Host ""
    
    Write-LeftAligned "1. Snap: Start @ 60 cols, Snap Top-Right."
    
    Write-Host ""
    Write-BodyTitle "E. Interactive Logic"
    Write-LeftAligned "${FGGray}1. Prompts: Include 10s timeout & safe default.$Reset" 5
}

function Show-VisualExamples {
    param(
        [bool]$ShowFormattingRules = $false
    )

    Write-Header "Script Output RULES"

    # --- PART 1: SCRIPT OUTPUT LEGEND ---
    Show-Legend

    # --- PART 2: SCRIPT OUTPUT DEFAULTS ---
    if ($ShowFormattingRules) {
        Show-FormattingRules
    }
}

Show-VisualExamples -ShowFormattingRules $true
Write-Footer
