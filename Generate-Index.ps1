<#
.SYNOPSIS
    Generates an index.json manifest listing every JSON report
    in the .\json\ folder.

.DESCRIPTION
    The index.html dashboard reads json/index.json to know which
    machine reports exist.  Run this script whenever a new JSON
    is added (or removed) from the folder.

    Tip: call this automatically after Collect-DiskInfo.ps1.

.EXAMPLE
    .\Generate-Index.ps1
#>

[CmdletBinding()]
param (
    [string]$JsonFolder
)

if (-not $JsonFolder) {
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) { $scriptDir = $PWD.Path }
    $JsonFolder = Join-Path $scriptDir "files\json"
}

$files = Get-ChildItem -Path $JsonFolder -Filter "*.json" |
         Where-Object { $_.Name -ne "index.json" } |
         Sort-Object Name |
         ForEach-Object { $_.Name }

$indexPath = Join-Path $JsonFolder "index.json"
@($files) | ConvertTo-Json | Set-Content -Path $indexPath -Encoding UTF8

Write-Host "[✓] index.json updated – $($files.Count) file(s):" -ForegroundColor Green
$files | ForEach-Object { Write-Host "    $_" }
