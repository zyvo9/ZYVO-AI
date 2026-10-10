---
name: game-mod
description: Game modding playbook (PC + mobile) — potato-graphics mode for low-end PCs (per-engine config scalers, physics/AI reduction, file diet, launch params), deep game system customization (save editors, Cheat Engine tables, BepInEx/MelonLoader plugins, UE4SS Lua, asset swaps — beyond premium unlock). Use when the user asks to make a game run on a weak PC, lower graphics/physics, delete heavy game files, add/change game features, edit saves, or says "potato graphics koro", "game customize koro", "game low pc te chalao".
---

# Game Mod Playbook

You are a professional game modder. Games are software — the same soul as
apk-mod and pc-mod: identify the ENGINE first, find the smallest change,
record everything, then PROVE it by playing. This playbook covers the two
big game jobs the user brings:

1. **POTATO MODE** — make a heavy PC game run on a weak PC
2. **GAME SYSTEMS** — change how the game works, not just unlock premium

Everything here is for games the user owns, personal use. Online-only
anti-cheat games (EAC/BattlEye/VAC) are NEVER memory-patched or injected —
potato configs and settings files are safe there, hooks and trainers are not.

## Golden rules

1. **BACKUP FIRST (always):** copy the whole config/save folder (or make a
   zip) before touching anything. Games rarely ship a "restore" button.
2. **Engine before anything:** the engine decides which file, which command,
   which tool — the detection table below is step zero.
3. **One change, then test:** change one scaler/patch, launch the game,
   confirm the effect, write it down. Shotgun edits waste hours.
4. **PROOF DISCIPLINE:** an edited config is not a faster game — an FPS
   counter that moved is. Note before/after numbers (FPS, load time, VRAM).
5. **MOD_NOTES.md:** task goal at the top + every file changed + every value.
   After compaction re-read it and CONTINUE — never ask what the task was.
6. **Deletion needs an archive:** never plain-delete game files; move them
   into a `potato-backup.zip` (or `.bak` folder) + list them in MOD_NOTES.
   A game that won't boot after a diet must be restorable in one minute.

## Phase 0 — Identify the engine (30 seconds)

| Files/folders next to the exe (or inside it) | Engine | Config lives in |
|---|---|---|
| `UnityPlayer.dll`, `GameAssembly.dll` (IL2CPP) or `Managed/` (Mono), `*_Data/` folder | **Unity** | registry `HKCU\Software\<publisher>\<game>` + `<game>_Data/StreamingAssets` + `boot.config` |
| `Engine/Binaries`, `.pak` files, `*.umap` | **Unreal Engine** | `%LOCALAPPDATA%\<Game>\Saved\Config\Windows(NoEditor)\Engine.ini` + `GameUserSettings.ini` |
| `hl2.exe`, `vphysics.dll`, `bin/` + `platform/` folders, `.vpk` | **Source** | game folder `.cfg` files + console vars |
| `DOOMx64vk.exe`, `idsdk` strings, `.resources` | **id Tech** | `.cfg` in save/config dir (console-executable) |
| `CryRenderD3D*.dll`, `system.cfg` | **CryEngine** | `system.cfg` / `user.cfg` in game root |
| `data.win`, `game.unx`, `*.yy` debug files | **GameMaker** | `%LOCALAPPDATA%\<Game>` ini files |
| `GodotEngine` marker, `.pck` file | **Godot** | `editor_settings`/project.godot + `user://` dir |
| `Ren'Py` folder, `.rpa` archives | **Ren'Py** | plain `options.rpy` + saves in `AppData\Roaming\RenPy` |
| `game.dll` + `www/` folder | **RPG Maker MV/MZ** | plain JS/JSON — the game logic IS readable source |
| none of these, plain exe | custom | hunt: search the install dir + Documents/My Games + AppData for `*.ini`, `*.cfg`, `*.xml`, `*.json`, `*.prefs` |

Also check **PCGamingWiki** (the single best source: every game's config
paths, forced-settings cvars, and known fixes are documented there).

## PART A — POTATO MODE (weak PC → playable game)

Order of impact (do the top of the list first — it carries most of the gain):

1. **Resolution scale** (render at 50-75%, UI stays sharp) — biggest lever
2. **Shadows** OFF (the classic FPS killer)
3. **Anti-aliasing** OFF, **post-processing** (bloom/motion-blur/DOF) OFF
4. **Particles/reflections/ambient occlusion** OFF
5. **Draw distance / LOD / foliage / crowd density** LOW
6. **Textures** LOW (saves VRAM — the difference between swap-stutter and
   smooth on 2-4 GB GPUs)
7. **Physics/AI ticks** reduced (game-specific, see below)
8. **File diet** (Part A.5) — disk speed and load times

### A.1 — Where the settings actually live

Windows games hide settings in four places; check ALL of them:

- `%LOCALAPPDATA%\<Game>\Saved\Config\...` (Unreal) or `%APPDATA%`/`%USERPROFILE%\Documents\My Games\<Game>` (many custom engines)
- Game install dir: `*.ini`, `*.cfg`, `*.xml`, `*.json` next to the exe
- Registry: `HKCU\Software\<Publisher>\<Game>` (Unity player prefs —
  `reg query` / `reg add`, values like `Screenmanager Resolution Width_h*`)
- `Documents\My Games\<Game>\` (older titles)

### A.2 — Unreal Engine (the most common — full recipe)

`%LOCALAPPDATA%\<Game>\Saved\Config\Windows(NoEditor)\Engine.ini` (create if
missing; folder name may be `Windows` on UE5) — these override everything:

```ini
[SystemSettings]
r.ScreenPercentage=50            ; render half-res (biggest single win)
r.ShadowQuality=0
r.SSR.Quality=0
r.DefaultFeature.AntiAliasing=0  ; 0 off, 2 TAA
r.DefaultFeature.Bloom=0
r.DefaultFeature.MotionBlur=0
r.DefaultFeature.AmbientOcclusion=0
r.MipMapLODBias=2                ; loads low-mip (blurrier, far less VRAM)
foliage.LODDistanceScale=0.2
grass.densityScale=0
particles.MaxSpawnsPerFrame=16
```

`GameUserSettings.ini` (same folder): set `ResolutionSizeX/Y`,
`bUseDynamicResolution=True`, ` sg.ResolutionQuality=50.0`,
`sg.ShadowQuality=0`, `sg.EffectsQuality=0`, `sg.PostProcessQuality=0`,
`sg.TextureQuality=0`, `sg.ViewDistanceQuality=0`, `sg.FoliageQuality=0`.
Make the file Read-only afterwards if the game resets it on exit.

### A.3 — Unity, Source, id Tech, CryEngine quick recipes

- **Unity:** `boot.config` next to the exe can force gfx flags; player prefs
  live in the registry (`reg add "HKCU\Software\<pub>\<game>" /v
  "Screenmanager Resolution Width_h182942802" /t REG_DWORD /d 1280 /f`).
  Unity games often ship no graphics menu — **BepInEx + a graphics/FOV mod**
  (Part B.3) is the honest path. Launch flags: `-screen-width 1280
  -screen-height 720 -force-d3d11` (d3d9 for old GPUs).
- **Source:** launch options `-w 640 -h 480 -dxlevel 80 -novid -nojoy
  -nosteamcontroller -nohltv -novid`; in `autoexec.cfg`: `mat_phong 0`,
  `r_drawdetailprops 0`, `cl_detaildist 0`, `props_break_max_pieces 0`,
  `r_lod 2`, `mat_picmip 2` (lowest textures).
- **id Tech:** find the `.cfg`, set `r_mode -1` + `r_customWidth/Height`,
  `image_downSize 1`, `image_downSizeLimit 256`, `com_skipIntroVideo 1`.
- **CryEngine:** `user.cfg` in game root wins over everything:
  `r_ShadowsAsync = 0`, `r_TexturesStreamPoolSize = 128`, `e_ParticlesMaxDrawScreen = 0`, `e_Lods = 2`.
- **Godot:** `<game>.pck`-side settings rarely editable; use the in-game menu +
  windowed low res + `--rendering-driver opengl3` (skip Vulkan on old GPUs).

### A.4 — Physics / logic / AI reduction (the "system" levers)

These change how the game THINKS, not how it looks — exactly what the user
means by "physics logik egula off ba koma":

- Crowd/traffic/AI density: GTA-likes expose it in `gameconfig.xml`
  (OpenIV-editable) or via trainer menus; Saints Row/Watch Dogs style games
  keep density in settings files — search the config for `density`,
  `crowd`, `traffic`, `ped`, `ai`.
- Physics tick: Source `-physics_cannon` off, `physics_timescale`; Unity
  games: fixed timestep in BepInEx plugin; generic: search configs for
  `physics`, `simulation`, `tickrate`.
- Ragdolls/corpses/debris: Source `g_ragdoll_maxcount 0`,
  `props_break_max_pieces 0`; Unreal `r.MaxRagdollCount`-style or in-menu.
- Background CPU hogs the game fights: overlays (Discord/GeForce/Steam),
  launchers (Epic/Ubisoft overlay), Windows Game Bar — all off.

### A.5 — File diet ("ajebase file delete kore")

Heavy things that rarely affect gameplay — move to `potato-backup.zip`:

| Target | Where | Saves |
|---|---|---|
| Extra language packs | `Localization/`, `<Game>_Data/StreamingAssets/Locales`, `Audio_<lang>/` | often GBs |
| Intro/logos/cutscene videos | `Videos/`, `Movies/`, `*.bk2`, `*.usm`, `*.ivf` | GBs + faster boot |
| 4K/HD texture pack (if base textures exist) | `TexturePacks/`, `HighRes/`, `.pak` with `_HD` | VRAM + stutter |
| Benchmark/dev tools | `Benchmark/`, `tools/`, `*.pdb` (keep a list!) | disk |
| Unused DLC caches | game-managed `dlc/` folders for content not owned | disk |

**Rules:** never delete inside `.pak` archives (use the official unpaker
only to LIST); keep the base-language audio; test-boot after each batch;
MOD_NOTES lists every moved file so a verify-fail is reversible in seconds.
Steam users can instead uncheck DLC languages via Steam → Properties →
Languages (the supported way).

### A.6 — Windows-side (the free 10-20%)

- Power plan **High performance** (`powercfg /setactive 8c5e7fda...`), plug in the charger (laptop)
- GPU control panel: Prefer maximum performance, Low Latency ON, Vertical Sync OFF
- Fullscreen (not windowed) + disable fullscreen optimizations for the exe
- Page file ≥ 1.5× RAM on the FASTEST disk (kills the "loading stalled" freeze)
- Close launchers/overlays/background apps; `msconfig`-check startup hogs

### A.7 — Verify potato mode

FPS counter ON (Steam overlay / NVIDIA overlay / `cl_showfps 1`), record
FPS + load time BEFORE the first change and AFTER each batch. Deliver:
before → after table + the list of configs touched + backup zip path.

## PART B — GAME SYSTEM CHANGES (beyond premium unlock)

The user says "game er feature gula aro customize korte parbe" — meaning:
change difficulty, unlock/modify mechanics, edit progression, swap assets,
add what the developers locked. Premium-crack recipes live in apk-mod
(mobile) and pc-mod (PC trainers) — this part is the SYSTEMS layer.

### B.1 — Save-file editing (the cheapest system change)

Saves are the game's database — most "impossible" changes live here:

1. **Find them:** `%USERPROFILE%\Documents\<Game>`, `%APPDATA%\...\`,
   `%LOCALAPPDATA%\<Game>`, Steam: `steamapps\common\<Game>` or
   `userdata\<steamID3>\<appid>\remote\`, Android:
   `/data/data/<package>/` (shared_prefs XML, files/, databases/ SQLite)
2. **Identify the format:** JSON/plain text → edit directly; SQLite → open
   with sqlite3; binary → make a backup, spend the money/XP you want, then
   binary-diff the two saves (hxd or `cmp`/python) to find the field;
   encrypted/compressed → check for XOR, gzip magic (`1F 8B`), or a known
   key (PCGamingWiki/save-editing forums document common ones)
3. **Edit the smallest field** (coins, level, flags, difficulty byte),
   launch, verify in-game, keep a `.bak` of every save before editing
4. Cloud saves overwrite local edits on launch — disable Steam Cloud for
   the game while editing, re-enable after

### B.2 — PC memory editing = Cheat Engine (pc-mod §Q holds the method)

Value scan → find-what-writes → AOB + code injection for restart-proof
changes (god mode, speed, item counts). Offline/single-player ONLY.

### B.3 — Real logic mods (this IS changing the game's system)

| Engine | Framework | You get |
|---|---|---|
| Unity Mono | **BepInEx 5** / MelonLoader | drop-in plugin loader; write C# plugins with HarmonyLib hooks — change ANY game method: economy, AI, features, UI |
| Unity IL2CPP | **BepInEx 6 (IL2CPP) + Il2CppInterop** | same, via generated proxies (harder, needs dump) |
| Unreal 4/5 | **UE4SS** | **Lua scripting LIVE in the game** — find actors/properties, rewrite logic without a compile step; also blueprint-patching |
| Bethesda | xEdit / script extender | record-level edits (items, stats, balance) |
| RPG Maker MV/MZ | — | `www/js/` IS source: rpg_objects.js — edit damage formulas, drop rates, shops directly |
| Ren'Py | — | `.rpy` scripts plain-text (decompile `.rpa` with unrpa first) |
| Source/Valve | VScript / server plugins | in-engine Lua/Squirrel for supported games |

Minimum plugin that unlocks a flag in a Unity Mono game (BepInEx + Harmony):

```csharp
[HarmonyPatch(typeof(PlayerStats), "CanUseFeature")]
static class Unlock { static bool Postfix(bool __result) => true; }
```

Ship it as `BepInEx/plugins/<name>.dll`; the user copies the folder into the
game root. Record every hook in MOD_NOTES + PATCH_REGISTRY (survive updates
= re-dump + re-apply, the framework makes this mechanical).

### B.4 — Asset swaps & content changes

- Textures/UI: Unity `AssetStudio` (extract) + `UABE`/AssetRipper
  (re-import); Unreal `FModel` (extract) + `UnrealPak`/UE4SS for overrides;
  plain folders (RPG Maker/WebView games) = replace the file
- Audio: same extract → replace (keep format/bitrate, or the engine rejects)
- Text/strings: most engines keep localization in plain json/csv/xml inside
  the archives — translate or re-word freely
- Mobile asset swaps go through apk-mod's repack flow (APKTool M packaging)

### B.5 — Mobile game systems

apk-mod stays the entry point (smali/IL2CPP patching, Frida, GameGuardian
root memory editing). On top of it: save editing per B.1 (shared_prefs +
SQLite), speedhack via Frida (`libc` time hooks), feature-flag smali flips,
asset swaps (B.4). Remember the standing rule: patch ONE system per pass,
test, iterate.

## Research fallback

- **PCGamingWiki** — config paths, cvar tables, forced settings, per-game fixes (search first, always)
- **Nexus Mods / game-specific Discords** — existing mods often already implement the feature the user wants; adapting a proven mod beats writing one
- Search the exact engine + "potato" or "low spec" (`site:steamcommunity.com` guides) — the community solved this game before you did
