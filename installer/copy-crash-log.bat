@echo off
rem Copies the latest Geode crash log (and the end of the latest game log) to the clipboard
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s = Get-Content -Raw -LiteralPath '%~f0'; $i = $s.IndexOf('#PS' + 'START'); Invoke-Expression $s.Substring($i)"
pause
exit /b

#PSSTART
$ErrorActionPreference = "Stop"
function Find-GD {
    $here = Split-Path -Parent ((Get-Location).Path)
    foreach ($p in @((Get-Location).Path, $here)) {
        if (Test-Path (Join-Path $p "GeometryDash.exe")) { return $p }
    }
    $steam = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
    $libs = @()
    if ($steam) {
        $libs += $steam
        $vdf = Join-Path $steam "steamapps\libraryfolders.vdf"
        if (Test-Path $vdf) {
            Select-String -Path $vdf -Pattern '"path"\s+"([^"]+)"' | ForEach-Object { $libs += $_.Matches[0].Groups[1].Value -replace '\\\\', '\' }
        }
    }
    foreach ($lib in $libs) {
        $p = Join-Path $lib "steamapps\common\Geometry Dash"
        if (Test-Path (Join-Path $p "GeometryDash.exe")) { return $p }
    }
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = "Select GeometryDash.exe"
    $dlg.Filter = "GeometryDash.exe|GeometryDash.exe|Programs (*.exe)|*.exe"
    $owner = New-Object System.Windows.Forms.Form -Property @{ TopMost = $true }
    if ($dlg.ShowDialog($owner) -eq "OK") { return Split-Path -Parent $dlg.FileName }
    return $null
}

function Read-Shared($path) {
    $fs = [System.IO.File]::Open($path, 'Open', 'Read', 'ReadWrite')
    try { (New-Object System.IO.StreamReader($fs)).ReadToEnd() } finally { $fs.Close() }
}

$gd = Find-GD
if (-not $gd) { Write-Host "Geometry Dash not found." -ForegroundColor Red; return }

$crash = Get-ChildItem (Join-Path $gd "geode\crashlogs") -Filter *.log -ErrorAction SilentlyContinue | Sort-Object LastWriteTime | Select-Object -Last 1
$log = Get-ChildItem (Join-Path $gd "geode\logs") -Filter *.log -ErrorAction SilentlyContinue | Sort-Object LastWriteTime | Select-Object -Last 1

$text = ""
if ($crash -and $crash.LastWriteTime -lt (Get-Date).AddDays(-1)) {
    Write-Host "The newest crash log is from $($crash.LastWriteTime) - older than a day, probably not the current crash." -ForegroundColor Yellow
    $text += "=== NOTE: newest crash log is old ($($crash.LastWriteTime)); the current crash may not have written one ===`r`n"
}
if ($crash) {
    $text += "=== Crash log: $($crash.Name) ===`r`n" + (Read-Shared $crash.FullName) + "`r`n"
}
if ($log) {
    $lines = (Read-Shared $log.FullName) -split "`r?`n"
    $text += "=== First 25 lines of $($log.Name) ===`r`n" + (($lines | Select-Object -First 25) -join "`r`n") + "`r`n"
    $tail = $lines | Select-Object -Last 150
    $text += "=== Last 150 lines of $($log.Name) ===`r`n" + ($tail -join "`r`n")
}
$modsDir = Join-Path $gd "geode\mods"
if (Test-Path $modsDir) {
    $text += "`r`n=== geode\mods ===`r`n" + ((Get-ChildItem $modsDir -Filter *.geode | ForEach-Object { $_.Name }) -join ", ")
}
if (-not $text) { Write-Host "No Geode logs found in $gd\geode." -ForegroundColor Red; return }

Set-Clipboard -Value $text
Write-Host "Copied to the clipboard. Paste it into the chat (Ctrl+V)." -ForegroundColor Green
if ($crash) { Write-Host "Crash log: $($crash.LastWriteTime)" }
if ($text.Length -gt 4000) { Write-Host "The text is long; Telegram may split it into several messages." }
