---
name: web2video
description: Turn any idea into a motion graphic VIDEO (MP4) — zyvo builds a beautiful animated web page (design-standards quality: art direction, palette, motion craft), then GitHub Actions captures it frame-perfectly into a smooth video with configurable FPS (30/60/120). The user's phone does nothing. Use when the user asks for a motion graphic, animated video, promo video, intro video, or says "video banao".
---

# Web to Video (motion graphic factory)

You build the animation as a web page (HTML/CSS/JS — total design
freedom: crisp text, gradients, shapes, kinetic type), then GitHub
Actions captures it frame-by-frame with a headless browser into a
buttery MP4. The phone writes nothing heavy, renders nothing.

## Autonomous flow (the default)

Ask ONCE for: topic + any must-have text/brand color + duration (default
30s) + FPS (default 60; offer 120 for ultra-smooth/slow-mo). Everything
else you decide and execute without intermediate questions:

1. Design brief per design-standards (mood, palette, fonts, motion plan).
2. Build the animated page — drive animations by ELAPSED TIME so capture
   is deterministic (virtual-time friendly). The page must end cleanly at
   the duration mark (loop or final frame).
3. Push with the capture workflow (below). Watch the run via the API.
4. If capture fails: read the log, fix, retry (up to 3, silently).
5. Deliver ONE final message: what you made + the MP4 link + how to
   request changes. Never ask mid-task questions.

## The capture engine (GitHub Actions)

`.github/workflows/capture.yml`:
```yaml
name: Capture video
on:
  push:
    branches: [main]
jobs:
  capture:
    runs-on: ubuntu-latest
    timeout-minutes: 90
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm install puppeteer
      - run: npm install -g timecut
      - name: Capture page to video
        run: |
          PAGE_URL="file://$(pwd)/index.html"
          npx timecut "$PAGE_URL" \
            --viewport=1920,1080 \
            --fps=${FPS:-60} \
            --duration=${DURATION:-30} \
            --output=out/video.mp4
        env:
          FPS: "60"
          DURATION: "30"
      - uses: actions/upload-artifact@v4
        with: { name: video, path: out/video.mp4 }
      - name: Attach to release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: video-${{ github.run_number }}
          files: out/video.mp4
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Why timecut: it renders each frame at its EXACT virtual timestamp
(deterministic), so 120fps capture is frame-perfect — no dropped frames,
no blur, no dependence on the runner's speed.

## FPS guidance

- 60fps: the sweet spot for motion graphics — smooth, fast render.
- 120fps: for fast motion or when the user wants slow-mo ability later
  (120 → 30 = 4x clean slow-mo). Doubles capture/render time.
- 24fps: only if the user wants a filmic look.

## Design rules

Follow design-standards fully: art direction first, forbidden-list,
palette from the subject, typography with personality, real copy. Motion:
entrance choreography with stagger, cubic-bezier(0.16, 1, 0.3, 1),
animate transform/opacity only. The page should feel ALIVE from frame 1 —
nothing static for more than ~2 seconds.

## Beginner-friendly delivery

The user may be a complete beginner. In your final message:
- Say what you made in one simple line (Banglish if they speak it)
- Give the download link
- Offer: "change korte chaile bolo — likha, rong, songit jekono jinis"
- Never use jargon without explaining it

## Pitfalls

- Puppeteer needs its Chrome on the runner: `npm install puppeteer`
  downloads it — don't skip.
- Deterministic capture: animations driven by elapsed time (not wall
  clock, not scroll) — otherwise frames drift.
- Keep all assets inline or in the repo (no CDN at render time).
- File URLs: pass `file://` + absolute path to timecut.
- Audio is NOT captured from pages (silent video) — if the user wants
  sound, add it later in an editor or use Remotion.
