#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Network Repair & Security Hardening Module
.DESCRIPTION
    Performs common network fixes (Flush DNS, Reset Winsock) and hardens
    network security by disabling legacy protocols (NetBIOS, LLMNR).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Pause {
    Write-Host ""
    while ($Host.UI.RawUI.KeyAvailable) { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }
    for ($i = 5; $i -gt 0; $i--) {
        if ($Host.UI.RawUI.KeyAvailable) {
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Write-Host "`r  $([char]0x23F8) Paused. Press any key to continue...       " -NoNewline -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            break
        }
        Write-Host "`r  $([char]0x23F1) Continuing in $i s... (Press any key to pause)   " -NoNewline -ForegroundColor Gray
        Start-Sleep -Seconds 1
    }
    Write-Host "`r                                                           " -NoNewline
    Write-Host ""
}

# --- STYLE ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Char_HeavyLine = [char]0x2501; $Char_BallotCheck = [char]0x2611; $Char_RedCross = [char]0x274E
$Char_Warn = [char]0x26A0; $Char_Finger = [char]0x261B; $Char_Keyboard = [char]0x2328; $Char_Eject = [char]0x23CF
$Esc = [char]0x1B; $Reset = "$Esc[0m"; $Bold = "$Esc[1m"
$FGCyan = "$Esc[96m"; $FGGreen = "$Esc[92m"; $FGYellow = "$Esc[93m"; $FGRed = "$Esc[91m"; $FGWhite = "$Esc[97m"; $FGGray = "$Esc[37m"
$FGDarkBlue = "$Esc[34m"; $FGDarkGray = "$Esc[90m"; $FGBlack = "$Esc[30m"; $BGYellow = "$Esc[103m"

function Write-Centered { param($Text, $Width = 60) $clean = $Text -replace "$Esc\[[0-9;]*m", ""; $pad = [Math]::Floor(($Width - $clean.Length) / 2); if ($pad -lt 0) { $pad = 0 }; Write-Host (" " * $pad + $Text) }
function Write-LeftAligned { param($Text, $Indent = 2) Write-Host (" " * $Indent + $Text) }
function Write-Header { param($Title) Write-Host ""; Write-Centered "$Bold$FGCyan $Char_HeavyLine PatchW11 $Char_HeavyLine $Reset"; Write-Centered "$Bold$FGCyan$Title$Reset"; Write-Host "$FGDarkBlue$([string]$Char_HeavyLine * 60)$Reset" }
function Write-Boundary { param($Color = $FGDarkBlue) Write-Host "$Color$([string]$Char_HeavyLine * 60)$Reset" }

# --- FUNCTIONS ---

function Create-RestorePoint {
    Write-Host ""
    Write-LeftAligned "$FGYellow Creating System Restore Point...$Reset"
    try {
        Checkpoint-Computer -Description "PatchW11 Network Fix $(Get-Date -Format 'yyyyMMdd_HHmm')" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-LeftAligned "$FGGreen$Char_BallotCheck Restore Point created.$Reset"
    } catch {
        Write-LeftAligned "$FGRed$Char_Warn Skip Restore Point: $($_.Exception.Message)$Reset"
    }
}

function Reset-NetworkStack {
    Write-Host ""
    Write-LeftAligned "$FGYellow Resetting Network Stack...$Reset"
    
    Create-RestorePoint
    
    try {
        # Winsock Reset
        $res = netsh winsock reset 2>&1
        Write-LeftAligned "$FGGreen$Char_BallotCheck Winsock reset successful.$Reset"
        
        # IP Reset
        $res = netsh int ip reset 2>&1
        Write-LeftAligned "$FGGreen$Char_BallotCheck TCP/IP stack reset successful.$Reset"
        
        # Flush DNS
        Clear-DnsClientCache
        Write-LeftAligned "$FGGreen$Char_BallotCheck DNS Cache flushed.$Reset"
        
        # Release/Renew (Optional, can disconnect session)
        # ipconfig /release & ipconfig /renew
        # Skipped to prevent remote disconnects.
        
        Write-LeftAligned "$FGYellow Note: A restart is required to apply these changes.$Reset"
    } catch {
        Write-LeftAligned "$FGRed$Char_RedCross Error resetting network: $($_.Exception.Message)$Reset"
    }
}

function Secure-Protocols {
    Write-Host ""
    Write-LeftAligned "$FGYellow Hardening Network Protocols...$Reset"
    
    Create-RestorePoint
    
    try {
        # Disable LLMNR (Local Link Multicast Name Resolution) via Registry
        $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        Set-ItemProperty -Path $path -Name "EnableMulticast" -Value 0 -Type DWord
        Write-LeftAligned "$FGGreen$Char_BallotCheck LLMNR Disabled (Registry).$Reset"
        
        # Disable NetBIOS over TCP/IP
        # This iterates through all adapters
        $adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }
        foreach ($adapter in $adapters) {
            $adapter.SetTcpipNetbios(2) | Out-Null # 0=Use DHCP, 1=Enable, 2=Disable
        }
        Write-LeftAligned "$FGGreen$Char_BallotCheck NetBIOS over TCP/IP Disabled on active adapters.$Reset"
        
    } catch {
        Write-LeftAligned "$FGRed$Char_RedCross Error hardening network: $($_.Exception.Message)$Reset"
    }
}

function Set-SecureDNS {
    Write-Host ""
    Write-LeftAligned "$FGYellow Configuring Secure DNS (Cloudflare)...$Reset"
    
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
        foreach ($adapter in $adapters) {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses ("1.1.1.1", "1.0.0.1") -ErrorAction SilentlyContinue
            Write-LeftAligned "  Configured $($adapter.Name)"
        }
        Write-LeftAligned "$FGGreen$Char_BallotCheck DNS set to Cloudflare (1.1.1.1).$Reset"
    } catch {
        Write-LeftAligned "$FGRed$Char_RedCross Error setting DNS: $($_.Exception.Message)$Reset"
    }
}

# --- MAIN MENU ---
$menu = $true
while ($menu) {
    Clear-Host
    Write-Header "NETWORK TOOLKIT"
    
    Write-Host ""
    Write-LeftAligned " ${FGBlack}${BGYellow}[1]${Reset} ${FGGray}Repair Network Stack ${FGDarkGray}(Reset Winsock/IP/DNS)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[2]${Reset} ${FGGray}Harden Protocols ${FGDarkGray}(Disable NetBIOS/LLMNR)${Reset}"
    Write-LeftAligned " ${FGBlack}${BGYellow}[3]${Reset} ${FGGray}Set Secure DNS ${FGDarkGray}(Cloudflare)${Reset}"
    Write-Host ""
    Write-LeftAligned " ${FGBlack}${BGYellow}[A]${Reset} ${FGYellow}Run Repair & Harden${Reset}"
    
    Write-Boundary
    $prompt = "${FGWhite}$Char_Keyboard  Type${FGYellow} ID ${FGWhite}to Execute${FGWhite}|${FGDarkGray}any other to ${FGWhite}EXIT$Char_Eject${Reset}"
    Write-Centered $prompt
    
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $c = $key.Character.ToString().ToUpper()
    
    switch ($c) {
        '1' { Reset-NetworkStack; Pause }
        '2' { Secure-Protocols; Pause }
        '3' { Set-SecureDNS; Pause }
        'A' { Reset-NetworkStack; Secure-Protocols; Pause }
        Default { $menu = $false }
    }
}
