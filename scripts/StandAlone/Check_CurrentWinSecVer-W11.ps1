# Clear the console before outputting (Per User Instruction)
Clear-Host

# Use the Get-MpComputerStatus cmdlet from the Defender module
# to retrieve the security information.
# We then use Select-Object to specifically pick the definition version property.

$DefenderStatus = Get-MpComputerStatus

# Select the property containing the Security Intelligence (Definition) version
$DefinitionVersion = $DefenderStatus.AntivirusSignatureVersion

# Output the result
Write-Host "Current Microsoft Defender Security Intelligence Version:"
Write-Host $DefinitionVersion

# Print 5 empty lines before the script exits (Per User Instruction)
Write-Output "`n`n`n`n`n"