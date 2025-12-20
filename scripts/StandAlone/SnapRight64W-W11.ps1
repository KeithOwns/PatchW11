#Requires -Version 5.1
<#
.SYNOPSIS
    Resizes console to 64 columns and snaps to right edge of screen.
.DESCRIPTION
    Adjusts the current PowerShell console window width to 64 characters
    and positions it on the right side of the primary monitor work area.
#>

# --- STYLE CONFIGURATION ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Char_HeavyLine = [char]0x2501
$FGCyan   = "$([char]0x1B)[96m"
$FGGreen  = "$([char]0x1B)[92m"
$Reset    = "$([char]0x1B)[0m"
$Bold     = "$([char]0x1B)[1m"

# --- NATIVE METHODS ---
$code = @"
using System;
using System.Runtime.InteropServices;

namespace PatchW11 {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    public class WinUtils {
        [DllImport("kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

        [DllImport("user32.dll")]
        public static extern int GetSystemMetrics(int nIndex);

        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        public const int SM_CXWORKAREA = 16;
        public const int SM_CYWORKAREA = 17;
    }
}
"@

try {
    Add-Type -TypeDefinition $code -ErrorAction Stop
} catch {
    # Type might already be added in session
}

# --- MAIN EXECUTION ---
try {
    Write-Host ""
    Write-Host " $FGCyan$Char_HeavyLine PatchW11 SnapRight (64W) $Char_HeavyLine$Reset"
    
    # 1. Set Buffer/Window Width to 64 chars
    $targetWidth = 64
    # Maximize height to mostly fill screen (optional, but good for "Snap")
    # For now, let's keep current height or set a reasonable default if small.
    $targetHeight = 50 
    
    # Get current to preserve height if larger
    $currentHeight = $Host.UI.RawUI.WindowSize.Height
    if ($currentHeight -gt $targetHeight) { $targetHeight = $currentHeight }

    # Apply Size - Safer Order for Shrinking
    # 1. Set Window to Target Width (Height kept same or increased later)
    # We must ensure Window is not larger than CURRENT buffer, which is usually true.
    $window = $Host.UI.RawUI.WindowSize
    $window.Width = $targetWidth
    $window.Height = $targetHeight
    
    # Check if we need to expand buffer for height first
    $buffer = $Host.UI.RawUI.BufferSize
    if ($buffer.Height -lt $targetHeight) {
        $buffer.Height = $targetHeight
        $Host.UI.RawUI.BufferSize = $buffer
    }
    
    # Now Set Window Size
    $Host.UI.RawUI.WindowSize = $window
    
    # Now Set Buffer Width (Shrink Buffer to match Window)
    $buffer = $Host.UI.RawUI.BufferSize
    $buffer.Width = $targetWidth
    $Host.UI.RawUI.BufferSize = $buffer

    # 2. Get Window Handle
    $hWnd = [PatchW11.WinUtils]::GetConsoleWindow()
    
    # 3. Get Screen Work Area Dimensions
    $screenW = [PatchW11.WinUtils]::GetSystemMetrics(16) # SM_CXWORKAREA
    $screenH = [PatchW11.WinUtils]::GetSystemMetrics(17) # SM_CYWORKAREA
    
    # 4. Get Current Window Rect (to calculate pixel width)
    $rect = New-Object PatchW11.RECT
    $null = [PatchW11.WinUtils]::GetWindowRect($hWnd, [ref]$rect)
    
    $winPixelW = $rect.Right - $rect.Left
    $winPixelH = $rect.Bottom - $rect.Top
    
    # 5. Calculate New Position (Right Aligned)
    $newX = $screenW - $winPixelW
    # Optional: Snap to top
    $newY = 0
    # Optional: Stretch height to fill screen? 
    # Let's stretch height to fill screen for a true "Snap" feel
    $newH = $screenH
    
    # Execute Move
    # Note: We use the calculated pixel width, but override height to screen height
    $null = [PatchW11.WinUtils]::MoveWindow($hWnd, $newX, $newY, $winPixelW, $newH, $true)
    
    Write-Host " $FGGreen  Window snapped to Right (Width: 64)$Reset"
    
} catch {
    Write-Error "Failed to snap window: $($_.Exception.Message)"
}
