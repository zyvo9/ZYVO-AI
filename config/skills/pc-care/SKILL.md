---
name: pc-care
description: Windows PC care playbook — SPEED MODE for slow/old PCs (startup trim, debloat, safe services, visual effects, disk/SSD care, thermal throttling check, hidden-malware slowness, Windows 11 on old hardware via documented TPM bypass), PC DOCTOR repairs (blue-screen minidump reading with per-code table, RAM/disk tests, deleted-file and SD-card recovery, USB/RAW drive repair, malware cleanup, sfc/DISM repair ladder, no-boot rescue) and AUTOMATION (AutoHotkey v2 macros, robocopy/schtasks backups, ffmpeg/python bulk file jobs). Use when the user says their PC is slow/lagging ("pc slow", "speed barao"), asks to fix a crash/blue screen, recover deleted files, repair a USB/SD card, remove a virus, speed up boot, install Windows 11 on an old PC, automate a repeated task, make a macro/auto-clicker, or set up an automatic backup.
---

# PC Care Playbook (speed · repair · automation)

You are a careful Windows technician. Three rules before everything:

1. **RESTORE POINT / BACKUP first** — `Checkpoint-Computer -Description
   "before-pc-care"` (PowerShell admin) before registry/service changes; a
   change you cannot undo is a change you do not make.
2. **Measure → one change → measure** — record boot time, idle CPU/RAM and
   free-disk% BEFORE touching anything; deliver a before/after table.
3. **No mystery cleaners** — "free PC cleaner/booster/driver updater"
   downloads ARE the malware in most cases. Everything here uses built-in
   Windows tools or named open-source utilities only.

## PART A — PC SPEED MODE (the system-level potato)

Work top-down; the first items carry most of the gain.

### A.1 — Diagnose before touching (5 minutes)

- Task Manager → sort by CPU / RAM / Disk / GPU — name the actual hog
- Startup tab: list everything Enabled with its publisher
- Free disk space: SSD/HDD needs **15-20% free** or it throttles itself
- Disk kind: SSD or HDD (`Get-PhysicalDisk | ft FriendlyName,MediaType`) —
  an old HDD machine's best upgrade advice IS an SSD; say it
- Temps: HWMonitor / `powercfg /energy` report — a 90°C laptop is dust in
  the fan, not "Windows being slow"; thermal throttling beats every tweak

### A.2 — Startup trim (biggest single win)

- Task Manager → Startup → disable everything non-essential (updaters,
  helpers, clouds) — DISABLE, never uninstall, and keep the list in notes
- `shell:startup` + `shell:common startup` folders + Task Scheduler logon
  tasks — vendors love hiding autoruns there
- Sysinternals **Autoruns** (official Microsoft) for the deep sweep —
  anything not Microsoft-hardware-essential gets questioned

### A.3 — Debloat the safe tier (manual, reversible)

- Uninstall trial AVs (Norton/McAfee — Defender alone is better and lighter),
  vendor game-launcher helpers, preinstalled bloat from Settings → Apps
- Settings → Privacy: turn off ads/tips/suggestions/telemetry toggles
- Visual effects: `sysdm.cpl` → Advanced → Performance → **Adjust for best
  performance**, but keep "Smooth edges of screen fonts"
- Power plan: High performance (plugged-in laptops), `powercfg /setactive`
- Services — ONLY the known-safe list, never random ones: Fax, Remote
  Registry, Xbox services (if unused), Connected User Experiences &
  dmwappushservice (telemetry). Set to Manual, not Disabled, unless sure.

### A.4 — Disk & memory

- `cleanmgr /sagerun:1` after `cleanmgr /sageset:1` (tick everything),
  Storage Sense ON, move old Downloads/Videos to an external drive
- HDD → defrag weekly (`dfrgui`); SSD → NEVER defrag, verify TRIM:
  `fsutil behavior query DisableDeleteNotify` must be `= 0`
- Page file: leave "system managed" unless RAM is tiny; on tiny-RAM+HDD
  machines a larger fixed page file on the fastest disk helps
- Browser = the real RAM hog on 4-8GB machines: extension audit,
  hardware-acceleration OFF on very old GPUs, tab-discipline advice

### A.5 — Hidden cause: malware pretending to be slowness

Slowness that no tweak fixes = a miner or adware: full **Defender offline /
boot-time scan**, Autoruns sweep for unknown publishers, hosts-file check,
browser-hijack reset. Never install a "booster" — see golden rule 3.

### A.6 — Old-PC extras

- Windows 11 on unsupported hardware is a documented, official-ISO path:
  registry `HKLM\SYSTEM\Setup\MoSetup` → `AllowUpgradesWithUnsupportedTPMOrCPU`
  = 1, or a Rufus-made install USB (it has the bypass checkbox). Personal
  machine, official ISO only. Activating with pirated keys is refused —
  the bypass covers INSTALLING, not licensing.
- Honest advice when RAM < 8GB and HDD-only: the SSD (+RAM) upgrade beats
  every software tweak combined — say it, with a price ballpark.

### A.7 — Verify speed mode

Boot stopwatch before/after, idle CPU/RAM %, the original complaint retested
(their game FPS, their app's load). Deliver: before → after table + every
change listed + restore-point name.

## PART B — PC DOCTOR (repair & recovery)

### B.1 — Blue screen (BSOD) — read it, don't guess

1. Dump lives in `C:\Windows\Minidump\` — open with **BlueScreenView**
   (NirSoft) or WinDbg `!analyze -v`; note the STOP code + the blamed driver
2. Common codes → the actual cause:

| STOP code | Usual culprit | Test |
|---|---|---|
| MEMORY_MANAGEMENT | RAM | `mdsched` (Windows Memory Diagnostic) / MemTest86 overnight |
| PAGE_FAULT_IN_NONPAGED_AREA | RAM or disk | RAM test, then disk SMART |
| DRIVER_IRQL_NOT_LESS_OR_EQUAL | a driver (the dump names it) | roll back/reinstall that driver |
| KMODE_EXCEPTION_NOT_HANDLED | driver/software | recent installs first |
| WHEA_UNCORRECTABLE_ERROR | hardware/overclock/PSU | reset BIOS defaults, temps, PSU |
| DPC_WATCHDOG_VIOLATION | SSD firmware/driver | SSD vendor tool + driver |
| INACCESSIBLE_BOOT_DEVICE | disk mode/failing disk | BIOS SATA mode (AHCI), disk health |

3. Fix the named culprit, reboot, confirm: no new dump for days = fixed

### B.2 — Disk & RAM health

- SMART: `wmic diskdrive get model,status` (quick), CrystalDiskInfo (real:
  health %, reallocated/pending sectors); CrystalDiskInfo Caution = **copy
  the data NOW, then replace** — say this in bold
- `chkdsk C: /f /r` (filesystem/sector repair, needs reboot)
- RAM: `mdsched` now, MemTest86 for a real answer; reseat sticks first —
  a dusty slot mimics bad RAM

### B.3 — Deleted-file recovery (the panic call)

1. **STOP using that drive immediately** — every new write can overwrite
   the deleted file; no installs, no downloads, minimal activity
2. Recover TO A DIFFERENT DRIVE, never onto the same one:
   - `winfr C: D: /regular /n *.docx` (Windows File Recovery, official)
   - **Recuva** (easiest GUI) or **PhotoRec** (deep signature scan —
     reformatted/RAW cards too)
3. SD cards / USB sticks: same, plus card-lock check; if the card is RAW:
   testdisk for partition recovery BEFORE reformatting
4. Honest odds: deleted yesterday on a busy SSD with TRIM = often gone;
   say it early, don't sell false hope — and set up Recycle-Bin/backup
   habits after the rescue

### B.4 — USB / SD card repair

- Seen but won't open: `chkdsk E: /f` first
- RAW/no partition: testdisk → recover partition; else `diskpart` →
  `clean` → `create partition primary` → `format fs=exfat quick`
  (clean DESTROYS data — recovery first if data matters)
- Write-protected: physical lock switch, then `attributes disk clear
  readonly` in diskpart

### B.5 — Malware cleanup (safe order)

1. Defender **offline scan** (boots outside Windows — cleaners can't hide)
2. Autoruns: unknown publishers OFF; browser reset (extensions, homepage,
   search engine); hosts file (`C:\Windows\System32\drivers\etc\hosts`)
3. If it survives: Malwarebytes free second-opinion scan
4. Fake-AV warnings ("your PC is infected, call this number") = close it,
   it's a scam page — never call, never pay

### B.6 — Windows repair ladder (least destructive first)

`sfc /scannow` → `DISM /Online /Cleanup-Image /RestoreHealth` → `chkdsk` →
in-place upgrade repair (official ISO setup.exe, **keeps files/apps**) →
Reset (last resort). **DATA BEFORE WIPE:** before any reset/reinstall, ask
what is not backed up and rescue it (B.3) — a wipe without that question is
the one mistake this playbook never forgives.

### B.7 — No-boot rescue

Official Media Creation Tool USB → Repair → startup repair / `bootrec
/fixmbr`, `/fixboot`, `/rebuildbcd`; still dead → pull the disk, attach to
another PC (USB adapter), copy the data, THEN reinstall.

## PART C — PC AUTOMATION (the boring-repeat killer)

### C.1 — AutoHotkey v2 (clicks, keys, windows)

Install: `winget install AutoHotkey.AutoHotkey`. Recipes:

```ahk
; text expander — type @addr, get the full address
:*:@addr::742 Evergreen Terrace, Springfield

; Ctrl+Alt+Space = always-on-top toggle for the active window
^!Space::WinSetAlwaysOnTop -1, "A"

; F8 auto-clicker — every 0.5s at the mouse position, Esc stops it
#Requires AutoHotkey v2
#MaxThreadsPerHotkey 2
F8:: {
    static clicking := false
    clicking := !clicking
    while clicking {
        Click
        Sleep 500
    }
}
Esc::ExitApp
```

Rules: every loop has an Esc/kill hotkey; never put a password into a
plaintext script; log actions when the script touches files.

### C.2 — File & media batch jobs (already-in-hand tools)

- Bulk rename: python one-liner / PowerRename (PowerToys)
- Bulk video compress/convert: ffmpeg (`for %f in (*.mp4) do ffmpeg -i "%f"
  -vcodec libx264 -crf 28 "%~nf_small.mp4"`) — phone videos shrink 5-10×
- Bulk image resize: ImageMagick `mogrify -resize 1600x`; PDF merge/split:
  pypdf

### C.3 — Scheduled backups (the one everyone needs)

`schtasks` + **robocopy**, weekly to an external/second drive:

```
robocopy "C:\Users\<u>\Documents" "E:\Backup\Documents" /MIR /XD node_modules ".git" /R:1 /W:1 /LOG:E:\Backup\logs\%DATE%.log
```

`/MIR` mirrors deletions — for an append-only safe variant use `/E /XO`
instead. Verify with the log line count + a random-file open test. Deliver
the exact schtasks command + how to test it + how to stop it.

### Termux note

This skill guides from any build; the actual work runs on the PC (zyvo PC
build), and the phone-control skill can drive that PC from the phone.
