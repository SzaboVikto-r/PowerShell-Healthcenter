<#
.SYNOPSIS
    Collects local disk information and exports it as a JSON file.

.DESCRIPTION
    Gathers the computer name, current date/time, and details for every
    local (fixed) drive: letter, type, label, file system, total / used /
    free space, and usage percentage.  The result is saved into the
    configured JSON folder and index.json is automatically refreshed.

.PARAMETER OutputFolder
    Folder where the JSON file will be written.
    Default: .\files\json  (relative to wherever the script lives)

.EXAMPLE
    .\Collect-DiskInfo.ps1
    .\Collect-DiskInfo.ps1 -OutputFolder "\\fileserver\reports\json"
#>

[CmdletBinding()]
param (
    [string]$OutputFolder
)

# ── Resolve output folder (fallback if $PSScriptRoot is empty) ──────
if (-not $OutputFolder) {
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) { $scriptDir = $PWD.Path }
    $OutputFolder = Join-Path $scriptDir "files\json"
}

# ── Ensure output folder exists ──────────────────────────────────────
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
    Write-Host "[+] Created output folder: $OutputFolder" -ForegroundColor Cyan
}

# ── Collect drive data ───────────────────────────────────────────────
$drives = Get-CimInstance -ClassName Win32_LogicalDisk |
    Where-Object { $_.DriveType -eq 3 } |          # 3 = Local Disk
    ForEach-Object {
        $total = $_.Size
        $free  = $_.FreeSpace
        $used  = $total - $free

        [PSCustomObject]@{
            letter          = $_.DeviceID
            type            = "Local Disk"
            label           = $(if ($_.VolumeName) { $_.VolumeName } else { "" })
            fileSystem      = $_.FileSystem
            totalBytes      = $total
            usedBytes       = $used
            freeBytes       = $free
            usedPercent     = $(if ($total -gt 0) {
                                  [math]::Round(($used / $total) * 100, 1)
                              } else { 0 })
        }
    }

# ── Build the final object ───────────────────────────────────────────
$report = [PSCustomObject]@{
    computerName = $env:COMPUTERNAME
    collectedAt  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    drives       = @($drives)
}

# ── Write JSON ───────────────────────────────────────────────────────
$fileName = "$($env:COMPUTERNAME).json"
$filePath = Join-Path $OutputFolder $fileName

$report | ConvertTo-Json -Depth 4 | Set-Content -Path $filePath -Encoding UTF8

Write-Host "[✓] Report saved: $filePath" -ForegroundColor Green
Write-Host "    Computer : $($report.computerName)"
Write-Host "    Drives   : $($drives.Count)"
Write-Host "    Time     : $($report.collectedAt)"

# ── Auto-refresh index.json ─────────────────────────────────────────
$allFiles = Get-ChildItem -Path $OutputFolder -Filter "*.json" |
            Where-Object { $_.Name -ne "index.json" } |
            Sort-Object Name |
            ForEach-Object { $_.Name }

$indexPath = Join-Path $OutputFolder "index.json"
@($allFiles) | ConvertTo-Json | Set-Content -Path $indexPath -Encoding UTF8

Write-Host "[✓] index.json updated – $($allFiles.Count) file(s)" -ForegroundColor Cyan
