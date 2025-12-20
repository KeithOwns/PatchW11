@echo off
:: This script launches the PowerShell script with a temporary policy bypass
:: This resolves the "not digitally signed" error without changing global system settings.

cd /d "%~dp0"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File ".\02_SecurityFeatures_ON-W11.ps1"

:: Keep window open to see results
pause