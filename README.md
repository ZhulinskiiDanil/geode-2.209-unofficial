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

## Community mods in `mods/community/`
Unofficial rebuilds for the 2.209 port: only `mod.json` (GD version) and API fixes were changed, nothing was added. They are published only for mods whose license allows redistribution; each license is in `mods/community/licenses/`. All credit goes to the authors; don't report problems with these builds to them.

| File | Mod | Author / source | License |
|---|---|---|---|
| `xboctatuk.globallistpositions.geode` | Global List Integration | [XBOCTATUK](https://github.com/XBOCTATUK/Global-List-Integration) | MIT |
| `fleym.nongd.geode` | Jukebox | [Fleeym](https://github.com/Fleeym/jukebox) | MIT |
| `beat.click-sound.geode` | Click Sounds | [clicksounds](https://github.com/clicksounds/geode-clicksound) | MIT |
| `prevter.imageplus.geode` | Image Plus | [Prevter](https://github.com/Prevter/ImagePlus) | MIT |
| `geode.devtools.geode` | DevTools | [Geode Team](https://github.com/geode-sdk/DevTools) | MIT |
| `hiimjustin000.more_icons.geode` | More Icons | [hiimjasmine00](https://github.com/hiimjasmine00/MoreIcons) | MIT |
| `hiimjustin000.more_object_info.geode` | More Object Info | [hiimjasmine00](https://github.com/hiimjasmine00/MoreObjectInfo) | MIT |
| `mat.run-info.geode` | Run Info | [matcool](https://github.com/matcool/geode-mods) | MIT |
| `alk.better-touch-prio.geode` | Better Touch Prio | [altalk23](https://github.com/altalk23/FuckTouchPrio) | Unlicense |

Global List Integration needs **Node IDs** (`geode.node-ids`). Node IDs has no license file, so its rebuild is not published here; ask whoever shared this port with you for it.

## Found a bug?
Open an issue using the "Bug report" template and attach the crash log from `Geometry Dash/geode/crashlogs`. Issues are read regularly.
