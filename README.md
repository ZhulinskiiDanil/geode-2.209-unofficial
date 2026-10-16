# Geode for Geometry Dash 2.209 (unofficial, Windows)

> **This is NOT an official Geode release.** It is an experimental port of [Geode](https://github.com/geode-sdk/geode) 5.10.1 to GD 2.209, made with heavy AI assistance while the official update is not out yet. Do not report problems with it to the Geode team or to mod authors. When official Geode for 2.209 comes out, uninstall this and use the official one.

## What works
- The loader starts, the main menu and the Geode mods screen open.
- About 90% of the game functions are bound; the rest are missing and will crash a mod that uses them.
- Only Windows. Only the Steam version of GD 2.209.

## Install
1. Close Geometry Dash.
2. Download this repository (Code → Download ZIP) or the zip from Releases, unpack it.
3. Run `installer/install.bat`. It finds GD, checks that it is 2.209, moves your current Geode and mods to a `geode-backup-…` folder, and installs the port. It can also install the mods from `mods/`.

Your old 2.2081 mods will **not** work on 2.209, so the installer puts them into the backup.

## Uninstall
Run `installer/uninstall.ps1` (right click → Run with PowerShell). It restores the latest backup.

## Mods in `mods/`
Ported builds of the Zhulis mods:

| File | Mod |
|---|---|
| `zhulis.blitzkrieg.geode` | Blitzkrieg (needs `cvolton.level-id-api` and `geode.node-ids`, not included) |
| `zhulis.askdash.geode` | AskDash (needs `geode.node-ids`, not included) |
| `zhulis.icon-mayhem.geode` | Icon Mayhem (needs `geode.node-ids`, not included) |
| `zhulis.mods-manager.geode` | Zhulis Mods Manager |
| `zhulis.improved-logger.geode` | Improved Logger |
| `zhulis.mod-profiler.geode` | Mod Profiler |
| `zhulis.crash-doctor.geode` | Crash Doctor |
| `zhulis.ui-tweaker.geode` | UI Tweaker |
| `zhulis.faceitify.geode` | FACEITify |
| `zhulis.context-trainer.geode` | Context Trainer |
| MiSide menu | 119 MB, download from https://github.com/ZhulinskiiDanil/MiSide/releases/tag/v1.4.0-gd2.209 (options/keybinds screen tweaks are off on 2.209) |

Put a `.geode` file into `Geometry Dash/geode/mods`.

## Found a bug?
Open an issue using the "Bug report" template and attach the crash log from `Geometry Dash/geode/crashlogs`. Issues are read regularly.
