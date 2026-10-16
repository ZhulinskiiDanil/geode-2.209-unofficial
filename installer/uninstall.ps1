# Restores the most recent backup made by install.ps1
param([string]$GDPath = "")
$ErrorActionPreference = "Stop"
if (-not $GDPath) {
    $steam = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
    $libs = @($steam)
    $vdf = Join-Path $steam "steamapps\libraryfolders.vdf"
    if (Test-Path $vdf) { Select-String -Path $vdf -Pattern '"path"\s+"([^"]+)"' | ForEach-Object { $libs += $_.Matches[0].Groups[1].Value -replace '\\\\', '\' } }
    foreach ($lib in $libs) { $p = Join-Path $lib "steamapps\common\Geometry Dash"; if (Test-Path "$p\GeometryDash.exe") { $GDPath = $p } }
}
$backup = Get-ChildItem $GDPath -Directory -Filter "geode-backup-*" | Sort-Object Name -Descending | Select-Object -First 1
if (-not $backup) { Write-Host "No backup found." -ForegroundColor Red; exit 1 }

Remove-Item (Join-Path $GDPath "Geode.dll"), (Join-Path $GDPath "XInput1_4.dll") -ErrorAction SilentlyContinue
$mods = Join-Path $GDPath "geode\mods"
if (Test-Path $mods) { Rename-Item $mods ("mods-2.209-" + (Get-Date -Format "yyyyMMdd-HHmmss")) }
Get-ChildItem $backup.FullName | ForEach-Object {
    if ($_.Name -eq "mods") { Move-Item $_.FullName $mods } else { Move-Item $_.FullName $GDPath }
}
Remove-Item $backup.FullName
Write-Host "Restored from $($backup.Name)" -ForegroundColor Green
