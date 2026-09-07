---
name: motion-animation
description: Make motion animation VIDEOS (MP4) — write Remotion compositions and render them on GitHub Actions, not on the phone. Motion animations, promos, intros, explainers, animated text/charts/logos, product or brand animation clips with springs and interpolation. Use when the user asks for a motion animation, animation video, motion graphics, video, promo, intro, product animation, or ANY short animated clip ("motion animation banao", "ai motion animation", "animation banao" even without the word "video", "video banao").
---

# Motion Animation Factory (Remotion + GitHub Actions)

Make real MP4 videos programmatically. You write React/TypeScript
compositions (Remotion), push them to a repo, and GitHub Actions renders
the MP4 in the cloud. The user's phone does nothing heavy.

## ⛔ READ-BEFORE-CODE GATE (non-negotiable — read this first)

Almost every bad video comes from writing Remotion code from memory
instead of following THIS file. Before writing a SINGLE line of
composition code:

1. Read this ENTIRE file — the Pro Motion Masterclass (10 laws), the
   reference scene, and the pre-render checklist are below. They are the
   product; skipping them is how "faltu video" happens.
2. **Copy the REFERENCE SCENE as your starting skeleton.** Never start a
   composition from an empty component.
3. **Every scene must contain real motion** — entrance animations,
   camera push, floating, stagger, beat-synced cuts. A static slide
   where text just sits there = total failure. Redo it.
4. **Layout safety:** all text lives inside a centered container with
   horizontal padding (≥ 120px at 1920px width). Text must NEVER clip
   off the left or right edge of the frame. Long headline → split into
   two lines. Check every AbsoluteFill/positioned element stays inside.
5. **Apply the laws for real:** overlap cascade delays (next element at
   ~60% of previous), ONE accent palette, entrance = opacity + scale +
   blur together, exits faster than entrances, grade chain (vignette +
   grain) as the top layer. Minimum 10s / 300 frames / 3 scenes.
6. After writing the code, run the pre-render checklist (bottom of this
   file) line by line BEFORE pushing. If any box fails, fix first.

## Golden rules

1. The phone NEVER renders video — rendering happens on GitHub Actions
   (free for public repos, ~3-5 min for a 30s 1080p video).
2. Every animation must follow the motion craft rules: animate only
   transform/opacity, spring/interpolate for motion, sequences for scenes,
   tasteful easing, respect reduced motion.
3. Design follows the brand: ask the user for topic, colors, text content.
   Match the palette to the subject (see the webdev skill's design system).
4. 30fps, 1920x1080 default. MINIMUM duration 10 seconds (300 frames) —
   default 10-30s. NEVER shorter.
5. MINIMUM 3 scenes with distinct beats (hook -> build -> payoff), each
   with its own entrance animation. One static scene for the whole video
   is a failure.

## Autonomous delivery (the default flow)

Be fully autonomous: the user gives the TOPIC (and optional must-have
text/brand color) once — everything else you decide and execute without
intermediate questions.

1. Decide yourself: scene plan, duration, colors (design-standards
   rules), typography, animation style, music silence (no audio assets
   unless provided).
2. Scaffold, commit, push, render on Actions — no confirmation asks.
3. Watch the run via the API. If the render FAILS: fetch the log, fix
   the reported error, push again — up to 3 attempts, silently.
4. Deliver ONE message at the end: what you made + the MP4 download
   link + one line on how to request changes.
Only interrupt the user if credentials are missing or all 3 attempts fail.

## Requirements checklist (do this first)

- User has a GitHub account + Personal Access Token (repo + workflow
  scopes): https://github.com/settings/tokens/new?scopes=repo,workflow&description=Zyvo%20video
- Content from the user: topic, text/headlines, brand colors, duration.
- Node 20+ and git in Termux: `pkg install -y nodejs-lts git`

## Step 1 — Scaffold the Remotion project

Create under `$HOME/<videoname>/`:

```
<videoname>/
  package.json          (remotion, @remotion/cli, react, react-dom + @types)
  remotion.config.ts
  tsconfig.json
  src/index.ts          (registerRoot)
  src/Root.tsx          (Compositions)
  src/<Scene>.tsx       (one file per scene)
  .github/workflows/render.yml
```

Minimal Root.tsx pattern:
```tsx
import { Composition } from "remotion";
import { Promo } from "./Promo";

export const RemotionRoot = () => (
  <Composition
    id="Promo"
    component={Promo}
    durationInFrames={900}   // 30s at 30fps
    fps={30}
    width={1920}
    height={1080}
  />
);
```

Animation patterns (use everywhere):
```tsx
const frame = useCurrentFrame();
const opacity = interpolate(frame, [0, 20], [0, 1], {
  extrapolateRight: "clamp",
});
const y = spring({ frame, fps, config: { damping: 12 } });
// scenes in order:
<Sequence from={0} durationInFrames={90}><SceneOne /></Sequence>
<Sequence from={90} durationInFrames={120}><SceneTwo /></Sequence>
```

Design quality bar: real content (the user's actual text/brand), brand
colors from their brief, big readable type (video = large text), smooth
staggered entrances, backgrounds built from gradients/shapes/SVG — no
empty black frames.

## Step 2 — The render workflow

`.github/workflows/render.yml`:
```yaml
name: Render video
on:
  push:
    branches: [main]
jobs:
  render:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm install
      - run: npx remotion browser ensure
      - run: npx remotion render src/index.ts Promo out/promo.mp4
      - uses: actions/upload-artifact@v4
        with: { name: video, path: out/promo.mp4 }
      - name: Attach to release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: video-${{ github.run_number }}
          files: out/promo.mp4
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Step 3 — Push and render

1. Create the repo with the user's token (same as the apk skill flow).
2. git init/commit/push (token remote or gh auth).
3. Actions renders automatically (~3-5 min). Then:
```
curl -s -H "Authorization: token <TOKEN>" \
  https://api.github.com/repos/<user>/<repo>/releases/latest
```
→ give the user the video download link (release asset).
4. If the render fails: fetch the run log the same way as the apk skill,
   fix the reported file, push again.

## Step 4 — Iterate

Text/color/scene changes: edit → commit → push → new MP4 in ~3-5 min.
Tell the user this — iteration is cheap after the first render.

## Pitfalls

- Remotion needs a headless browser on the runner: `npx remotion browser
  ensure` (in the workflow) installs it — don't skip.
- Rendering audio: add assets to the repo (no external URLs at render).
- durationInFrames must cover the longest Sequence or scenes get cut.
- First render includes browser download — later runs are cached.
- Never render on the phone.


## PRO UPGRADE PACK (scene templates, audio, preview, brand)

### Scene code patterns (copy and adapt)

**Text reveal (word by word, spring):**
```tsx
const words = text.split(" ");
{words.map((word, i) => {
  const start = i * 8;
  const opacity = spring({ frame: frame - start, fps, config: { damping: 200 } });
  return <span key={i} style={{ opacity, display: "inline-block",
    transform: `translateY(${(1 - opacity) * 20}px)`, marginRight: "0.3em" }}>{word}</span>;
})}
```

**Logo outro (scale + fade at the end):**
```tsx
const appear = spring({ frame: frame - (durationInFrames - 45), fps });
const scale = interpolate(appear, [0, 1], [0.6, 1]);
<div style={{ opacity: appear, transform: `scale(${scale})` }}><Logo /></div>
```

**Animated bar chart (bars grow with stagger):**
```tsx
{data.map((item, i) => {
  const h = spring({ frame: frame - i * 6, fps, config: { damping: 15 } });
  return <div key={i} style={{ height: `${item.value * h}%`, width: 60,
    background: brandColor, alignSelf: "flex-end" }} />;
})}
```

**Background motion (subtle, never distracting):**
```tsx
const drift = interpolate(frame, [0, durationInFrames], [0, 40]);
<div style={{ transform: `translateX(${drift}px)` }} />  // slow drift layer
```

### Audio (music that fits)
- Add the music file to the repo (src/music.mp3)
- `<Audio src={staticFile("music.mp3")} volume={(f) => interpolate(f, [0, 30, durationInFrames - 30, durationInFrames], [0, 0.8, 0.8, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })} />`
- Mute during render if the user wants silent: volume 0.

### Quick preview (don't render the full video to check)
```
npx remotion render src/index.ts Promo out/preview.mp4 --frames=0-90
```
First 3 seconds tell you if the design/direction is right — check before
the full render.

### Brand parameterization
Ask the user once: brand color + brand text/logo. Then every scene uses
those values (pass via a constants object, not scattered literals).
Change brand = change 2 values = re-render.

## PRO MOTION CRAFT (smooth + beautiful video techniques)

### 1. Easing curves that feel alive
```tsx
// Bouncy overshoot (logos, cards popping in)
const pop = spring({ frame, fps, config: { damping: 8, stiffness: 120, mass: 0.8 } });

// Smooth glide (backgrounds, slides)
const glide = interpolate(frame, [0, 45], [0, 1], {
  easing: Easing.bezier(0.16, 1, 0.3, 1),  // expo-out — snappy start, soft landing
  extrapolateRight: "clamp",
});

// Elastic wobble (fun, playful content)
const wobble = spring({ frame, fps, config: { damping: 6, stiffness: 100 } });
```

### 2. Stagger choreography (elements enter one by one)
```tsx
const items = ["Feature 1", "Feature 2", "Feature 3"];
{items.map((text, i) => {
  const delay = i * 12; // 12 frames between each
  const opacity = interpolate(frame, [delay, delay + 15], [0, 1], { extrapolateRight: "clamp" });
  const translateY = interpolate(frame, [delay, delay + 15], [30, 0], {
    extrapolateRight: "clamp", easing: Easing.out(Easing.cubic),
  });
  return <div key={i} style={{ opacity, transform: `translateY(${translateY}px)` }}>{text}</div>;
})}
```

### 3. Gradient background that moves (not static)
```tsx
const angle = interpolate(frame, [0, durationInFrames], [135, 225]);
<div style={{
  background: `linear-gradient(${angle}deg, ${color1}, ${color2})`,
  width: "100%", height: "100%",
}} />
```

### 4. Scale + blur text entrance (cinematic feel)
```tsx
const blur = interpolate(frame, [0, 15], [10, 0], { extrapolateRight: "clamp" });
const scale = interpolate(frame, [0, 20], [1.3, 1], { extrapolateRight: "clamp", easing: Easing.out(Easing.cubic) });
<div style={{ filter: `blur(${blur}px)`, transform: `scale(${scale})` }}>
  {bigTitle}
</div>
```

### 5. Countdown / timer animation
```tsx
const secondsLeft = Math.ceil((durationInFrames - frame) / fps);
const scale = spring({ frame: frame % fps, fps, config: { damping: 10 } });
<div style={{ transform: `scale(${scale})`, fontSize: 120, fontWeight: 900 }}>
  {secondsLeft}
</div>
```

### 6. Floating particles (ambient background)
```tsx
{Array.from({ length: 20 }).map((_, i) => {
  const seed = i * 137.5;
  const x = (Math.sin(seed) * 0.5 + 0.5) * 100;
  const speed = 0.3 + (i % 5) * 0.15;
  const y = ((frame * speed + i * 80) % 1200) - 100;
  const size = 4 + (i % 3) * 3;
  return <div key={i} style={{
    position: "absolute", left: `${x}%`, top: y, width: size, height: size,
    borderRadius: "50%", background: brandColor, opacity: 0.15,
  }} />;
})}
```

### 7. Scene transition (zoom crossfade)
```tsx
// Previous scene zooms IN while fading out, next scene zooms OUT while fading in
const progress = interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" });
const oldScale = interpolate(progress, [0, 1], [1, 1.15]);
const newScale = interpolate(progress, [0, 1], [1.15, 1]);
const oldOpacity = 1 - progress;
// Layer: old scene behind, new scene on top with opacity = progress
```

### 8. Kinetic typography (each word does something different)
```tsx
const effects = [
  (o: number) => ({ opacity: o, transform: `translateY(${(1 - o) * 30}px)` }),
  (o: number) => ({ opacity: o, transform: `rotate(${(1 - o) * -5}deg) scale(${0.8 + o * 0.2})` }),
  (o: number) => ({ opacity: o, transform: `translateX(${(1 - o) * -40}px)` }),
];
// Rotate through effects per word for variety
```

### Color grading (post-production polish)
```tsx
// Subtle vignette (edges darken — draws eye to center)
<div style={{
  position: "absolute", inset: 0,
  background: "radial-gradient(ellipse at center, transparent 60%, rgba(0,0,0,0.4) 100%)",
  pointerEvents: "none",
}} />
// Color overlay (warm/cool tint)
<div style={{
  position: "absolute", inset: 0,
  background: `linear-gradient(135deg, rgba(255,140,0,0.08), rgba(0,100,255,0.05))`,
  mixBlendMode: "overlay", pointerEvents: "none",
}} />
```

### Motion rules (summary)
- Always `extrapolateRight: "clamp"` — prevents overshooting past target
- Spring `damping: 8-12` = bouncy, `damping: 15-20` = smooth, `damping: 200+` = linear fade
- Stagger delay: 6-15 frames between items (too fast = chaos, too slow = boring)
- Every scene: enter (10-20 frames) → hold (main content) → exit (10-15 frames)
- One focal point per scene — don't animate everything at once

## 🎬 PRO MOTION MASTERCLASS — frame-level craft from 7 pro tutorials

Distilled from: *Overlapping Keyframes (AE)*, *Apple-Style Motion Graphics
in 20 min (AE)*, *Smooth Camera Movement (AE)*, *Clean Text Animation +
Free Presets (AE)*, *Motion Graphics Reels (Premiere Pro)*, *Clean Motion
Graphics (DaVinci)*, *PC-level Motion on Mobile (Alight Motion)*.

Every timing below is a literal frame number at 30fps — copy exactly, do
not estimate. If a video feels robotic or cheap, it is breaking one of
these 10 laws. Find which one, fix it, re-render.

### LAW #1 — THE OVERLAP CASCADE (the #1 secret in motion design)

Amateurs animate in sequence: A finishes → B starts. Pros overlap: **B
starts when A is ~60% done.** The end of one element's motion hands off
energy to the next — the eye follows one continuous stream instead of
waiting for steps.

```tsx
// Cascade formula: next delay = prev delay + (entrance duration × 0.6)
// Entrance duration D = 30 frames → stagger step ≈ 18 frames
const D = 30;
const delays = layers.map((_, i) => Math.round(i * D * 0.6));
// → [0, 18, 36, 54] — NOT [0, 30, 60, 90]
```

**Hero scene timing sheet (copy literally):**

| Layer      | Starts | Done | Motion                                  |
|------------|--------|------|-----------------------------------------|
| Background | f0     | f45  | slow fade + scale 1.15→1                |
| Headline   | f6     | f48  | Apple triple (LAW #3)                   |
| Sub-line   | f24    | f54  | rise 30px + fade, spring d20            |
| Accent bar | f34    | f52  | width 0→100%, expo-out                  |
| CTA button | f44    | f62  | spring pop d8 st120 m0.8                |

**Exits overlap too** — the incoming scene starts at 50% of the outgoing
exit: scene A exits f0–f15 (scale 1→1.12 + fade), scene B starts entering
at **f7**, not f15.

**Alternate speeds for interest:** snappy element (spring d8) → drifting
element (expo-out 40f) → snappy → drift. A cascade at one constant speed
feels mechanical even with perfect overlap.

### LAW #2 — THE EASING LIBRARY (exact configs, exact use)

| Feel           | Recipe                                  | Use for                          |
|----------------|-----------------------------------------|----------------------------------|
| Bouncy pop     | `spring d:8, stiffness:120, mass:0.8`   | logos, emojis, play buttons      |
| Smooth settle  | `spring d:20, stiffness:100`            | cards, images, device mockups    |
| Silky fade     | `spring d:200`                          | opacity-only changes             |
| Snappy glide   | `Easing.bezier(0.16, 1, 0.3, 1)`        | slides/entrances (expo-out)      |
| Overshoot      | `Easing.bezier(0.34, 1.56, 0.64, 1)`    | scale-in with snapback, no spring|
| Anticipation   | `Easing.bezier(0.68, -0.6, 0.32, 1.6)`  | pull back first, then launch     |
| Camera moves   | `Easing.inOut(Easing.quad)` over 60f+   | pans, pushes, drifts             |

Three rules from the tutorials:
1. **Exit faster than entrance.** Enter over 20–30f, exit over 10–15f
   (Apple pace: enter 30–45f, exit 15–20f). Slow exits feel like lag.
2. **Nothing stops dead.** After an element lands, keep a settle drift
   alive: `Math.sin(frame * 0.04) * 3` px float. Motion that freezes
   completely reads as broken.
3. **Vary curves within a scene.** The same curve everywhere = template
   feel. Mix expo-out drifts with spring pops — that contrast is life.

### LAW #3 — THE APPLE ENTRANCE FORMULA (premium feel)

The Apple keynote look is ONE formula applied with total discipline:

```tsx
// The triple — opacity, scale, blur animate TOGETHER on one spring:
const p = spring({ frame, fps, config: { damping: 15, mass: 1.2 } });
const opacity = p;
const scale = interpolate(p, [0, 1], [1.4, 1]);  // big → settle
const blur  = interpolate(p, [0, 1], [20, 0]);   // out-of-focus → focus
// d15 + m1.2 makes the entrance run ~30–45 frames — Apple pace
```

The discipline around the formula:
- **Pace 30–50% slower than feels natural.** If 20f "looks right", use 30f.
  Confidence = slowness. Rushed = cheap.
- **Near-black or near-white background** (#0A0A0A / #FAFAFA). Huge type:
  headline 140–200px at 1080p, weight 600–700, letterSpacing -0.02em.
- **Fill ≤ 60% of the frame**, content optically centered, huge margins.
  Whitespace IS the design — don't decorate the empty areas.
- **ONE accent color** on less than 10% of pixels. Everything else neutral.
- **Depth:** background layer gets blur(8px) + opacity ~0.4. The focus
  separation reads as a camera lens, not as a decoration.
- **A slow camera push runs under everything** (LAW #5) — Apple frames
  are never still, even when "nothing is moving".

### LAW #4 — KINETIC TYPOGRAPHY ENGINE

**Word stagger: 4–7 frames between words** (12+ is dead — the phrase
loses its rhythm). **Character stagger: 2–3 frames per character**, only
for short punch words (≤ 8 chars).

```tsx
// Word engine — blur-rise per word, 5-frame cascade:
const words = headline.split(" ");
{words.map((w, i) => {
  const p = spring({ frame: frame - i * 5, fps, config: { damping: 14 } });
  return (
    <span key={i} style={{
      display: "inline-block", marginRight: "0.28em",
      opacity: p,
      transform: `translateY(${(1 - p) * 34}px)`,
      filter: `blur(${(1 - p) * 10}px)`,
    }}>{w}</span>
  );
})}
```

Two signature text moves from the AE presets tutorial:

```tsx
// TRACKING SETTLE — title starts letter-spaced wide, tightens into place:
const track = interpolate(frame, [0, 25], [0.3, 0.02], {
  easing: Easing.out(Easing.exp), extrapolateRight: "clamp" });
<h1 style={{ letterSpacing: `${track}em` }}>HEADLINE</h1>

// OVERSHOOT LANDING — pass the target, settle back:
const y = interpolate(frame, [0, 16, 26], [40, -6, 0], {
  easing: Easing.out(Easing.cubic), extrapolateRight: "clamp" });
```

Editorial line-mask reveal (the magazine look from the mobile tutorial):
```tsx
// Each line sits in an overflow:hidden box; the inner text slides up from below
<div style={{ overflow: "hidden" }}>
  <div style={{
    transform: `translateY(${interpolate(frame, [0, 22], [110, 0], {
      easing: Easing.bezier(0.16, 1, 0.3, 1), extrapolateRight: "clamp" })}%)`,
  }}>{line}</div>
</div>
// Stagger lines by 8 frames (LAW #1)
```

Text exit is always quick and soft: 8–10f, scale 1→0.95 + blur 0→8 + fade.

### LAW #5 — THE FAKE CAMERA (a pro frame is never static)

From the camera tutorial: build a "null parent" equivalent — a wrapper
div around every scene that carries camera motion:

```tsx
// 1. PUSH-IN — scale 1→1.08 across the WHOLE scene duration.
//    Per-frame change is invisible; over 10s it adds life.
const push = interpolate(frame, [0, durationInFrames], [1, 1.08]);

// 2. PARALLAX — layers move at different rates (fake depth).
//    Depth factor: background 0.3, midground 0.6, foreground 1.0
const pan = interpolate(frame, [0, durationInFrames], [-40, 40],
  { easing: Easing.inOut(Easing.quad) });
// bg layer:  translateX(pan * 0.3)  + blur(8px)
// fg layer:  translateX(pan * 1.0)  + sharp

// 3. HANDHELD MICRO-SHAKE — deterministic noise (render-stable, never random())
import { noise } from "remotion";
const shakeX  = noise("2d", frame * 0.08, 0) * 1.5;   // px
const shakeR  = noise("2d", 0, frame * 0.08) * 0.1;   // deg

// 4. DIRECTIONAL BLUR on fast moves — a camera whip gets a blur spike:
const whipBlur = interpolate(frame, [0, 3, 6], [0, 16, 0]);  // 6f total
```

Scene wrapper: `<div style={{ transform:
`scale(${push}) translate(${shakeX}px, 0) rotate(${shakeR}deg)` }}>`

**Every scene gets AT LEAST ONE of: push-in, pan, drift, float.**
A perfectly still frame reads as a slide, not a video.

### LAW #6 — REEL STRUCTURE & BEAT SYNC (the Premiere workflow)

Hard frame budgets at 30fps:
- **HOOK f0–f45 (0–1.5s):** the boldest visual FIRST — the claim, the
  hero shot, the number. If nothing impressive happened by f45, the reel
  is dead no matter what comes after.
- **BUILD f45–f180:** one point per beat, cuts land on the music rhythm.
- **PAYOFF f180–end:** CTA, logo pop, end on brand.

**Beat grid math** — sync every cut and punch to the music BPM:
```tsx
// Beat interval in frames = 60 × fps / BPM. 120 BPM @ 30fps → every 15 frames.
const BPM = 120;
const beat = (60 * 30) / BPM;                    // 15
const lastBeat = Math.floor(frame / beat) * beat;

// ZOOM PUNCH-IN that lands ON the beat, then relaxes:
const sinceBeat = frame - lastBeat;
const punch = interpolate(sinceBeat, [0, 3, 18], [0.05, 0.05, 0], {
  extrapolateRight: "clamp", easing: Easing.out(Easing.cubic) });
<div style={{ transform: `scale(${1 + punch})` }}>{scene}</div>
```

**Speed ramping** on video clips (the Premiere time-remap equivalent;
needs `npm i @remotion/videos`):
```tsx
import { OffthreadVideo } from "@remotion/videos";
<OffthreadVideo
  src={staticFile("clip.mp4")}
  playbackRate={(f) => (f < 30 ? 2 : f < 75 ? 0.4 : 1)}  // fast → slow-mo → normal
/>
```

**Cut on action:** cut while something is MOVING (mid-pan, mid-rise,
mid-rotation). The motion bridges the cut and the two shots read as one
continuous flow.

### LAW #7 — THE TRANSITION LIBRARY (6 styles + the half-overlap rule)

**Rule: the incoming scene starts at 50% of the outgoing exit** — LAW #1
applied to scenes. Outgoing exits over 15f → incoming enters from f7.

| # | Style          | Frames | Essentials                                                            |
|---|----------------|--------|-----------------------------------------------------------------------|
| 1 | Zoom crossfade | 18–20  | old: scale 1→1.15 + fade; new: scale 0.95→1 + fade; `inOut(cubic)`     |
| 2 | Slide overlap  | 12–15  | new slides from +100% X with `out(exp)`; old shifts −15% X            |
| 3 | Blur cut       | 10–12  | old: blur 0→20 + fade; new enters from blur(20)→0 (Apple dreamy)      |
| 4 | Mask wipe      | 18     | brand-color bar sweeps L→R (`inOut(quad)`), new scene behind it       |
| 5 | Scale pop      | spring | new pops `d:10, st:100`; old quick-fades over 8f                      |
| 6 | Whip pan       | 6      | both scenes translateX ±300px + blur spike 0→16→0, hard cut at f3     |

```tsx
// Mask wipe (the clean "professional" one):
const wipe = interpolate(frame, [0, 18], [-35, 130], {
  easing: Easing.inOut(Easing.quad), extrapolateRight: "clamp" });
<>
  <div style={{ position: "absolute", inset: 0 }}>{newScene}</div>
  <div style={{ position: "absolute", top: 0, bottom: 0,
    left: `${wipe}%`, width: "35%", background: brandColor }} />
</>
```

### LAW #8 — BACKGROUND SYSTEMS (pick one per video, never static)

1. **Rotating gradient:** angle 135°→200° across the whole video
   (~2°/second — felt, not seen).
2. **Floating shapes:** `Math.sin((frame + i * 40) * 0.02) * 20` px float,
   rotation `frame * (0.2 + i * 0.1)` deg, **opacity ≤ 0.06** — shapes are
   whispered, never shouted.
3. **Particle field:** 30 dots, golden-angle seed `i * 137.5`, opacity
   pulsing 0.03–0.12 via `Math.sin(frame * 0.03 + i)`.
4. **Grid drift + glow orb:** faint 1px grid translating −0.5px/frame +
   one 900px radial-gradient orb (brand color at 8%) drifting slowly —
   the modern SaaS/product look.

Background layers always get the LAW #5 parallax treatment: depth factor
0.3 + blur(8px).

### LAW #9 — EDITORIAL LAYOUT (from the mobile pro tutorial)

- 12-column mental grid; **96px side margins** at 1080p; 8px baseline
  spacing system — alignment consistency is what reads "designed".
- **Monochrome + ONE accent:** near-black bg, white text, one brand color.
- **Device mockup fly-in:** translateY 120px→0 on spring `d:16`, with the
  shadow animating `0 0 0 rgba(0,0,0,0)` → `0 30px 60px rgba(0,0,0,0.45)`
  in sync — the growing shadow sells the "landing".

### LAW #10 — THE GRADE CHAIN (post polish — order matters)

Add as the LAST layers of the top-level composition (all in one wrapper,
zIndex 100+, pointerEvents "none"):

1. **Vignette** — `radial-gradient(ellipse at center, transparent 55%, rgba(0,0,0,0.35) 100%)`
2. **Grain** — SVG feTurbulence data-URI at opacity 0.03 — kills the
   "too digital" flatness of pure CSS color
3. **Tint** — warm `rgba(255,140,0,0.05)` or cool `rgba(0,100,255,0.04)`
   with `mixBlendMode: "overlay"` — sets mood in one layer
4. **Letterbox (optional cinema)** — 2.39:1 → ~140px black bars top+bottom

```tsx
const GRAIN = `url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='4'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.03'/%3E%3C/svg%3E")`;
```

### REFERENCE SCENE — every law in one annotated component

```tsx
import { useCurrentFrame, useVideoConfig, spring, interpolate, Easing, noise } from "remotion";

export const HeroScene: React.FC<{ headline: string; sub: string; brand: string }> =
({ headline, sub, brand }) => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames } = useVideoConfig();

  // LAW #5 — camera wrapper: push + handheld micro-shake
  const push = interpolate(frame, [0, durationInFrames], [1, 1.08]);
  const shakeX = noise("2d", frame * 0.08, 0) * 1.5;
  const shakeR = noise("2d", 0, frame * 0.08) * 0.1;

  // LAW #1 — overlap cascade timings (each start ≈ 60% into the previous)
  const tHead = 6, tSub = 24, tBar = 34, tCta = 44;

  // LAW #3 — Apple triple for the headline block
  const hp = spring({ frame: frame - tHead, fps, config: { damping: 15, mass: 1.2 } });
  const hBlur = interpolate(hp, [0, 1], [20, 0]);
  const hScale = interpolate(hp, [0, 1], [1.4, 1]);

  // LAW #2 — settle drift: after landing, keep floating ±3px forever
  const floatY = Math.sin(frame * 0.04) * 3 *
    interpolate(frame, [50, 65], [0, 1],
      { extrapolateLeft: "clamp", extrapolateRight: "clamp" });

  // LAW #4 — word engine inside the headline (5-frame cascade)
  const words = headline.split(" ");

  const subP = spring({ frame: frame - tSub, fps, config: { damping: 20 } });
  const barW = interpolate(frame, [tBar, tBar + 18], [0, 100],
    { easing: Easing.bezier(0.16, 1, 0.3, 1), extrapolateRight: "clamp" });
  const ctaP = spring({ frame: frame - tCta, fps,
    config: { damping: 8, stiffness: 120, mass: 0.8 } });

  return (
    <div style={{ position: "absolute", inset: 0, background: "#0A0A0A",
      transform: `scale(${push}) translate(${shakeX}px, 0) rotate(${shakeR}deg)` }}>
      {/* LAW #8 — glow orb bg, parallax 0.3 + blur */}
      <div style={{ position: "absolute", width: 900, height: 900, borderRadius: "50%",
        background: `radial-gradient(circle, ${brand}14, transparent 70%)`,
        left: "55%", top: "-20%", filter: "blur(8px)",
        transform: `translateX(${interpolate(frame, [0, durationInFrames], [0, -25])}px)` }} />

      <div style={{ position: "absolute", inset: 0, display: "flex",
        flexDirection: "column", alignItems: "center", justifyContent: "center",
        gap: 28, transform: `translateY(${floatY}px)` }}>
        <h1 style={{ opacity: hp, transform: `scale(${hScale})`,
          filter: `blur(${hBlur}px)`, margin: 0, color: "#FAFAFA",
          fontSize: 150, fontWeight: 700, letterSpacing: "-0.02em", textAlign: "center" }}>
          {words.map((w, i) => {
            const p = spring({ frame: frame - tHead - i * 5, fps, config: { damping: 14 } });
            return <span key={i} style={{ display: "inline-block", marginRight: "0.28em",
              opacity: p, transform: `translateY(${(1 - p) * 34}px)`,
              filter: `blur(${(1 - p) * 10}px)` }}>{w}</span>;
          })}
        </h1>
        <div style={{ height: 6, width: `${barW}%`, maxWidth: 320,
          background: brand, borderRadius: 3 }} />
        <p style={{ opacity: subP, transform: `translateY(${(1 - subP) * 30}px)`,
          margin: 0, color: "#A0A0A0", fontSize: 44, fontWeight: 500 }}>{sub}</p>
        <div style={{ opacity: ctaP, transform: `scale(${0.6 + ctaP * 0.4})`,
          background: brand, color: "#0A0A0A", padding: "22px 56px",
          borderRadius: 999, fontSize: 34, fontWeight: 700 }}>Get started</div>
      </div>
    </div>
  );
};
```

### AI VIDEO HYBRID WORKFLOW (photoreal footage + Remotion polish)

Remotion cannot generate photoreal people/places; AI video generators
cannot do precise typography, beat-perfect timing, or branding. Combine:

1. **Storyboard** into scenes (hook/build/payoff budgets from LAW #6).
2. **You write one shot prompt per scene** with this template:

   > `[SHOT TYPE] of [SUBJECT + ACTION], [CAMERA MOVE], [LIGHTING],
   > [STYLE + GRADE], [MOOD], [DURATION]`

   Example: *"Slow dolly-in medium shot of a steaming coffee cup on a
   marble counter, soft morning window light from the left, warm cinematic
   color grade, shallow depth of field, 35mm film look, calm premium mood,
   4 seconds."*

   Prompt rules: ONE camera move per shot, ONE subject per shot, always
   state the lighting, keep clips 3–5s (short clips cut together better),
   and reuse the same style keywords in EVERY prompt so the clips match
   each other.

3. **User generates** the clips (Seedance / Kling / Higgsfield / Veo) and
   drops the files into the project's `public/` folder.
4. **You compose in Remotion** — clips + everything in this skill:
```tsx
import { OffthreadVideo } from "@remotion/videos";  // npm i @remotion/videos
<Sequence from={0} durationInFrames={105}>
  <OffthreadVideo src={staticFile("hook.mp4")}
    style={{ width: "100%", height: "100%", objectFit: "cover" }} />
</Sequence>
// then: transitions (LAW #7), beat-synced cuts (LAW #6), text overlays,
// and the grade chain over everything (LAW #10)
```
   Trim clips with `startFrom` / `endAt`; slow-mo with `playbackRate`.
   Text over footage needs `textShadow: "0 2px 12px rgba(0,0,0,0.6)"`.
5. **Iterate:** new prompt → new clip → swap the file → re-render. The
   clips are raw material; the editing, timing, type and polish live in
   Remotion — that combination is stronger than either tool alone.

### PRE-RENDER CHECKLIST (run before every push)

1. ⬜ ≥ 10s / 300 frames, ≥ 3 scenes with distinct beats
2. ⬜ Every entrance overlaps the previous at ~60% (LAW #1)
3. ⬜ No linear easing anywhere — springs or bezier curves only (LAW #2)
4. ⬜ Exits faster than entrances; nothing stops dead — settle drift on landed elements (LAW #2)
5. ⬜ Headlines: word-stagger 4–7f, 140–200px, tight tracking (LAW #4)
6. ⬜ Every scene has camera life: push / pan / shake / float (LAW #5)
7. ⬜ The hook lands in the first 45 frames (LAW #6)
8. ⬜ Background never static; shape opacity ≤ 0.06 (LAW #8)
9. ⬜ Grade chain present as top layer: vignette + grain + tint (LAW #10)
10. ⬜ Every `interpolate` has `extrapolateRight: "clamp"` (and left too where frames go negative)
11. ⬜ One focal point per moment; ≤ 60% of the frame filled (LAW #3)
12. ⬜ 90-frame preview rendered and checked BEFORE the full render
