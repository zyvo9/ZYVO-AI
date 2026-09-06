---
name: remotion
description: Make motion graphic VIDEOS (MP4) — write Remotion compositions and render them on GitHub Actions, not on the phone. Promos, intros, explainers, animated text/charts/logos with springs and interpolation. Use when the user asks for a video, promo, intro, animation video, or motion graphics ("video banao", "promo lagbe").
---

# Motion Video Factory (Remotion + GitHub Actions)

Make real MP4 videos programmatically. You write React/TypeScript
compositions (Remotion), push them to a repo, and GitHub Actions renders
the MP4 in the cloud. The user's phone does nothing heavy.

## Golden rules

1. The phone NEVER renders video — rendering happens on GitHub Actions
   (free for public repos, ~3-5 min for a 30s 1080p video).
2. Every animation must follow the motion craft rules: animate only
   transform/opacity, spring/interpolate for motion, sequences for scenes,
   tasteful easing, respect reduced motion.
3. Design follows the brand: ask the user for topic, colors, text content.
   Match the palette to the subject (see the webdev skill's design system).
4. 30fps, 1920x1080 default. Keep videos 15-60s unless asked otherwise.

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
