$ErrorActionPreference = 'Stop'

$waPath = "C:\Users\admin\src\github.com\KeithOwns\PatchW11\wa.ps1"
$atomicDir = "C:\Users\admin\src\github.com\KeithOwns\PatchW11\StandaloneScripts\AtomicScripts"

$waText = Get-Content $waPath -Raw

# 1. Parse wa.ps1
$waAst = [System.Management.Automation.Language.Parser]::ParseFile($waPath, [ref]$null, [ref]$null)
$waFuncs = $waAst.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)

function Normalize-String($str) {
    $lines = $str -split "`n"
    $res = @()
    foreach ($line in $lines) {
        $l = $line.Trim(" `r`t")
        if ($l -ne "" -and -not $l.StartsWith("#") -and -not $l.StartsWith("<#") -and -not $l.StartsWith(".SYNOPSIS") -and -not $l.StartsWith(".DESCRIPTION") -and -not $l.StartsWith(".PARAMETER") -and -not $l.StartsWith("#>")) {
            $res += $l
        }
    }
    return ($res -join "`n")
}

$allMatch = $true

foreach ($func in $waFuncs) {
    if ($func.Name -notmatch '^Invoke-WA_(.+)$') { continue }
    $baseName = $matches[1]

    # Map function name to script name
    # e.g. SetRealTimeProt -> SET_RealTimeProt.ps1
    $possibleNames = @("$baseName.ps1", "SET_$baseName.ps1", "RUN_$baseName.ps1", "UIA_$baseName.ps1", "INSTALL_$baseName.ps1", "CHECK_$baseName.ps1")
    
    # Custom mappings if needed, but the prefix is usually SET_, RUN_, etc.
    if ($baseName -eq "VirusThreatProtect") { $possibleNames += "UIA_VirusThreatON.ps1" }
    if ($baseName -eq "TaskViewOFF") { $possibleNames += "SET_TaskViewOFF.ps1" }
    if ($baseName -eq "TaskbarSearch") { $possibleNames += "SET_TaskbarSearch.ps1" }
    if ($baseName -eq "MemoryInteg") { $possibleNames += "SET_MemoryInteg.ps1" }
    if ($baseName -eq "SystemPreCheck") { continue } # No standalone for this usually
    if ($baseName -eq "InstallApps") { continue }    # No standalone for this
    
    $matchedFile = $null
    foreach ($name in $possibleNames) {
        $p = Join-Path $atomicDir $name
        if (Test-Path $p) {
            $matchedFile = $p
            break
        }
    }
    
    # If not found, search the directory for anything ending in $baseName.ps1
    if (-not $matchedFile) {
        $files = Get-ChildItem -Path $atomicDir -Filter "*$baseName.ps1" -ErrorAction SilentlyContinue
        if ($files) { $matchedFile = $files[0].FullName }
    }
    
    if (-not $matchedFile) {
        Write-Host "Warning: No standalone script found for function: $($func.Name)" -ForegroundColor Yellow
        continue
    }

    # Extract function body
    $funcBody = $func.Body.Extent.Text
    if ($funcBody.StartsWith("{")) { $funcBody = $funcBody.Substring(1) }
    if ($funcBody.EndsWith("}")) { $funcBody = $funcBody.Substring(0, $funcBody.Length - 1) }

    # Parse standalone
    $stAst = [System.Management.Automation.Language.Parser]::ParseFile($matchedFile, [ref]$null, [ref]$null)
    # The body is usually inside `& { ... } @args` or just raw
    $scriptBlocks = $stAst.FindAll({ $args[0] -is [System.Management.Automation.Language.ScriptBlockAst] }, $true)
    
    $stBodyText = ""
    # Find the top-level ScriptBlockAst that is inside a CommandAst (&)
    $innerBlock = $null
    foreach ($sb in $scriptBlocks) {
        if ($sb.Parent -is [System.Management.Automation.Language.CommandAst] -or $sb.Parent -is [System.Management.Automation.Language.PipelineAst]) {
            $innerBlock = $sb
            break
        }
    }
    
    if ($innerBlock) {
        $stBodyText = $innerBlock.Extent.Text
        if ($stBodyText.StartsWith("{")) { $stBodyText = $stBodyText.Substring(1) }
        if ($stBodyText.EndsWith("}")) { $stBodyText = $stBodyText.Substring(0, $stBodyText.Length - 1) }
    } else {
        $stBodyText = $stAst.EndBlock.Extent.Text
    }

    $nFunc = Normalize-String $funcBody
    $nSt = Normalize-String $stBodyText

    if ($nFunc -eq $nSt) {
        Write-Host "MATCH: $($func.Name) <==> $(Split-Path $matchedFile -Leaf)" -ForegroundColor Green
    } else {
        Write-Host "MISMATCH: $($func.Name) <==> $(Split-Path $matchedFile -Leaf)" -ForegroundColor Red
        $allMatch = $false
        
        $lFunc = $nFunc -split "`n"
        $lSt = $nSt -split "`n"
        $min = [Math]::Min($lFunc.Length, $lSt.Length)
        for ($i=0; $i -lt $min; $i++) {
            if ($lFunc[$i] -ne $lSt[$i]) {
                Write-Host "  wa.ps1   : $($lFunc[$i])" -ForegroundColor Gray
                Write-Host "  atom.ps1 : $($lSt[$i])" -ForegroundColor Gray
                break
            }
        }
    }
}

if ($allMatch) {
    Write-Host "All matched." -ForegroundColor Green
} else {
    Write-Host "Some scripts did not match." -ForegroundColor Red
}
