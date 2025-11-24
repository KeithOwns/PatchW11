# CLAUDE.md - AI Assistant Development Guide

This file provides comprehensive guidance for AI assistants (like Claude Code) when working with code in this repository.

---

## Table of Contents
1. [Repository Overview](#repository-overview)
2. [Quick Reference for AI Assistants](#quick-reference-for-ai-assistants)
3. [Directory Structure](#directory-structure)
4. [Common Commands](#common-commands)
5. [Architecture & Code Organization](#architecture--code-organization)
6. [Key Architectural Patterns](#key-architectural-patterns)
7. [Common Development Tasks](#common-development-tasks)
8. [Best Practices for AI Assistants](#best-practices-for-ai-assistants)
9. [Important Technical Notes](#important-technical-notes)
10. [Testing Considerations](#testing-considerations)
11. [File Encoding](#file-encoding)
12. [Documentation References](#documentation-references)
13. [Current Development State](#current-development-state)

---

## Repository Overview

PatchW11 is a Windows 11 security hardening and maintenance automation toolkit for enterprise environments. It provides comprehensive security configuration, monitoring, remediation, and system maintenance through modular PowerShell scripts.

## Quick Reference for AI Assistants

**What This Repo Does:** Windows 11 security automation - 32 PowerShell scripts for hardening, monitoring, and maintenance

**Key Files:**
- `scripts/Check_SecurityComprehensive-W11.ps1` - Main security audit tool (scoring, remediation, export)
- `scripts/01_WindowsUpdate_ON-W11.ps1` - Update configuration
- `scripts/02_SecurityFeatures_ON-W11.ps1` - Batch security enablement
- `scripts/03_Maintenance_RUN-W11.ps1` - System optimization
- `docs/script_LEGEND-W11.ps1` - Visual formatting standards

**Critical Rules:**
1. All scripts require `#Requires -RunAsAdministrator`
2. UTF-8 encoding mandatory (for Unicode icons: ✓ ✗ 🛡️)
3. 50-character max width for console output
4. Check Tamper Protection before modifying Windows Defender
5. Use color conventions: Cyan=✓, DarkRed=✗, Yellow=prompts, Gray=info

**Common Patterns:**
```powershell
Get-RegValue()          # Safe registry reads
Add-SecurityCheck()     # Track security check results
Write-StatusIcon()      # Visual status indicators
```

**Testing:** Always test with Tamper Protection ON and OFF, third-party AV present/absent

## Directory Structure

```
PatchW11/
├── scripts/          # All PowerShell scripts (32 total) and batch files
│   ├── 01_WindowsUpdate_ON-W11.ps1
│   ├── 02_SecurityFeatures_ON-W11.ps1
│   ├── 03_Maintenance_RUN-W11.ps1
│   ├── Check_*.ps1           # Status verification scripts
│   ├── Enable_*.ps1           # Feature enablement scripts
│   ├── Disable_*.ps1          # Feature disablement scripts
│   ├── Create_*.ps1           # System utilities
│   └── Test-ScriptQuality.ps1 # Quality validation tool
├── docs/            # Documentation and reference materials
│   ├── CLAUDE.md              # AI development guidance (this file)
│   ├── README.md              # User documentation
│   ├── ENHANCEMENT_GUIDE.md   # Evolution notes and severity guidelines
│   ├── script_LEGEND-W11.ps1  # Visual formatting reference
│   ├── scriptRULES-W11.ps1    # Coding standards
│   ├── formattingLEGEND-W11.ps1  # Formatting rules
│   └── Install_RequiredApps-agron.ps1  # App installation reference
└── .git/            # Git repository
```

## Common Commands

### Development & Testing

```powershell
# Test individual scripts (must run as Administrator)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
cd scripts

# Run security check (read-only)
.\Check_SecurityOnly-W11.ps1

# Run security check with remediation options
.\Check_SecurityComprehensive-W11.ps1 -ShowRemediation

# Export security report
.\Check_SecurityComprehensive-W11.ps1 -ExportHtml -OutputPath "C:\Reports"
```

### Full System Hardening Workflow

```powershell
# Recommended execution order (numbered scripts for convenience):
.\Create_RestorePoint-W11.ps1                     # 0. Safety first
.\01_WindowsUpdate_ON-W11.ps1                     # 1. Configure Windows Updates
.\02_SecurityFeatures_ON-W11.ps1                  # 2. Enable security features
.\Check_SecurityComprehensive-W11.ps1             # 3. Security audit + remediation
.\03_Maintenance_RUN-W11.ps1                      # 4. Final optimization
```

## Architecture & Code Organization

### Script Categories

**Orchestration Scripts (Main Workflow):**
- `01_WindowsUpdate_ON-W11.ps1` - Windows Update configuration and automation
- `02_SecurityFeatures_ON-W11.ps1` - Batch enable multiple security features
- `03_Maintenance_RUN-W11.ps1` - System optimization, cleanup, and diagnostics
- `Check_SecurityComprehensive-W11.ps1` - Security assessment with scoring and interactive remediation

**Check Scripts (Check_*.ps1):**
- Read-only status verification for specific features
- Examples:
  - `Check_SecurityComprehensive-W11.ps1` - Full security audit with scoring and remediation
  - `Check_SecurityOnly-W11.ps1` - Read-only security audit (no remediation)
  - `Check_DevDrive-W11.ps1` - Dev Drive protection status
  - `Check_SmartAppControl-W11.ps1` - Smart App Control verification
  - `Check_SmartScreen-W11.ps1` - SmartScreen status
  - `Check_SmartScreenApps-W11.ps1` - SmartScreen for apps verification
  - `Check_WinUpdates-W11.ps1` - Windows Update automation
  - `Check_MSstoreUpdates-W11.ps1` - Microsoft Store update automation
  - `Check_MSVDB-W11.ps1` - Microsoft Vulnerable Driver Blocklist status

**Enable Scripts (Enable_*.ps1):**
- Apply specific security settings with Tamper Protection awareness
- Examples:
  - `Enable_RealTimeProtection-W11.ps1` - Enable real-time virus protection
  - `Enable_LSA-W11.ps1` - Enable LSA protection (requires reboot)
  - `Enable_MemoryIntegrity-W11.ps1` - Enable Core Isolation/HVCI
  - `Enable_PUA-W11.ps1` - Enable potentially unwanted app blocking
  - `Enable_PhishingProtection-W11.ps1` - Enable phishing protection
  - `Enable_PhishingProtectionMalicious-W11.ps1` - Enhanced phishing protection
  - `Enable_MSstoreSmartScreen-W11.ps1` - Enable Microsoft Store SmartScreen
  - `Enable_SmartScreen-W11.ps1` - Enable SmartScreen
  - `Enable_KernelStackProtection-W11.ps1` - Enable kernel stack protection
  - `Enable_StorageSense-W11.ps1` - Configure storage sense

**Disable Scripts (Disable_*.ps1):**
- Remove specific security settings (use cautiously)
- Examples:
  - `Disable_PUA-W11.ps1` - Disable potentially unwanted app blocking

**Other Utility Scripts:**
- `Create_RestorePoint-W11.ps1` - System restore point creator
- `DynamicLock_ON-W11.ps1` - Enable dynamic lock feature
- `Firewall_ON-W11.ps1` - Enable Windows Firewall
- `PUAapps_ON-W11.ps1` - Enable PUA protection
- `Open_PhishProtect-W11.ps1` - Open phishing protection settings
- `Restart_WindowsSecurity-W11.ps1` - Restart Windows Security service
- `Test-ScriptQuality.ps1` - Script quality validation tool
- `MAINTENANCEruns.bat` - Legacy maintenance batch script

### Shared Utility Framework

All scripts follow consistent patterns:

**Visual Feedback Functions:**
```powershell
Write-StatusIcon()      # Visual status indicators (✓/✗) with color-coded severity
Write-SectionHeader()   # Formatted section headers with icons
```

**Registry Operations:**
```powershell
Get-RegValue()          # Safe read with null handling and default value support
Set-RegistryDword()     # Safe write with path creation
Add-SecurityCheck()     # Add check results to global tracking array
```

**Error Handling Pattern:**
```powershell
#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
```

### Visual Formatting Standards

All scripts follow the visual formatting guidelines documented in `docs/script_LEGEND-W11.ps1`:

**Color Conventions:**
- **DarkBlue** (─) - Section boundary lines (50 characters wide)
- **Cyan** (✓) - Enabled features / Success states
- **DarkRed** (✗) - Disabled features / Failures
- **Red** (🚫) - Errors
- **Yellow** (!) - User prompts
- **DarkYellow** (⚠) - Warnings
- **White** - Icons and section titles
- **Gray** - Informational text and details
- **DarkGray** (-) - Unavailable features
- **Green** (✅) - Completion / Success
- **DarkGreen** - Script titles

**Formatting Rules:**
- Maximum line width: 50 characters (for console readability)
- Never split words between lines
- Use abbreviations or ellipses (...) for conciseness
- Boundary lines are exactly 50 characters: `Write-Host ("─" * 50) -ForegroundColor DarkBlue`
- All files must be UTF-8 encoded for proper Unicode display

## Key Architectural Patterns

### 1. Dependency Awareness

Scripts understand feature dependencies and check them before applying changes:

- **Real-time Protection** is required for:
  - Controlled Folder Access
  - Dev Drive Protection
  - Network Protection
- **Tamper Protection** blocks programmatic security changes (user must disable manually)
- **Third-party AV detection** skips Windows Defender checks when non-Microsoft AV is active

### 2. SecurityCheck Class and Tracking

The main security script uses a custom class to track check results:

```powershell
class SecurityCheck {
    [string]$Category      # E.g., "Virus & Threat Protection"
    [string]$Name          # Feature name
    [bool]$IsEnabled       # Current state
    [string]$Severity      # Critical, Warning, Info
    [string]$Remediation   # PowerShell command to fix
    [string]$Details       # Additional context
}
```

**Adding checks:**
```powershell
Add-SecurityCheck -Category "Device Security" `
                  -Name "Memory Integrity" `
                  -IsEnabled $true `
                  -Severity "Warning" `
                  -Remediation "Enable_MemoryIntegrity-W11.ps1" `
                  -Details "Core Isolation enabled"
```

### 3. The Apply Settings Module (Check_SecurityComprehensive-W11.ps1)

The main security script has an integrated "Apply Settings" module with individual setters:
- Each setter is a self-contained function targeting one security feature
- Setters check dependencies before applying changes
- Recent additions: Real-time Protection, Tamper Protection, Controlled Folder Access, SmartScreen

**When adding new setters:**
1. Add the function to the Apply Settings section (~line 800+)
2. Include dependency checks (e.g., verify Real-time Protection is enabled)
3. Add error handling for Tamper Protection scenarios
4. Update the Apply Settings menu in `Show-ApplySettingsMenu()`

### 4. UI Automation Pattern

Multiple scripts automate Windows Settings/Store UI interactions:

```powershell
# Load UI Automation assemblies
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

# Find and click buttons programmatically
$button = $element.FindFirst($TreeScope, $condition)
$button.GetCurrentPattern($InvokePattern).Invoke()
```

Used in: `01_WindowsUpdate_ON-W11.ps1`, `Check_MSstoreUpdates-W11.ps1`, `Check_WinUpdates-W11.ps1`

### 5. Naming Convention

All scripts follow the pattern `[Verb]_[SettingName]-W11.ps1`:

- **Verbs**: Check, Enable, Disable, Configure, Run, Create, Open, Restart
- **Examples**: `Check_DevDrive-W11.ps1`, `Enable_RealTimeProtection-W11.ps1`, `Disable_PUA-W11.ps1`
- **Exception**: Test-ScriptQuality.ps1 (uses PowerShell Verb-Noun convention)
- **Numbered Scripts**: Main workflow scripts use numbered prefixes: `01_`, `02_`, `03_`

### 6. Application Installation Pattern (Removed)

The application installer (`04-Install_Apps-agron.ps1`) has been removed from the repository.

Previous installation methods included:

```powershell
# 1. WINGET (preferred) - with scope fallback and retry
Install-WithWingetRetry -Id "App.ID" -Scope "user" -FallbackScope "machine"

# 2. MSI - Download and silent install
Get-File -Url $url -OutFile $msiPath
msiexec.exe /i "$msiPath" /qn /norestart $silentArgs

# 3. EXE - Download and silent install
Get-File -Url $url -OutFile $exePath
Start-Process -FilePath $exePath -ArgumentList $silentArgs -Wait
```

**Installation workflow:**
1. Validate app configurations
2. Check prerequisites (interactive loop)
3. Disable Controlled Folder Access
4. Install missing apps (sorted by InstallOrder)
5. Verify installation with `Wait-UntilDetected()` (timeout-based retry loop)
6. Re-enable Controlled Folder Access
7. Generate summary logs

### 7. Security Scoring System

Security checks use weighted severity levels:

- **Critical** (3x weight): Firewall, Real-time Protection, Tamper Protection
- **Warning** (2x weight): Most security features, updates, policies
- **Info** (1x weight): Optional features, informational items

Score calculation: `(PassedWeight / TotalWeight) * 100`

Rating: EXCELLENT (90+) | GOOD (80+) | FAIR (60+) | POOR (<60)

## Common Development Tasks

### Adding a New Security Check to Check_SecurityComprehensive-W11.ps1

1. Add check function in appropriate section (Virus Protection, Firewall, etc.)
2. Use the `SecurityCheck` class to store results:
   ```powershell
   $check = [SecurityCheck]@{
       Category = "Virus & Threat Protection"
       Name = "Feature Name"
       IsEnabled = $true/$false
       Severity = "Critical"  # or Warning, Info
       Remediation = "Set-MpPreference -FeatureName 1"
       Details = "Additional context"
   }
   $script:SecurityChecks += $check
   ```

3. Add display logic in `Show-SecurityStatus()`

### Adding a New Enable Script

1. Copy template from existing Enable_*.ps1 script
2. Include Tamper Protection detection:
   ```powershell
   $tamperProtection = Get-RegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection"
   if ($tamperProtection -eq 5) {
       Write-Warning "Tamper Protection is ON - user must disable manually in Windows Security"
       exit 1
   }
   ```

3. Add status verification after applying changes
4. Use consistent visual feedback (Write-StatusIcon)

### Adding Script Quality Tests

The `Test-ScriptQuality.ps1` script validates:

- `#Requires -RunAsAdministrator` in all scripts
- UTF-8 encoding preservation
- PowerShell syntax errors
- Best practices (informational)

Run with:
```powershell
cd scripts
.\Test-ScriptQuality.ps1
```

## Best Practices for AI Assistants

When working with this codebase as an AI assistant:

### 1. Always Read Before Editing
- Never propose changes without reading the target file first
- Check related files for context and patterns
- Verify naming conventions match existing code

### 2. Maintain Consistency
- Follow the established color conventions (see Visual Formatting Standards)
- Use the same function patterns (Get-RegValue, Add-SecurityCheck, etc.)
- Preserve UTF-8 encoding (critical for Unicode icons)
- Keep the 50-character line width for user-facing output

### 3. Security Awareness
- Always include `#Requires -RunAsAdministrator`
- Check for Tamper Protection before modifying Windows Defender settings
- Detect third-party antivirus software when relevant
- Test dependency chains (e.g., Real-time Protection → Controlled Folder Access)

### 4. Testing Considerations
- Suggest testing on both clean VMs and production systems
- Remind users to create restore points before major changes
- Consider Tamper Protection ON/OFF scenarios
- Test with both Windows Terminal (modern) and legacy console

### 5. Documentation Updates
- Update CLAUDE.md when adding new patterns or conventions
- Document new security checks in the script synopsis
- Add examples for new functionality
- Keep script counts and lists current

### 6. Code Quality
- Run Test-ScriptQuality.ps1 after making changes
- Verify error handling is present
- Use try/catch blocks for risky operations
- Provide clear user feedback for errors

### 7. Git Workflow
- Follow the specified branch naming convention (claude/...)
- Write descriptive commit messages
- Push to the correct feature branch
- Never force push to main/master

## Important Technical Notes

### Registry Paths (Frequently Accessed)

```powershell
# Windows Defender
HKLM:\SOFTWARE\Microsoft\Windows Defender\Features
HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender

# Windows Update
HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings

# SmartScreen
HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer
HKLM:\SOFTWARE\Policies\Microsoft\Windows\System

# Core Isolation
HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity
```

### Windows Defender Cmdlets

```powershell
Get-MpPreference          # Read current settings
Set-MpPreference          # Modify settings (blocked by Tamper Protection)
Get-MpComputerStatus      # Scan info, signature versions
```

### System Diagnostics Cascade (Run_Maintenance-W11.ps1)

Automated repair workflow:

```
IF Test-SystemFiles (SFC) fails:
  → Repair-WindowsImage (DISM /Online /Cleanup-Image /RestoreHealth)
    IF DISM fails:
      → Start-MemoryDiagnostics (scheduled for next boot)
```

### UI Automation Limitations

- Only works for UWP/Modern UI elements (Settings, Store)
- Requires specific AutomationID or ControlType matching
- Fragile - breaks if UI layout changes
- Add `Start-Sleep` delays to allow UI rendering

## Testing Considerations

### Before Committing

1. Test on clean Windows 11 VM (both Pro and Enterprise)
2. Test with Tamper Protection ON and OFF
3. Test with third-party AV installed (Symantec, McAfee)
4. Verify visual output in Windows Terminal and legacy console
5. Check UTF-8 encoding for icon characters (✓ ✗ 🛡️)

### Common Issues

**"Access Denied" errors:**
- Check `#Requires -RunAsAdministrator`
- Verify Tamper Protection status
- Check if third-party AV is blocking

**UI Automation failures:**
- Add longer `Start-Sleep` delays
- Verify AutomationID hasn't changed in Windows updates
- Test on both light/dark themes

**WINGET failures:**
- Ensure version 1.5.0+
- Try scope fallback (user → machine)
- Refresh sources: `winget source update`

### Script-Specific Issues

**Check_SecurityComprehensive-W11.ps1:**
- If scoring seems off, check severity weights (Critical=3x, Warning=2x, Info=1x)
- Export failures: Verify OutputPath exists and is writable
- Baseline comparison: Ensure baseline JSON format matches current schema

**Enable_*.ps1 scripts:**
- Always check Tamper Protection status first
- Exit code 1 means Tamper Protection is blocking (user intervention required)
- Some features require reboot (LSA, Memory Integrity)

**UI Automation scripts:**
- May fail if Windows is slow to respond (increase Start-Sleep values)
- Check if AutomationID changed after Windows updates
- Only works for UWP/Modern UI (Settings, Store), not Win32 dialogs

### Performance Optimization

- Use `Get-RegValue` instead of repeated `Get-ItemProperty` calls
- Cache expensive operations (Get-MpPreference, Get-NetFirewallProfile)
- Minimize cmdlet pipeline overhead in loops
- Use `-ErrorAction SilentlyContinue` for expected failures

## File Encoding

**Critical:** All `.ps1` files must be UTF-8 encoded for proper display of Unicode characters (✓ ✗ 🛡️ 👤 🔒).

```powershell
# Save files with UTF-8 encoding:
$content | Out-File -FilePath $path -Encoding UTF8
```

## Documentation References

### Primary Documentation
- **docs/CLAUDE.md** (this file) - AI assistant development guide with architecture, patterns, and conventions
- **docs/README.md** - User-facing documentation and quick start guide
- **docs/ENHANCEMENT_GUIDE.md** - Evolution from v1 to v2 security checking, severity guidelines

### Reference Files (in docs/)
- **script_LEGEND-W11.ps1** - Visual formatting standards and color conventions (executable reference)
- **scriptRULES-W11.ps1** - Coding standards and best practices
- **formattingLEGEND-W11.ps1** - Detailed formatting rules and examples
- **Install_RequiredApps-agron.ps1** - Application installation reference (historical)

### How to Use Reference Files
```powershell
# View the visual formatting legend
cd docs
.\script_LEGEND-W11.ps1

# Review coding standards
Get-Content .\scriptRULES-W11.ps1

# Check formatting rules
.\formattingLEGEND-W11.ps1
```

## Current Development State

**Last Major Update:** 2025-11-24
**Script Count:** 32 PowerShell scripts + 1 batch file
**Recent Changes:**
- Renamed maintenance scripts to numbered format (01_, 02_, 03_)
- Enhanced Check_SecurityComprehensive-W11.ps1 with scoring and remediation
- Added comprehensive Enable/Disable script collection
- Improved Tamper Protection detection across all scripts
- Standardized visual formatting and color conventions

**Active Development Areas:**
- Security assessment and remediation workflows
- UI automation for Windows Settings and Microsoft Store
- Third-party antivirus detection and compatibility
- Export capabilities (HTML, JSON, baseline comparison)

## Future Development Directions

When extending this toolkit, consider these areas:

### Potential Enhancements
1. **Remote Management**
   - PowerShell remoting support for multiple machines
   - Centralized reporting dashboard
   - Group Policy integration

2. **Advanced Reporting**
   - Historical trend analysis
   - Compliance frameworks (CIS, NIST, DISA-STIG)
   - Email notifications for critical findings

3. **Automated Remediation**
   - Scheduled task integration
   - Automatic fix rollback on failures
   - Remediation impact assessment

4. **Extended Security Features**
   - Windows Sandbox configuration
   - Application Guard settings
   - BitLocker management
   - Certificate store validation

5. **Integration**
   - SIEM integration (Splunk, Sentinel)
   - Ticketing system webhooks
   - Configuration as Code (desired state)

### Backward Compatibility
- Maintain Windows 10 support where possible
- Test on both Professional and Enterprise editions
- Consider LTSC (Long-Term Servicing Channel) compatibility

### Maintenance Notes
- Review security checks quarterly for new Windows features
- Update UI automation when Windows UI changes
- Keep third-party AV detection list current
- Monitor for PowerShell cmdlet deprecations

---

**Document Version:** 2.0
**Last Updated:** 2025-11-24
**Maintainer:** AI+IT Support Team
**Repository:** PatchW11 - Windows 11 Security Hardening Toolkit
