<div align="center">

# Zyvo AI

**The AI coding agent that lives on your phone.**

**Zyvo AI** (the `zyvo` command) is a free, open-source AI coding CLI for
Android Termux — build Android apps, websites, and motion-graphics videos
from your phone, no PC needed. A fork of
[opencode](https://github.com/anomalyco/opencode) (MIT), rebuilt natively
for Android.

`zyvo · zyvo ai · zyvoai · AI coding CLI · Termux · free AI models · Banglish`

</div>

---

## ⚡ Install

Install [Termux](https://github.com/termux/termux-app/releases) first — the
F-Droid or GitHub build (the Play Store version is outdated and unsupported) —
then run:

```bash
curl -fsSL https://raw.githubusercontent.com/zyvo9/ZYVO-AI/main/install.sh | bash
```

The installer checks your phone's architecture, installs dependencies, deploys
17 free AI models + 6 skills + agent memory, and verifies the binary runs.

Start it:

```bash
zyvo
termux-wake-lock    # optional: keeps long sessions alive
```

## 🤖 50 AI models, zero setup

zyvo ships with its own provider (**Zyvo**) pre-configured in
[`config/zyvo.json`](config/zyvo.json) — 17 hand-picked FREE models over
OpenRouter's stable official API (no tunnel drama), led by Nemotron 3 Ultra
550B with 1M context. No API keys, no setup: open `zyvo` and start.

Run out of quota or hit a dead model? Use the built-in **model tester** — it
probes every model, auto-retries failures (Smart Retry), and reports exactly
which ones are alive right now.

## 🧩 Six built-in skills

Skills are playbooks the agent loads on demand — just ask in plain language
(Banglish works):

| Skill | Say something like | What you get |
|---|---|---|
| `apk` | "ekta todo app banao" | Complete Android project, APK-ready structure |
| `webdev` | "landing page banao" | Modern responsive website |
| `lets-scroll` | "reel-type scroll video" | Reel-style scrolling web animation |
| `motion-animation` | "motion animation banao" / "ai motion animation" | Motion-graphics video — see below |
| `web2video` | "webpage theke video" | Turns a web animation into a rendered video |
| `phone-control` | "phone ta control koro" / "WiFi off koro" | Sees the screen (vision) and taps/swipes/types — Shizuku-style wireless pairing, no root |

## 🎬 Motion-graphics studio — the motion-animation skill

Not template-grade animation: a full **frame-level motion masterclass**,
distilled from 7 professional motion-design tutorials and encoded as 10 hard
laws the agent follows in every scene:

1. **Overlap cascade** — the next element starts at ~60% of the previous one; overlapping motion is what reads as *smooth*
2. **Easing discipline** — tuned springs and bezier curves; exits are faster than entrances; nothing stops dead (settle drift)
3. **Apple entrance formula** — opacity + scale 1.4→1 + blur 20→0, all on one spring
4. **Kinetic typography** — word cascades (4–7 frames), tracking settle, overshoot landings, line-mask reveals
5. **Fake camera** — push-in, parallax depth layers, deterministic handheld shake — static frames feel alive
6. **Beat sync** — cuts and zoom punches on a BPM grid, speed ramps, cut on action
7. **Transitions** — zoom crossfade, slide overlap, blur cut, mask wipe, whip pan — with the half-overlap rule
8. **Living backgrounds** — rotating gradients, ≤6%-opacity floaters, golden-angle particle fields
9. **Editorial layout** — 12-column grid, consistent margins, one accent color, mockup fly-ins
10. **Grade chain** — vignette → film grain → tint → letterbox, always the top layer

The skill also carries a copyable **reference scene** that combines all ten
laws, and a **pre-render checklist** (minimum 10 seconds / 300 frames / 3
scenes; render a 90-frame preview before committing to the full render).

## 🤝 AI video pipeline — agent + AI generator, together

Need real footage the phone can't render? zyvo writes the prompts, you generate
the clips, zyvo composes the final film:

```text
 zyvo (phone)                              you (phone)
 ────────────                              ───────────
 1. Storyboard + shot-by-shot        →     2. Paste each prompt into
    AI generation prompts                  Seedance / Kling / Higgsfield / Veo
                                           and download the clips

 3. Drop the clips into public/      ←     (zyvo detects them)
 4. Compose: trim, slow-mo, text,
    transitions, color grade
 5. Push → GitHub Actions renders    →     6. Download the MP4 🎬
```

Every prompt follows one template — shot type, one subject + one action, one
camera move, lighting, the same style keywords, 3–5s — so every clip matches
the same look.

## 🧠 Memory & updates

- **AGENTS.md memory** — deployed once and never overwritten by updates; the
  agent remembers your preferences and project decisions across sessions
- **Obsidian vault (2nd brain)** — deep memory (session logs, project
  dossiers, lessons) in a markdown vault you can open and edit in the
  Obsidian app; hot facts stay in AGENTS.md
- **Delta updates** — the installer doubles as an updater: re-run the same
  one-liner and only what changed is re-fetched (skills update per-file)

## ☁️ How video rendering works

Termux can't run a headless-browser render farm — so zyvo doesn't try. The
motion-animation skill scaffolds your video project with a `render.yml`
GitHub Actions workflow:

| Stage | Where it runs |
|---|---|
| Storyboard, AI prompts, Remotion code | your phone (zyvo) |
| Code push + render trigger | your phone (git) |
| Headless browser render → MP4 | GitHub Actions (free) |

## 📱 Device support

| Device | Status |
|---|---|
| aarch64 Android 7+ in Termux — every modern phone | ✅ Supported |
| Android 7+ via proot-distro (Ubuntu in Termux) | ✅ Works |
| 32-bit ARM phones (pre-2016) | ❌ Bun is 64-bit only — use zyvo remotely over SSH |
| x86_64 emulators / Chromebooks | 🔜 Planned |
| Windows / macOS / Linux PC | ✅ zyvo PC builds (`pc-v*` releases) or upstream opencode |

## 🔨 How the Android build works

opencode ships as a compiled Bun binary, and Bun has no official Android
target — so this repo cross-compiles the whole stack (Bun, JavaScriptCore, ICU,
OpenTUI) against Android's own libc (bionic). The result is a single standalone
arm64 binary that runs natively in Termux with no proot and no glibc layer.

Builds run on GitHub Actions (`.github/workflows/android-build.yml`) and every
successful build updates the [Releases](https://github.com/zyvo9/ZYVO-AI/releases)
page. The build system lives in [`android/`](android/), based on
[guysoft/opencode-termux](https://github.com/guysoft/opencode-termux) (MIT).

## 🗂️ Repo layout

```
android/     Android cross-compile toolchain + build docs
config/      zyvo.json (17 free models) · skills/ · AGENTS.md · model probes
install.sh   one-command installer + delta updater
packages/    opencode source (the fork)
```

## 🗺️ Roadmap

- [x] Native Android (aarch64) build for Termux
- [x] One-command installer + delta updates
- [x] `zyvo` rebrand — command, config, TUI
- [x] Zyvo provider — 17 free models via OpenRouter
- [x] Six built-in skills (apk, webdev, lets-scroll, motion-animation, web2video, phone-control)
- [x] Motion-animation masterclass + AI video pipeline
- [x] Model tester with Smart Retry
- [ ] OmniRoute on permanent public hosting
- [ ] x86_64 build (emulators, Chromebooks)

---

<details>
<summary>🔎 People search this as</summary>

zyvo · zyvo ai · zyvoai · zyvo-ai · ZYVO-AI github · zyvo app · opencode for android ·
opencode termux · ai coding cli android · ai coding app for phone · mobile ai code editor ·
free ai models termux · claude on termux · bangla ai coding · banglish ai · phone e coding ·
zyvo android · zyvo termux · zyvo download · ai coding agent android

</details>

## 📄 License

MIT — see [LICENSE](LICENSE).
