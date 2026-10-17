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

function Pick-GD {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = "Select GeometryDash.exe"
    $dlg.Filter = "GeometryDash.exe|GeometryDash.exe|Programs (*.exe)|*.exe"
    $owner = New-Object System.Windows.Forms.Form -Property @{ TopMost = $true }
    if ($dlg.ShowDialog($owner) -eq "OK") { return Split-Path -Parent $dlg.FileName }
    return $null
}

if (-not $GDPath) {
    # A copy of the game next to the installer (unzipped into the game folder) wins over Steam
    foreach ($p in @((Split-Path -Parent $here), $here)) {
        if (-not $GDPath -and (Test-Path (Join-Path $p "GeometryDash.exe"))) { $GDPath = $p }
    }
    if (-not $GDPath) { $GDPath = Find-GD }
    if ($GDPath) {
        Write-Host "Found Geometry Dash: $GDPath"
        $answer = Read-Host "Press Enter to install there, or type C to choose another copy of the game"
        if ($answer -match '^[cC]') { $GDPath = Pick-GD }
    } else {
        Write-Host "Geometry Dash was not found in the Steam libraries. Select GeometryDash.exe in the window that opens."
        $GDPath = Pick-GD
    }
}
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
# Geode does not always re-extract a replaced .geode; drop the extracted copies so every mod is unpacked fresh
$unzipped = Join-Path $GDPath "geode\unzipped"
if (Test-Path $unzipped) { Remove-Item $unzipped -Recurse -Force }

# Optional mods next to the installer (..\mods)
$bundled = Join-Path (Split-Path -Parent $here) "mods"
$files = @(Get-ChildItem (Join-Path $bundled "*.geode") -ErrorAction SilentlyContinue)
if ($files.Count -gt 0) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    # Mods that were installed before (now in the backup) start checked
    $previous = @(Get-ChildItem (Join-Path $backup "mods\*.geode") -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
    $entries = foreach ($f in $files) {
        $label = $f.BaseName
        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($f.FullName)
            $entry = $zip.GetEntry("mod.json")
            if ($entry) {
                $reader = New-Object System.IO.StreamReader($entry.Open())
                $json = $reader.ReadToEnd() | ConvertFrom-Json
                $reader.Close()
                $label = "$($json.name) $($json.version)  ($($f.BaseName))"
            }
            $zip.Dispose()
        } catch {}
        [pscustomobject]@{ File = $f; Label = $label; Checked = $previous -contains $f.Name }
    }
    $entries = @($entries | Sort-Object Label)

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Choose mods to install"
    $form.Size = New-Object System.Drawing.Size(560, 600)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true

    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.CheckOnClick = $true
    $list.Dock = "Fill"
    $list.IntegralHeight = $false
    foreach ($e in $entries) { [void]$list.Items.Add($e.Label, $e.Checked) }

    $panel = New-Object System.Windows.Forms.FlowLayoutPanel
    $panel.Dock = "Bottom"
    $panel.Height = 44
    $panel.FlowDirection = "RightToLeft"
    $panel.Padding = New-Object System.Windows.Forms.Padding(6)
    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = "Install"
    $ok.DialogResult = "OK"
    $skip = New-Object System.Windows.Forms.Button
    $skip.Text = "Skip mods"
    $skip.DialogResult = "Cancel"
    $none = New-Object System.Windows.Forms.Button
    $none.Text = "None"
    $none.Add_Click({ for ($i = 0; $i -lt $list.Items.Count; $i++) { $list.SetItemChecked($i, $false) } })
    $all = New-Object System.Windows.Forms.Button
    $all.Text = "All"
    $all.Add_Click({ for ($i = 0; $i -lt $list.Items.Count; $i++) { $list.SetItemChecked($i, $true) } })
    $panel.Controls.AddRange(@($ok, $skip, $none, $all))

    $form.Controls.Add($list)
    $form.Controls.Add($panel)
    $form.AcceptButton = $ok
    $form.CancelButton = $skip

    if ($form.ShowDialog() -eq "OK") {
        foreach ($i in $list.CheckedIndices) { Copy-Item $entries[$i].File.FullName $mods }
        Write-Host "Installed $($list.CheckedIndices.Count) mod(s)."
    } else {
        Write-Host "No mods installed."
    }
}

Write-Host "Done. Start the game. To undo, run uninstall.ps1." -ForegroundColor Green
