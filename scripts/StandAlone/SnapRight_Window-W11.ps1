Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
}
"@

$VK_LWIN = 0x5B
$VK_RIGHT = 0x27
$KEYEVENTF_KEYUP = 0x0002

# Press Win+Right
[Win32]::keybd_event($VK_LWIN, 0, 0, [UIntPtr]::Zero)
[Win32]::keybd_event($VK_RIGHT, 0, 0, [UIntPtr]::Zero)

# Release keys
[Win32]::keybd_event($VK_RIGHT, 0, $KEYEVENTF_KEYUP, [UIntPtr]::Zero)
[Win32]::keybd_event($VK_LWIN, 0, $KEYEVENTF_KEYUP, [UIntPtr]::Zero)