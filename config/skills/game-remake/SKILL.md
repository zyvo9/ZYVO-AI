---
name: game-remake
description: PC game REMAKE playbook for Android (Solarpunk-style porting) — extract assets/animations from Unity/Unreal/Godot/GameMaker games (AssetRipper full-project recovery, AssetStudio FBX-with-animation export, UModel/UE Viewer for Unreal), rebuild in Unity for Android (Hub + Android Build Support setup, URP mobile settings), write the game logic with AI (micro-task C# prompts — inventory, timers/growth, interaction, building, save systems), Mono decompile reference (dnSpy/ILSpy on Assembly-CSharp.dll), touch/joystick controls (Input System), mobile optimization (texture compression, batching, LOD), and the APK/AAB build with keystore. Use when the user asks to port a PC game to Android by rebuilding it, extract a game's assets/models/animations into a new engine, make a game remake, set up Unity for Android game dev, build an APK from a Unity project, or says "game remake koro", "asset extract kore notun engine e banao", "solarpunk port", "unity android build", "pc game er asset nao", "game port remake".
---

# Game Remake Playbook (PC → Android rebuild)

You are running a GAME REMAKE project: take a PC game's assets and mechanics,
and rebuild it as an Android game. The user writes/approves the design; YOU
write the engine code (C#), drive the extraction tools, and produce the APK.

Division of labor (memorize):
- **Assets (visuals)** — extracted from the PC game: models, textures,
  ANIMATION CLIPS come out intact with their rig. No re-animating needed.
- **Logic (brain)** — rewritten fresh: the conditions and rules (key checks,
  timers, inventory). You draft these as C# from the mechanics the user
  describes, using decompiled code as the reference when available.
- **Engine plumbing** — Unity project settings, touch controls, optimization,
  APK build. All yours.

## Golden rules

1. **BACKUP + PROJECT FOLDER**: one folder per remake
   (`D:\remakes\<game>\` with `extracted/`, `unity/`, `notes/`). Never work
   inside the installed game's folder.
2. **Engine first** — the extraction tool choice depends entirely on the
   engine (table below). Wrong tool = hours wasted.
3. **MOD_NOTES.md**: task goal + every extracted batch + every C# file
   written + every Unity setting changed. After compaction, re-read and
   CONTINUE silently.
4. **Verify by PLAYING**: build → install → play the mechanic that was just
   implemented. A compiled APK is not a working feature.
5. Personal/remake use. Extracted assets from a commercial game being
   distributed publicly = the user's legal call — say it in ONE line if they
   plan to publish, never lecture.

## Phase 0 — Identify the engine

Full detection table lives in the game-mod skill. Quick version:

| Marker in the game folder | Engine | Extraction tool |
|---|---|---|
| `<Game>_Data/` folder + `UnityPlayer.dll` | **Unity** | AssetRipper (full project) + AssetStudio (per-asset FBX) |
| `.pak` files + `Engine/Binaries` | **Unreal** | UModel/UE Viewer, FModel |
| `.pck` file | **Godot** | gdsdecomp |
| `data.win` | **GameMaker** | UndertaleModTool / GMExtract |
| `Managed/` folder with `Assembly-CSharp.dll` | Unity **Mono** | + dnSpy/ILSpy (logic reference — real C# readable!) |
| `GameAssembly.dll` (no Managed/) | Unity **IL2CPP** | Il2CppDumper (metadata only — logic must be rewritten) |

Unity + Mono = the golden path (assets AND readable original logic).
Unity + IL2CPP = assets still perfect, logic rewritten from behavior.

## Phase 1 — EXTRACT the assets

### Unity games (most simulators/solarpunk games)

1. **AssetRipper** (github.com/AssetRipper/AssetRipper — free, GUI):
   File → Open File/Folder → point at the game's `<Game>_Data` folder →
   **Export → All files → Unity project**. This recovers meshes, textures,
   prefabs, scenes and animation clips AS A UNITY PROJECT — the fastest
   possible skeleton for the rebuild.
2. **AssetStudio** (github.com/Perfare/AssetStudio) for surgical exports:
   - Filter the Asset List by `Mesh`, `Texture2D`, `AnimationClip`
   - Scene Hierarchy → tick the object (Player/Door/Tree) →
     **Export → Selected 3D objects → FBX with animation** — the FBX
     carries the rig + animation clips together, so nothing is re-animated
3. Textures come out as PNG; keep the folder structure
   (`extracted/models/`, `extracted/textures/`, `extracted/anims/`).

### Unreal games

- **UModel/UE Viewer** (gildor.org): select the .pak → export meshes as
  .psk/.fbx, textures as .tga, animations as .psa. Unreal → Unity needs
  re-rigging in Blender (state this honestly — it is real work).

### Godot / GameMaker

- Godot: **gdsdecomp** unpacks `.pck` into a readable project.
- GameMaker: **UndertaleModTool** opens `data.win` (sprites, sounds, code).

### Logic reference (when available)

- Mono games: open `Managed/Assembly-CSharp.dll` in **dnSpy/ILSpy** — the
  original C# is readable. Harvest the formulas (growth timers, costs,
  yields) as CONSTANTS for the rewrite — do not copy classes verbatim,
  use them as the spec.
- IL2CPP: Il2CppDumper gives class/method names + string tables — useful as
  a checklist of systems, not readable logic.

## Phase 2 — UNITY ANDROID SETUP

1. **Unity Hub** (unity.com/download) → install the latest **LTS** editor +
   tick modules: **Android Build Support** → **OpenJDK** + **Android SDK &
   NDK Tools** (all three, one click).
2. New project → 3D (URP) template. If AssetRipper exported a project, open
   THAT instead and add the URP package if missing.
3. Player Settings (File → Build Settings → Player Settings):
   - Scripting Backend: **IL2CPP**, Target Architectures: **ARM64** (+
     ARMv7 for old phones)
   - Texture compression: **ASTC**
   - Minimum API level: 24+ (Android 7)
   - Orientation: as the design needs (Landscape for most simulators)
4. Import the extracted assets: drag `extracted/` into `Assets/`. FBX rigs +
   clips import natively; set Texture import type to Sprite (2D) only if
   the game is 2D.

## Phase 3 — LOGIC (AI-written C#, micro-task by micro-task)

NEVER ask for "the game" in one prompt. Each mechanic = one script, one
conversation turn. The prompt pattern (Banglish fine):

- "Unity C#: player ei ghas-e click korle ghas destroy hobe ar inventory-te
  5 Fiber joge. Script dao."
- "Tree growth system: proti 30 second-e scale 20% barbe, 3 bar barle mature
  model-e swap hobe. Rain hole speed double."

The standard systems checklist for a simulator/solarpunk remake:
- [ ] Inventory (add/remove/count, UI binding)
- [ ] Interaction (raycast tap → harvest/open/talk)
- [ ] Growth timers (trees/crops: scale over time → swap prefab)
- [ ] Building (cost check → spawn prefab → place)
- [ ] Day/night cycle + energy production (solar: +5/day-second, 0 at night)
- [ ] Save/load (JSON to Application.persistentDataPath)
- [ ] Touch camera control (drag-rotate, pinch-zoom)
- [ ] UI (hotbar, counters, build menu)

Mono games: paste the decompiled constants (growth seconds, yields) INTO the
prompts so the remake matches the original balance.

## Phase 4 — ANIMATION integration

- FBX imports with the Animator + clips. Create an **Animator Controller**:
  states = the imported clips, parameters = bools/triggers
  (`isWalking`, `OpenDoor`, `isCutting`).
- Smoothness is free: every transition gets **Has Exit Time off** +
  **Transition Duration 0.15–0.25s** — the engine blends, no code.
- Particles/shaders (solarpunk green-growth effects) rarely extract cleanly —
  rebuild with Unity's particle system / Shader Graph; say this early.

## Phase 5 — TOUCH CONTROLS

- **Unity Input System** package → on-screen Stick + Button controls: drag
  into the canvas, bind actions — near-zero code.
- Tap-to-interact = a raycast from the touched screen point; the AI writes
  this as one small script.
- External controllers (Bluetooth gamepads) work through the same Input
  System — add later, costless.

## Phase 6 — MOBILE OPTIMIZATION

- URP asset: shadows OFF or 1 cascade, MSAA 2x, render scale 0.8
- Static batching + GPU instancing ON for the heavy prefab sets
- Texture import: ASTC 6x6 for most, crunch compression for UI atlases
- LOD groups on the extracted meshes (the originals usually carry LODs)
- Target: 60fps on a mid-range phone — test with the Android Profiler,
  not the editor.

## Phase 7 — BUILD the APK

1. Build Settings → Android → **Build** (APK for testing) / **Build App
   Bundle** (Play Store)
2. First build: Player Settings → Publishing Settings → **Create a new
   keystore** (save the password in MOD_NOTES — losing it loses update
   ability)
3. Install + launch: `adb install -r builds\<game>.apk` (or copy to the
   phone)
4. Verify EVERY system on the phone (Phase 3 checklist) — editor ≠ phone.

## Research fallback

- The exact game name + "AssetRipper" / "unity android port" — someone may
  have already extracted it
- Unity Learn + the official Input System docs for the mechanic tutorials
- PCGamingWiki for the game's engine + data paths
