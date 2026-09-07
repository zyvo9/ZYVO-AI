---
name: webdev
description: Build professional, distinctive websites/web apps and deploy them LIVE on GitHub Pages — art direction first, real motion craft, no generic AI look. Zero load on the user's phone. Use when the user asks to create/build a website, landing page, portfolio, web app, or says "website banao".
---

# Website Builder Pro (GitHub Pages)

Build websites that look like a HUMAN DESIGNER made them — not AI. You
write the files, push to GitHub, enable Pages, and hand over a LIVE URL.
The phone only writes text files.

## Golden rules

1. The phone NEVER builds anything — all hosting/building is GitHub's.
2. NEVER ship the generic AI look (see The Anti-AI-Look Doctrine — it is
   the most important section of this skill).
3. The site MUST be responsive (mobile-first — the user is on a phone).
4. Default to a **single self-contained index.html** (inline CSS + JS).
   Split files only when the site truly needs it.
5. Sources live in `$HOME/<sitename>` — never in shared storage.
6. NEVER put the user's GitHub token inside any committed file.

## THE ANTI-AI-LOOK DOCTRINE

The generic AI site is instantly recognizable: blue-purple gradient,
rounded-3xl card grid in perfect 3 columns, Inter font, emoji in the hero,
centered everything, lorem ipsum. FORBIDDEN. Instead:

### 1. Art direction FIRST — before writing any code
Choose, and state to the user, three words for the MOOD (e.g. "warm,
handcrafted, bold" for a bakery; "precise, technical, calm" for a dev
tool). Every color/type/layout decision must serve those words. Two
different projects must never end up with the same palette + layout.

### 2. Color: derive, don't decorate
- Derive the palette from the SUBJECT (a coffee site: espresso browns,
  cream, burnt orange — never tech-blue).
- One dominant + one accent + neutrals. Use a real palette tool's logic:
  60/30/10 distribution. Avoid pure #3B82F6/#8B5CF6 gradients.
- Dark mode only if it fits the mood — light sites are NOT worse.

### 3. Typography: personality, not defaults
- NEVER Inter/Roboto/system-ui as the identity font. Use Google Fonts
  pairings with character: Fraunces + Space Grotesk, Playfair Display +
  Inter (Inter OK as body only), Bebas Neue + Manrope, DM Serif + DM Sans.
- Oversized display type (clamp(3rem, 8vw, 7rem)) is the fastest way to
  look designed. Tight letter-spacing on headlines, generous line-height
  on body.

### 4. Layout: break the grid
- Vary the layout per project: editorial asymmetry, split-screen, oversized
  sidebar, bento grid with MIXED sizes, full-bleed imagery sections.
- Uniform 3-column card rows are forbidden — vary card sizes, offset rows,
  overlap elements, use whitespace deliberately.
- Real spacing system: consistent scale (4/8/16/24/48/96px), lots of
  intentional whitespace.

### 5. Content: real, specific, alive
- Write REAL copy for the topic (no lorem ipsum, no "Your text here").
- Real images: picsum.photos with fixed seeds (https://picsum.photos/seed/<word>/800/600)
  or hand-made SVG shapes/patterns. No generic stock feel.
- Microcopy with personality (button labels like "Start brewing", not "Submit").

### 6. Self-check before pushing
Re-read your page and ask: "Would a senior designer ship this? Can I tell
which AI made it from a screenshot?" If any section looks templated, redo
it with a different layout/palette. This loop is mandatory.

## MOTION CRAFT (what separates pro from AI)

Principles from professional web animation practice:

- **Performance law:** animate ONLY `transform` and `opacity` (never
  top/left/width/height) — keeps 60fps on phones.
- **Entrance choreography:** elements reveal in a stagger (50–100ms apart),
  not all at once. Hero first, then supporting items.
- **Easing:** never the default `ease`. Entrances: `cubic-bezier(0.16, 1, 0.3, 1)`
  (decisive, settles softly). Exits: faster easing, shorter duration.
- **Durations:** UI feedback 150–300ms, content reveals 400–700ms, hero
  600–900ms. Anything over 1s feels sluggish.
- **Micro-interactions:** buttons lift on hover (translateY(-2px) + shadow),
  compress on press (scale 0.97), inputs glow on focus. Every interactive
  element must respond.
- **Scroll reveals:** IntersectionObserver, once per element, subtle
  (translateY 24px → 0 + fade).
- **Tiered reduced motion:** respect `prefers-reduced-motion: reduce` by
  keeping short fades and dropping large movements — degrade gracefully,
  don't remove everything.
- **Restraint:** motion serves hierarchy and feedback. If it doesn't help,
  cut it.

## Autonomous delivery (the default flow)

Be fully autonomous: collect missing info ONCE at the start (site
purpose, GitHub username + token), then decide everything else yourself
— design direction, palette, fonts, copy, structure, Pages setup. The
ONLY intentional interaction is the UI preview gate (Step 1.5): show 2-3
design directions in Chrome, user picks a number, you build the winner.
Never ask other intermediate questions. Deliver ONE final message: the
art direction the user picked + the LIVE URL + one line on how to
request changes.

## Requirements checklist (do this first)

- `git` installed: `pkg install -y git`
- User has a GitHub account
- User has a **Personal Access Token** with `repo` scope. Give them this
  DIRECT link (lands on token creation with the scope pre-checked):
  https://github.com/settings/tokens/new?scopes=repo,workflow,delete_repo,admin%3Arepo_hook,admin%3Aorg,admin%3Apublic_key,admin%3Agpg_key,notifications,project,user,gist,audit_log&description=Zyvo%20website
  They click "Generate token" and paste it to you immediately (shown once).
- Site topic/purpose and rough content from the user.
- State the ART DIRECTION (mood, palette, fonts, layout concept) to the
  user before coding — they can steer.

## Step 1 — Design pass

1. Read `references/ui-ideas.md` (same folder as this skill) — especially
   §13 WEBSITE STYLE DIRECTIONS (9 complete personalities: dark editorial,
   luxury cream serif, magazine, bento grid, soft 3D, brutalist, minimal
   luxury, dark glass tech...) and §12 palettes. Pick 2-3 candidates that
   fit the subject's mood.
2. Mood in 3 words → palette (60/30/10) → font pairing → layout concept,
   per the Anti-AI-Look Doctrine.
3. Fetch references with WebFetch if the app type is unfamiliar
   (https://m3.material.io, design showcases).

## Step 1.5 — UI PREVIEW GATE (always — the user picks the design)

NEVER build the site on the first design you imagine. The gate:

1. **Mock up the 2-3 candidate directions** from Step 1 as one
   self-contained HTML page: each direction = a mini hero + one content
   section (real copy, real picsum images, real fonts), stacked with big
   number badges ① ② ③, name + 3-word mood label above each. All inline
   CSS; only Google Fonts external. Save as `ui-preview.html` in the
   project folder.
2. **Serve it on localhost and open in Chrome** (file:// links are
   blocked by Chrome on modern Android — always use localhost):
   ```bash
   command -v python >/dev/null || pkg install -y python
   cd "$HOME/<sitename>"
   # free the port if a previous preview server is still running
   pkill -f "http.server 8484" 2>/dev/null
   nohup python -m http.server 8484 --bind 127.0.0.1 >/dev/null 2>&1 &
   sleep 1
   termux-open-url "http://127.0.0.1:8484/ui-preview.html" 2>/dev/null \
     || am start -a android.intent.action.VIEW \
          -d "http://127.0.0.1:8484/ui-preview.html"
   ```
   The server stays up — the user can refresh or reopen the URL anytime.
   Serve the real site from the same server during iteration too.
4. **Tell the user**: "Chrome-এ ২-৩টা design খুলেছি — কোন নম্বরটা পছন্দ?
   (মিশ্রও যায়: '২ এর layout + ১ এর রঙ')" — then WAIT for the pick.
   This is the ONE intentional interaction point; everything else stays
   autonomous.
5. Build the full site with the chosen (or mixed) direction only. The
   winner's exact mockup CSS becomes the seed of the real stylesheet.

## Step 2 — Scaffold

Write under `$HOME/<sitename>/`:
- `index.html` — complete, polished, content-filled, following the
  doctrine + motion craft
- `.nojekyll` — EMPTY file (skips Jekyll processing)
- extra files only when truly needed

## Step 3 — Push to GitHub

1. Create the repo with the user's token:
```
curl -s -X POST -H "Authorization: token <TOKEN>" \
  -d '{"name":"<repo>","private":false}' https://api.github.com/user/repos
```
2. Then:
```
cd $HOME/<sitename>
git init -b main
git config user.name "<username>"
git config user.email "<username>@users.noreply.github.com"
git add -A && git commit -m "zyvo: initial site"
git remote add origin "https://<TOKEN>@github.com/<user>/<repo>.git"
git push -u origin main
```
3. Enable Pages:
```
curl -s -X POST -H "Authorization: token <TOKEN>" \
  -H "Accept: application/vnd.github+json" \
  -d '{"source":{"branch":"main","path":"/"}}' \
  https://api.github.com/repos/<user>/<repo>/pages
```
4. Live URL: `https://<user>.github.io/<repo>/` — verify:
```
curl -s -o /dev/null -w "%{http_code}" https://<user>.github.io/<repo>/
```
   (200 = LIVE. Give the user this URL.)

## Step 4 — Iterate

Changes: edit → commit → push → live in ~1 minute. Tell the user this.

## Pitfalls

- Missing `.nojekyll` → Jekyll mangles files starting with `_`.
- Pages first build: wait 1–2 min before testing.
- Never commit the token; never echo it.
- Repo must be PUBLIC for free Pages on personal accounts.
- Google Fonts via <link> is fine; don't inline base64 fonts.
- If Pages enable returns 404, re-check the token's repo scope.


## PRO UPGRADE PACK (meta, SEO, accessibility, performance)

### Head template (always include, fill real values)
```html
<meta name="description" content="<one real sentence about the site>">
<meta property="og:title" content="<page title>">
<meta property="og:description" content="<one real sentence>">
<meta property="og:image" content="https://picsum.photos/seed/<sitename>/1200/630">
<meta name="theme-color" content="<primary color hex>">
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'><emoji or letter></text></svg>">
```
Emoji favicon: pick one emoji that represents the site — instant branded
tab icon with zero image files.

### Accessibility checklist (every site)
- Every image: alt text (describes the content, not "image")
- Body text contrast ≥ 4.5:1 against its background
- Every interactive element reachable by Tab, visible focus ring
- Icon-only buttons: aria-label
- Form inputs: real <label for> connections

### Performance rules (phones are the target)
- Images: loading="lazy" + width/height set (no layout shift)
- No frameworks/libraries for static sites — vanilla HTML/CSS/JS
- CSS: system-ui fallbacks in every font stack
- Total page weight target: under 500KB for a landing page

### States most sites forget (design ALL three)
- Empty state: what the user sees with no data (friendly, with a next step)
- Loading: skeleton or spinner — never a blank screen
- Error: clear message + what to do next
