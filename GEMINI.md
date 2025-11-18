# PatchW11 Scripts

This repository contains a collection of PowerShell scripts designed to check, configure, and maintain various security and system settings on Windows 11.

## Script Categories

### Security Checks

These scripts perform checks to assess the security posture of the system.

- **Check_SecurityAndUpdates-W11.ps1**: Checks for pending security and Windows updates.
- **Check_SecurityComprehensive-W11.ps1**: Performs a comprehensive security check of the system.
- **Check_SecurityOnly-W11.ps1**: Focuses exclusively on security-related checks.
- **Check_SmartAppControl-W11.ps1**: Checks the status of Smart App Control.
- **Check_SmartScreen-W11.ps1**: Verifies if SmartScreen is enabled.
- **Check_SmartScreenApps-W11.ps1**: Checks SmartScreen settings specifically for applications.
- **Check_MSVDB-W11.ps1**: Checks the status of the Microsoft Vulnerable Driver Blocklist.

### Security Configuration

These scripts enable or disable various security features on Windows 11.

- **Disable_PUA-W11.ps1**: Disables Potentially Unwanted App (PUA) protection.
- **Enable_KernelStackProtection-W11.ps1**: Enables Hardware-enforced Stack Protection.
- **Enable_LSA-W11.ps1**: Enables Local Security Authority (LSA) Protection.
- **Enable_MemoryIntegrity-W11.ps1**: Enables Memory Integrity (Hypervisor-Protected Code Integrity - HVCI).
- **Enable_MSstoreSmartScreen-W11.ps1**: Enables SmartScreen for the Microsoft Store.
- **Enable_PhishingProtection-W11.ps1**: Enables phishing protection.
- **Enable_PhishingProtectionMalicious-W11.ps1**: Enables enhanced phishing protection against malicious content.
- **Enable_PUA-W11.ps1**: Enables Potentially Unwanted App (PUA) protection.
- **Enable_RealTimeProtection-W11.ps1**: Enables real-time threat protection.
- **Enable_SmartScreen-W11.ps1**: Enables SmartScreen for the system.
- **Open_PhishProtect-W11.ps1**: Opens the Phishing Protection settings page in Windows Security.
- **Restart_WindowsSecurity-W11.ps1**: Restarts the Windows Security Center service.

### System Maintenance & Updates

Scripts for system maintenance, updates, and configuration.

- **Check_DevDrive-W11.ps1**: Checks for a configured Dev Drive.
- **Check_MSstoreUpdates-W11.ps1**: Checks for updates for Microsoft Store apps.
- **Check_WinUpdates-W11.ps1**: Checks for pending Windows updates.
- **Configure_Updates-W11.ps1**: Configures system update settings.
- **Create_RestorePoint-W11.ps1**: Creates a new system restore point.
- **Enable_StorageSense-W11.ps1**: Enables Storage Sense to automatically manage disk space.
- **Run_Maintenance-W11.ps1**: Executes general system maintenance tasks.
- **Test-SFC.ps1**: Runs the System File Checker (SFC) tool to scan for and repair corrupted system files.
- **Verify-SFC-Code.ps1**: Verifies the exit code from an SFC scan.
- **Demo-SFC-Flow.ps1**: Demonstrates a workflow using the SFC tool.
- **MAINTENANCEruns.bat**: A batch file to execute multiple maintenance scripts.

### Application Management

- **Install_RequiredApps-W11.ps1**: Installs applications listed in `Install_RequiredApps-Config.json`.

### Development & Utility

Internal scripts used for developing and maintaining the script library itself.

- **ConvertTo-UTF8BOM.ps1**: Converts script files to UTF-8 with BOM encoding.
- **Fix-Encoding.ps1**: Fixes file encoding issues.
- **Test-ScriptQuality.ps1**: Runs quality checks on the scripts.
- **Test-Syntax.ps1**: Performs a syntax check on PowerShell scripts.
