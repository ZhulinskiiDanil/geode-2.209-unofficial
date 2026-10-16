# Unofficial Geode 5.10.1 for Geometry Dash 2.209 (Windows) installer
# Backs up the current Geode install and mods, then installs the port.
param([string]$GDPath = "")
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$GD2209Timestamp = 1791899187

function Find-GD {
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
    return $null
}

if (-not $GDPath) { $GDPath = Find-GD }
if (-not $GDPath -or -not (Test-Path (Join-Path $GDPath "GeometryDash.exe"))) {
    Write-Host "Geometry Dash not found. Run: install.ps1 -GDPath 'C:\path\to\Geometry Dash'" -ForegroundColor Red
    exit 1
}
Write-Host "Geometry Dash: $GDPath"

# Check the game version by the PE timestamp
$bytes = [System.IO.File]::ReadAllBytes((Join-Path $GDPath "GeometryDash.exe"))
$pe = [BitConverter]::ToInt32($bytes, 0x3c)
$ts = [BitConverter]::ToUInt32($bytes, $pe + 8)
if ($ts -ne $GD2209Timestamp) {
    Write-Host "This is not Geometry Dash 2.209 (timestamp $ts). Aborting." -ForegroundColor Red
    exit 1
}

if (Get-Process GeometryDash -ErrorAction SilentlyContinue) {
    Write-Host "Close Geometry Dash first." -ForegroundColor Red
    exit 1
}

# Back up the previous Geode and mods
$backup = Join-Path $GDPath ("geode-backup-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
New-Item -ItemType Directory $backup | Out-Null
foreach ($f in "Geode.dll", "XInput1_4.dll", "GeodeUpdater.exe") {
    $src = Join-Path $GDPath $f
    if (Test-Path $src) { Move-Item $src $backup }
}
$mods = Join-Path $GDPath "geode\mods"
if (Test-Path $mods) { Move-Item $mods (Join-Path $backup "mods") }
Write-Host "Backup: $backup"

# Install
Copy-Item (Join-Path $here "Geode.dll"), (Join-Path $here "XInput1_4.dll") $GDPath
$res = Join-Path $GDPath "geode\resources\geode.loader"
if (Test-Path $res) { Remove-Item $res -Recurse -Force }
New-Item -ItemType Directory -Force $res | Out-Null
Copy-Item (Join-Path $here "resources\*") $res -Recurse
New-Item -ItemType Directory -Force $mods | Out-Null

# Optional mods next to the installer (..\mods)
$bundled = Join-Path (Split-Path -Parent $here) "mods"
if (Test-Path $bundled) {
    $answer = Read-Host "Install the bundled mods too? (y/n)"
    if ($answer -eq "y") { Copy-Item (Join-Path $bundled "*.geode") $mods }
}

Write-Host "Done. Start the game. To undo, run uninstall.ps1." -ForegroundColor Green
