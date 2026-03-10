#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Click the "Turn on" button under "App & browser control" via UI Automation.
.DESCRIPTION
    Launches Windows Security to the App & browser control page, locates the "Turn on" button, and attempts to invoke it.
    Useful as an atomic script to enforce security settings when registry access is locked or hidden.
#>

param(
    [switch]$Undo # Unused for this specific "Turn on" action, but kept for signature consistency if needed
)

# --- UIA PREPARATION ---
if (-not ([System.Management.Automation.PSTypeName]"System.Windows.Automation.AutomationElement").Type) {
    try {
        Add-Type -AssemblyName UIAutomationClient
        Add-Type -AssemblyName UIAutomationTypes
    }
    catch {
        Write-Host "[!] Failed to load UIAutomation assemblies." -ForegroundColor Red
        exit
    }
}

# Local UIA Helper
function Get-UIAElement {
    param(
        [System.Windows.Automation.AutomationElement]$Parent,
        [string]$Name,
        [string]$AutomationId,
        [string]$ControlType
    )
    
    $conditions = @()
    if ($Name) { $conditions += New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty, $Name) }
    if ($AutomationId) { $conditions += New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::AutomationIdProperty, $AutomationId) }
    if ($ControlType) { 
        # Convert string to ControlType object (e.g. "Button" -> [System.Windows.Automation.ControlType]::Button)
        $ct = [System.Windows.Automation.ControlType]::$ControlType
        $conditions += New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, $ct)
    }

    if ($conditions.Count -eq 0) { return $null }

    if ($conditions.Count -eq 1) {
        $finalCondition = $conditions[0]
    } else {
        $finalCondition = New-Object System.Windows.Automation.AndCondition($conditions)
    }

    return $Parent.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $finalCondition)
}

function Invoke-WA_TurnOnAppBrowserControl {
    
    Write-Host "[*] Launching Windows Security (App & browser control)..." -ForegroundColor Cyan
    try {
        Start-Process "windowsdefender://appbrowser"
    }
    catch {
        Write-Host "[X] Failed to launch Windows Security: $($_.Exception.Message)" -ForegroundColor Red
        return
    }
    
    Start-Sleep -Seconds 3

    $Desktop = [System.Windows.Automation.AutomationElement]::RootElement
    $Window = $null
    
    # Locate Windows Security Window
    Write-Host "[*] Searching for Windows Security window..." -ForegroundColor Gray
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($sw.Elapsed.TotalSeconds -lt 15) {
        $Window = Get-UIAElement -Parent $Desktop -Name "Windows Security" -ControlType "Window"
        if ($Window) { break }
        Start-Sleep -Seconds 1
    }

    if ($Window) {
        try { $Window.SetFocus() } catch {}
        Start-Sleep -Seconds 1
        
        Write-Host "[*] Searching for 'Turn on' button..." -ForegroundColor Gray
        
        # Typically, the button is named "Turn on" or has a specific AutomationId depending on OS version
        $TurnOnBtn = Get-UIAElement -Parent $Window -Name "Turn on" -ControlType "Button"
        
        if ($TurnOnBtn) {
            try {
                $InvokePattern = $TurnOnBtn.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
                $InvokePattern.Invoke()
                Write-Host "[V] Successfully clicked 'Turn on' button." -ForegroundColor Green
            }
            catch {
                Write-Host "[X] Found button but failed to click it: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        else {
            Write-Host "[!] Could not find 'Turn on' button. It might already be turned on, or the UI layout differs." -ForegroundColor Yellow
        }
        
    }
    else {
        Write-Host "[X] Could not find Windows Security window." -ForegroundColor Red
    }
    
    # Cleanup / Let user observe before closing (optional)
    Start-Sleep -Seconds 2
    # Stop-Process -Name "SecHealthUI" -Force -ErrorAction SilentlyContinue # Optional auto-close
}

Invoke-WA_TurnOnAppBrowserControl
