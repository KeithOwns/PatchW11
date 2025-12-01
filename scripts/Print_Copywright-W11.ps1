<#
.SYNOPSIS
    Prints a dynamic copyright notice based on the script's last modification year.
.DESCRIPTION
    This script is designed to run independently and dynamically determine the year 
    the file was last saved, using that year in the copyright statement.
#>

# --- Intellectual Property Notice (Output) ---

# 1. Get the full path of the currently executing script using the reliable $PSCommandPath variable.
# $PSCommandPath is generally preferred over $MyInvocation.MyCommand.Path for the script's full path.
$ScriptPath = $PSCommandPath

# 2. Determine the year based on the script's last saved time, or use the current year as a fallback.
if ($ScriptPath) {
    # Script is running from a file, retrieve the year it was last edited.
    $LastEditYear = (Get-Item $ScriptPath).LastWriteTime.Year
} else {
    # Script is being run interactively (e.g., pasted into the console), so file info is unavailable.
    # Fallback to the current year to prevent the error.
    $LastEditYear = (Get-Date).Year
    Write-Host " ❗ Script path not found. Defaulting to current year for copyright." -ForegroundColor Yellow
}

# 3. Define the copyright line using the determined year.
$CopyrightLine = "© $LastEditYear, www.AIIT.support. All Rights Reserved."

# 4. Print the formatted output to the console.
Write-Host "---" -ForegroundColor DarkGray
Write-Host $CopyrightLine -ForegroundColor Cyan
Write-Host "---" -ForegroundColor DarkGray