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
3. A build that succeeds with BAD design is a FAILED build: the Web
   Design System + Page Recipes + QA checklist below are not optional —
   run the checklist before every push.
4. The site MUST be responsive (mobile-first — the user is on a phone).
5. Default to a **single self-contained index.html** (inline CSS + JS).
   Split files only when the site truly needs it.
6. Sources live in `$HOME/<sitename>` — never in shared storage.
7. NEVER put the user's GitHub token inside any committed file.

## 🏗️ THE BUILD PIPELINE (professional 22-stage process — follow IN ORDER)

EVERY full website project runs this pipeline. Professional sites are not
"write code" — they are idea → PRD → design → build → test → deploy → monitor.
Weak moments (compaction, long session)? Re-read PROJECT_PLAN.md + PRD.md and
continue from the next unticked stage.

**BOOT (the very first message of any website project):**
0. **SPEED vs CRAFT — জিজ্ঞেস BINDING (একটা লাইন কোড লেখার আগেই, এক বার্তায়):**
   "আপনি কোনটা চান? ① জলদি ভার্সন — ২-৫ মিনিটে সহজ-সৎ, বেসিক পলিশ ·
   ② ADVANCE সুন্দর ভার্সন — ৫০-৬০ মিনিট, পুরো ডিজাইন প্রসেস + নিজে
   ব্রাউজারে A-Z টেস্ট + পলিশ রাউন্ড।" এই প্রশ্ন ছাড়া কোনো বিল্ড শুরু নয়।
   User "tumi bolo" বললে নিজে ঠিক করে জানাও: real/multi-page site = ADVANCE,
   ছোট demo/দ্রুত এডিট = জলদি। উত্তরটা প্রজেক্টের MEMORY নোটে সাথে রাখো।
1. ASK the user (ONE message, numbered, max 6 questions): website ta ki kore ·
   target user ke · main features · kon kon pages · login/payment/database
   lagbe kina · style system + color mood (clay/glass/skeuo/neu/default —
   sob dharone nibe).
2. Save the project to MEMORY by name: "Project <name> — <one-line what>".
3. Create TWO files in the project folder:
   - **PROJECT_PLAN.md** — the master TODO: every stage below, one line each,
     unticked checkbox. Tick each stage the moment it is done.
   - **PRD.md** — the product requirements document (stage 4 output).

**TWO TRACKS (BOOT-এর উত্তর ঠিক করে কোন track — একবার ঠিক হলে মাঝে বদলাবে না):**
- **জলদি track (২-৫ মিনিট):** mini-PRD বাদ → একটা design direction নিজে বাছাই
  → build → দুই রকম quick self-test (মোবাইল view + সব বাটন একবার) → জমা।
  ছোট কাজ/দ্রুত দেখার জন্য — বড় real site-এ এই track নয়।
- **ADVANCE track (৫০-৬০ মিনিট):** নিচের পুরো ২২-স্টেজ pipeline + **SELF-VERIFY
  GATE (A-Z)** + **POLISH PASS** + CUSTOMIZATION ROUND। User যা-ই বলুক,
  মাঝপথে রাশ করে "শেষ" করা **কখনো নয়** — রাশ করা মানে আধা-ভাঙা জিনিস জমা দেওয়া।

**THE STAGES (tick off in PROJECT_PLAN.md, one at a time):**
1. Idea Discovery — problem? whose problem? why will people use it? existing
   solutions? why is ours better?
2. User Research — target user, what they want, pain points, user journey,
   which features are truly needed
3. Requirements — must-have / should-have / nice-to-have / future / constraints
4. **PRD.md** — the full product blueprint, write ALL sections:
   product vision · goals · target users · user stories · features ·
   functional requirements · non-functional requirements · user flows ·
   edge cases · success metrics · out of scope
5. PRD Review — check yourself: anything missing? any contradictions? is
   each feature actually feasible? does it solve the user's REAL problem?
   Then validate WITH the user: one short message — PRD summary + the open
   questions — and only build after their OK
6. User Flow — landing → signup → dashboard → core action → save/share —
   define what the user does at every step
7. UX — wireframe, information architecture, navigation, empty/loading/error
   states, mobile UX
8. UI Design System — colors, fonts, spacing, radius, shadows, buttons,
   inputs, cards, icons, components (use the style system the user chose)
9. Technical Spec — stack, architecture, DB schema, API design, auth, file
   structure, third-party services, security requirements
10. Build Plan — milestones: PRD → architecture → design system → page
    structure → components → features → backend → integration
11. Implementation — frontend → backend → database → APIs → integrations
    (run the UI PREVIEW GATE right after the first homepage)
12. Testing — unit/integration/E2E where the project has tests, forms, auth,
    edge cases. **Web UI হলে SELF-VERIFY GATE (A-Z) এখানেই — নিজে
    ব্রাউজারে পুরো site টেস্ট + POLISH PASS, ব্যতিক্রম নেই**
13. Responsive — mobile, tablet, laptop, desktop, large screen
14. Security — auth, authorization, input validation, API security, secrets
    in env vars, DB permissions, rate limiting
15. Performance — load speed, images, bundle size, API response, DB queries,
    caching, lazy loading
16. Accessibility — keyboard, screen reader, contrast, labels, focus states,
    semantic HTML
17. SEO — metadata, titles, descriptions, sitemap, robots, Open Graph
18. User Acceptance — give the user a REAL task ("make an account and create
    a project"); watch where they get stuck, what they miss
19. Iterate — build → user test → feedback → fix → repeat (many cycles OK)
19b. CUSTOMIZATION ROUND (MANDATORY — never deploy without it): site tested
    and working? STOP. Ask the user (one message): "Site ready — ki ki
    customize korte chao?" with numbered options: color/text change ·
    section tweak · add/remove feature · layout · animations · content edit ·
    anything else. Iterate FULLY — user khusi na howa porjonto kono tarahora
    na. THEN find a free deploy server that fits and walk the user through
    it: static site → GitHub Pages / Netlify (free) · full-stack → Vercel /
    Render (free tier) — account, repo connect, env vars, sob step-e help.
    Deploy ONLY when the user explicitly says yes.
20. Pre-Launch checklist — features ✓ no critical bugs ✓ responsive ✓
    security ✓ performance ✓ accessibility ✓ SEO ✓ error handling ✓
    analytics ✓ legal pages ✓ backup ✓
21. Deploy — push → CI/CD → hosting → env vars → domain → SSL → production
22. Post-Launch — analytics, error monitoring, user feedback → measure →
    learn → improve → release

**RULES:**
- ONE stage at a time. Tick it in PROJECT_PLAN.md before starting the next.
- User touchpoints: boot questions, PRD validation, UI preview gate, UAT,
  CUSTOMIZATION ROUND (before any deploy). Everything in between = fully
  autonomous, no interruptions.
- After compaction: re-read PROJECT_PLAN.md + PRD.md → continue the next
  unticked stage. NEVER ask what the project was.
- Small sites (single landing page) may compress stages 1-9 into a mini-PRD
  in PROJECT_PLAN.md — but stages 10-22 ALWAYS run.
- Also keep TRD (tech spec), design spec, API spec, DB schema, test plan and
  Definition of Done as small files when the project is big enough to need
  them — controlled, professional vibe-coding.

## THE ANTI-AI-LOOK DOCTRINE

The generic AI site is instantly recognizable: blue-purple gradient,
rounded-3xl card grid in perfect 3 columns, Inter font, emoji in the hero,
centered everything, lorem ipsum. FORBIDDEN. Instead:

### 1. Art direction FIRST — before writing any code
Choose, and state to the user, three words for the MOOD (e.g. "warm,
handcrafted, bold" for a bakery; "precise, technical, calm" for a dev
tool). Every color/type/layout decision must serve those words. Two
different projects must never end up with the same palette + layout.
Then ground the choices in data with the Design Intelligence Engine
(below) — your 3 mood words still have the final say.

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

## 🧠 DESIGN INTELLIGENCE ENGINE (ui-ux-pro-max — search, don't guess)

A searchable local catalog ships INSIDE this skill at
`$HOME/.config/zyvo/skills/webdev/references/ui-ux-pro-max/` — 192 industry
palette + reasoning profiles, 79 UI styles, 74 font pairings, 119 UX
guidelines, 34 landing-page patterns, 25 chart types, 22 stacks. Pure
Python 3 (stdlib only, works on Termux).

After choosing the 3 mood words, run 2-3 searches to ground your
palette/typography/pattern choices in real data (query by product type:
"a coffee shop landing page", "saas pricing page"):

```bash
ENGINE="$HOME/.config/zyvo/skills/webdev/references/ui-ux-pro-max/scripts/search.py"
python "$ENGINE" "<query>" --domain product      # industry palettes + reasoning
python "$ENGINE" "<query>" --domain style        # UI style match
python "$ENGINE" "<query>" --domain typography   # font pairings
```
Domains: `product`, `style`, `typography`, `ux` (guidelines), `landing`
(page patterns), `color`, `chart`, `stack`. If `python` is missing, try
`python3`.

Engine = EVIDENCE, mood words = IDENTITY. THE ANTI-AI-LOOK DOCTRINE
ALWAYS WINS: if the engine suggests Inter as the identity font, a
tech-blue gradient, or a uniform 3-column card grid — ignore that
suggestion and follow the Doctrine instead.

## 🧩 COMPONENT EVIDENCE — real components, not imagination

Before building a hero, pricing section, dashboard, form or feature
grid, look at 2-3 real components of that type. Free & unlimited:
the shadcn/ui + MagicUI public registries — no key, no limit, just curl:

```bash
# discover what exists (list of registry items)
curl -fsSL "https://ui.shadcn.com/r/index.json" | head -c 2000
# one component's full source (structure + tailwind classes)
curl -fsSL "https://ui.shadcn.com/r/styles/new-york-v4/<name>.json"
# animated components (marquee, particles, animated-beam…)
curl -fsSL "https://magicui.design/r/<name>.json"
```
Study the JSON's layout/spacing/hierarchy as PATTERN EVIDENCE, then
port the STRUCTURE into the single-file HTML build (Tailwind CDN) —
in your own style, never verbatim. The ANTI-AI-LOOK DOCTRINE wins over
every component source: a generic component (Inter identity, tech-blue
gradient, uniform 3-column cards) is rejected no matter how popular
it is.

## 🌟 SIGNATURE STYLE SYSTEMS (clay · glass · skeuomorphism · neumorphism)

Four full-page style systems with proven recipes. When the user names one
("clay ui banao", "glassmorphism style", "3d soft look", "real object ui")
— build the ENTIRE site in that system: tokens, cards, buttons, inputs all
follow it. These OVERRIDE the WEB DESIGN SYSTEM tokens for the chosen style.
The ANTI-AI-LOOK DOCTRINE still applies (readability first, no neon soup).
Proven live in the Zyvo Admin Panel (clay, milk + orange).

**THE 3-SHADOW LAW (morphism ভুল বানানো নিষিদ্ধ):** morphism-এর 3D feel আসে
**শ্যাডোর স্তর** থেকে — একটা box-shadow দিয়ে করা morphism = flat, ভাঙা, FAKE।
এটাই আগের বার ভুল হচ্ছিল। প্রতিটা card/button/box-এ ন্যূনতম এই ৩টা স্তর একসাথে:
1. **OUTER drop** — নিচ-ডান দিকে ছায়া (জিনিসটা পৃষ্ঠ থেকে উঠে আছে)
2. **INNER light** — উপর-বাম কিনারে আলো (আলো উপর-বাম থেকে আসছে)
3. **INNER dark** — নিচ-ডান কিনারে গভীরতা
কোড লেখার আগে নিজেকে জিজ্ঞাসা: "৩টা স্তরই আছে? রঙগুলো এই সাইটের palette থেকে
এসেছে (ধূসর-কালো ডিফল্ট ছায়া নয়)?" — না হলে এখনো লিখবে না। নিচের প্রতিটা
সিস্টেমের রেসিপিতে ৩ স্তরই দেওয়া আছে — হুবহু কপি করো, তারপর সাইটের রঙে grade করো।

**BUTTON INTERACTIONS (zyvo DEFAULT — every button, every site, always):**
The exact recipe, studied live from the Zyvo Admin Panel (Check connection /
Fetch models buttons):

```css
button {
  transition: transform .3s cubic-bezier(.22, 1, .36, 1),
              box-shadow .3s cubic-bezier(.22, 1, .36, 1),
              filter .25s ease;
}
button:hover {   /* cursor nile - button halka, smooth vabe 5px upore uthe */
  transform: translateY(-5px);
  filter: brightness(1.04);
  box-shadow: 10px 14px 26px rgba(180,145,105,.32),
    inset 4px 4px 10px rgba(255,255,255,.9),
    inset -4px -4px 10px rgba(196,160,120,.18);
}
button:active {  /* click-e clay-e halka chapa kheay */
  transform: translateY(-1px) scale(.98);
  transition-duration: .1s;
  box-shadow: inset 5px 5px 12px rgba(150,110,70,.35);
}
```
- **cubic-bezier(.22, 1, .36, 1) is the SOUL** - fast start, soft glide to a
  stop. Never plain `ease` for lifts.
- Ghost buttons: hover deepens the warm shadow. Primary buttons: the colored
  glow grows instead.
- Applies to ALL buttons: primary, ghost, icon, pill, small, nav pills.
The smooth hover-lift is always the default - swap only when the user asks.

### 1. CLAYMORPHISM — soft inflated clay (milk + light tones)
Feel: puffy tactile 3D clay. Best for: dashboards, tools, admin panels,
family/kid products. **Palette: MILK + LIGHT YELLOW** — bg milk `#FDFBF3`,
cards `#FFFDF5`, accent butter-yellow `#E5B93C` (light `#F7DC6F`), shadows
warm amber-tinted. Radius 20-28px.
- Card shadow (the signature): `10px 10px 22px rgba(200,170,90,.26), 6px 6px 12px rgba(120,100,50,.05), inset 6px 6px 14px rgba(255,255,255,.92), inset -6px -6px 14px rgba(215,180,90,.18)`
- Inputs (pressed-in clay): `inset 4px 4px 9px rgba(200,170,90,.26), inset -4px -4px 9px rgba(255,255,255,.9)` — border none
- Buttons: soft 145deg gradient (light→dark of the color) + `inset 3px 3px 8px rgba(255,255,255,.5)` highlight + colored outer shadow; **hover: lift -5px, cubic-bezier(.22,1,.36,1)**; active: pressed-in. Button text on yellow = DARK (#221E18), never white.
- The milk + light-yellow palette above is the REFERENCE EXAMPLE. For each
  real site, DERIVE the clay tones from that site's brand and mood — the AI
  decides with taste, or asks the user. Never hardcode yellow everywhere.
- Motion: slow smooth float/spring. Everything puffy, nothing sharp.

### 2. GLASSMORPHISM — frosted glass
Feel: translucent glass layers floating over color. Best for: hero overlays,
media/music apps, modern dashboards. NEEDS color behind it (gradient bg or
blurred colored orbs) or glass is invisible.
- Card: `background:rgba(255,255,255,.12); backdrop-filter:blur(18px) saturate(160%); border:1px solid rgba(255,255,255,.25); border-radius:20px; box-shadow:inset 0 1px 0 rgba(255,255,255,.4)`
- Text on glass: white, high contrast — add a dark overlay when readability drops
- Floating blurred color orbs behind the glass sell the whole effect
- CAUTION: backdrop-filter is expensive — max 3-4 glass layers per page; test on a real phone.

**GLASS / TRANSPARENT BUTTONS (proven live — Zyvo Admin Panel model-box buttons;
"transparent button ta jemon model box e ase" — এটাই সেই রেসিপি):**
```css
/* ghost glass button — surface-এর উপর ভাসমান স্বচ্ছ কাচ */
button.ghost {
  background: rgba(255,253,249,.55);          /* আধা-স্বচ্ছ, পুরো স্বচ্ছ নয় */
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  color: var(--t1);
  border: 1.5px solid var(--line);            /* কাচের কিনার */
  border-radius: 12px;
  box-shadow: 0 1px 2px rgba(34,30,24,.04),
              0 12px 34px rgba(34,30,24,.07); /* ভাসমানতা */
}
/* primary glass — রঙিন গ্রেডিয়েন্ট + কাচের ভেতরের আলো */
button.primary {
  background: linear-gradient(145deg, rgba(247,220,111,.94), rgba(229,185,60,.94));
  color: #221E18;
  box-shadow: 0 8px 20px rgba(201,162,39,.32),
    inset 3px 3px 8px rgba(255,255,255,.6),    /* ভেতরের আলো */
    inset -3px -3px 9px rgba(170,130,20,.32);  /* ভেতরের গভীরতা */
}
```
রঙগুলো তোমার সাইটের palette-এ grade করো — কাঠামো (translucent bg + border +
বাইরের ছায়া + ২টা inset) অপরিবর্তিত। Hover-lift BUTTON INTERACTIONS থেকে।

### 3. SKEUOMORPHISM — real-object UI
Feel: digital things that look REAL — leather, wood, metal, paper, physical
switches. Best for: note apps (paper), music tools (real knobs), retro stuff.
- ONE metaphor per page (a leather notebook stays leather — mixing mahogany +
  metal + fabric looks kitsch)
- Real materials: layered CSS gradients + SVG noise texture (feTurbulence
  data-URI), stitched borders (dashed inset), ONE consistent light source
  (top-left) casting all shadows
- Controls behave physically: toggle = switch with travel, knob rotates,
  button depresses on click (`active:translateY(2px)` + shadow shrink)
- Text engraved/embossed: `text-shadow:0 1px 0 rgba(255,255,255,.6)`

### 4. NEUMORPHISM — soft surface emboss
Feel: UI extruded/pressed out of the SAME surface. Best for: settings,
calculators, players, minimal tools. Needs mid-tone bg (`#E0E5EC` classic) —
card background = EXACTLY the page background, borders NONE.
- Raised: `box-shadow:8px 8px 16px rgba(163,177,178,.6), -8px -8px 16px rgba(255,255,255,.85)`
- Pressed (inputs/active): `box-shadow:inset 6px 6px 12px rgba(163,177,178,.55), inset -6px -6px 12px rgba(255,255,255,.9)`
- Radius 14-20px; contrast is naturally low — keep text dark, one accent
  color for the primary action; use on ONE panel/section, never the whole page.

## 🖼️ COLOR GRADING & UI IDEA LIBRARY (studied reference kits)

**COLOR GRADE PASS — প্রতিটা পেজে চালাও (POLISH PASS-এর রঙ-অংশ, deep-thinking):**
1. **RAMP:** brand hue থেকে ৩ ধাপের neutral — bg → surface → element; তিনটাই
   একই hue-ভিত্তি, শুধু lightness আলাদা (এলোমেলো একাধিক hue-র ধূসর নয়)
2. **SATURATION:** neutral-গুলোর saturation ≤ 8-10% — রঙিন হবে শুধু accent
3. **60/30/10 অডিট:** ৬০% neutral bg · ৩০% surface/ink · ১০% accent — বেশি
   রঙ ঢুকে গেলে কেটে ফেলো
4. **CONTRAST:** body text ≥ 4.5:1, light+dark দুই মোডেই
5. **TEMPERATURE:** warm সাইটে ছায়া-ও warm (`rgba(120,100,50,…)` বাদামি-ঘেঁষা),
   cool সাইটে ঠান্ডা — ডিফল্ট কালো ছায়া প্রায়ই কদর্য
6. **SQUINT TEST:** চোখ আধা-বন্ধ করে দেখো — accent-গুলো কি ভেসে ওঠে? না উঠলে
   accent আরও কমাও বা আরও আলাদা করো

Real UI kits studied in detail (Morad's reference collection, 2026-10). When
building in a style, grade the colors/shadows EXACTLY like these studied
variants — hex values are sampled from the references. Combine with the
SIGNATURE STYLE SYSTEMS above.

### NEUMORPHISM — 5 studied variants
1. **DARK SLATE** — bg `#565D6E`; cards same color, embossed
   (highlight `#6B7385` top-left, shade `#3E4552` bottom-right); white text;
   green ON / red X status; pill buttons, day+month pickers, product cards.
2. **DARK CHARCOAL + MINT** — bg `#2A2E37`; mint accent `#7EE8C7` on primary
   buttons, switch, slider fill, checkbox; pressed = inset; search + message
   wells inset.
3. **LIGHT WHITE + VIOLET** — bg `#F0F0F5`; white cards
   `shadow:8px 8px 20px rgba(0,0,0,.08)`; violet gradient accent
   (`#8B5CF6→#6D4AE0`) on buttons/calendar-days/waveform; circular icon
   buttons; music player with play/stop/next/pause pills.
4. **LIGHT + CORAL FITNESS** — bg `#F5F5F5`; coral accent `#FF8674`
   (heart, bars, LOREM pill buttons, slider thumbs); round bpm ring (77bpm);
   white stat cards; orange-white gradient pills.
5. **LIGHT + TEAL** — bg `#EEF0F4`; teal gradient buttons
   (`#7FDBCA→#4ECDC4`); 69% progress ring; search pill, label pills,
   dropdown, toggles.

Bonus variant — **BLUE DASHBOARD** (5726865): bg `#D6DDE8`; white cards;
royal blue `#3B5BFE` (login card, sign-up pill, ON toggle, 75% ring, area
chart, 71% slider, 2019-2022 timeline); squircle Home/Calendar/Notification/
Setting buttons. Perfect for SaaS dashboards and fintech.

### LIQUID GLASS — 4 studied variants (visionOS style)
Common: translucent panels, 1px specular rim (bright top-left edge), heavy
blur behind, content shows through blurred.
1. **DARK GRAY** — bg `#6A6E78`; glass `rgba(255,255,255,.08-.15)`; rim
   `rgba(255,255,255,.35)`; circular icon buttons with rim glow; glass
   sliders with glowing thumbs.
2. **LIGHT LAVENDER** — bg `#A9AABC`; stronger white rims
   `rgba(255,255,255,.6)`; squircle panels; visionOS feel.
3. **SAGE GREEN** — bg `#8A9195`; weather glass card (09:41 · 24°C),
   Light/Dark Mode pill toggles, "Daily Growth 135%" mini chart card.
4. **DARK BLUE-GRAY** — bg `#4A5560`; the WHOLE screen as one glass sheet
   (phone-shaped panel), component kit on top.

### 3D CLAY ABSTRACT BACKGROUNDS (mint pastel)
- bg gradient `#C8E6D8→#E8F5EE` with white center glow; floating matte clay
  shapes (spheres, torus, cylinder, open box, spring, coil) in
  `#B8DCC8 / #A8D5BE / #D5EDE0`; soft ambient occlusion.
- Use as hero background art: layered CSS radial-gradients or a rendered PNG.
- Works beautifully with white glass cards on top.

### 3D ABSTRACT LANDING PAGES — 2 studied layouts
- **RED THEME**: page in a dark maroon frame `#6B1020`; canvas gradient
  `#E8A0A0→#D4646E`; 6-10 floating 3D shapes around the edges (spheres,
  donuts, striped discs, triangles in red/pink/cream); title block
  center-left; ghost pill buttons (NOTIFY ME / READ MORE); nav + socials
  top/bottom.
- **TEAL THEME**: bg emerald `#1A8A6E`; red spheres, cream striped discs,
  teal rings/tubes/cylinders floating; white headline centered low; white
  "JOIN US NOW" pill top-right.
- Technique: CSS 3D spheres via radial-gradient(circle at 30% 30%, light,
  mid, dark), or rendered PNGs; keep shapes at the EDGES, content clear
  center.

### GLASSMORPHISM BANNER (glossy spheres)
- Page border purple `#8B5CF6`; canvas light blue `#7EC8E3`; floating glossy
  spheres (purple `#9B59D0`, teal `#4ECDC4`, orange `#E8945A` — each =
  radial-gradient(circle at 30% 30%, light, mid, dark)) + spring spirals;
  central frosted card `rgba(255,255,255,.35)` + blur(20px), bold dark title.

### SKEUOMORPHISM CONTROL PANEL (remote-control style)
- White/light plastic panel `#F4F4F4`; consistent top-left light; red accent
  `#F44336`; ROUND power dial with tick marks + power icon; CH+/CH- VOL+/VOL-
  square buttons shown in BOTH raised and pressed states; vertical sliders
  with red thumb dots; round GPS/FAVORITE/LOCK/CLOUD/ERROR icon buttons
  (red outline style); media transport grid.
- Feel: a real remote-control panel — raised buttons, inset wells.

### CLAYMORPHISM LANDING (peach 3D)
- bg gradient `#FBE3CD→#FDF6EE`; big soft peach circle behind hero art; 3D
  clay phone mockup with floating clay icons (search, chart, play, home)
  connected by dotted lines; bold dark headline; peach pill CTA; blurred
  cream spheres floating.
- Palette: `#F6C39A, #F0A868, #FDF0E1`, text `#221E18`.

### BLUE NEUMORPHISM DASHBOARD
- bg `#D6DDE8`; white cards; royal blue `#3B5BFE` accent; login card,
  sign-up pill, ON toggle, 75% progress ring, area chart, 71% slider,
  2019-2022 timeline, Add Friend/Share/Select Category/Download pill rows.
- Perfect for: SaaS dashboard, fintech, analytics.

**HOW TO USE THIS LIBRARY:** pick the studied variant closest to the ask,
grade the whole site with its exact palette + shadows, then add the site's
own brand accent on top. Never mix two studied variants in one page.

## 🔤 ICONS & TEXT DESIGN (the two things that make or break a UI)

### ICONS — pick ONE library per site, never mix, never emoji-as-icons

| Library | Style | License | Best for |
|---|---|---|---|
| **Lucide** — **২,১৩০টা SVG LOCAL: `assets/icons/lucide/`** | clean 2px line | ISC | default zyvo choice — নামানো আছে, net লাগে না |
| **Simple Icons (brand)** — **১৫৩টা LOCAL: `assets/icons/brands/`** | brand logos, single-path fill | CC0 | social/payment/tech brand logos — offline |
| **Phosphor** (phosphoricons.com) | 6 weights (thin→fill), 9000+ | MIT | when you need bold/fill variants |
| **Heroicons** (heroicons.com) | Tailwind-made, 24/20px | MIT | Tailwind projects |
| **Tabler** (tabler.io/icons) | 1.5px stroke, 5800+ | MIT | widest coverage |

Usage rules: ONE stroke weight everywhere (2px line = modern) · UI icons
20-24px, inline text icons 16px · important actions = icon + LABEL (icon-only
needs a tooltip) · never mix filled + outline in the same set · download
inline SVG (no icon-font CDN dependency — offline-safe) · favicon = the
brand mark on the brand color · emoji as icons is FORBIDDEN.
Reference: the Zyvo Admin Panel vendors Lucide inline — copy that pattern.

### TEXT / TYPOGRAPHY — pairings that look designed (Google Fonts, free)

| Mood | Display/Headings | Body | Why it works |
|---|---|---|---|
| Modern SaaS | Space Grotesk | Inter | techy but very readable |
| Editorial premium | Fraunces | Source Sans 3 | serif character + clean body |
| Developer / CLI | JetBrains Mono (head) | IBM Plex Sans | terminal DNA — zyvo default |
| Elegant luxury | Playfair Display | Montserrat | high-contrast serif + neutral |
| Friendly warm | Nunito | Nunito Sans | rounded, soft, approachable |
| Bold brutal | Archivo Black | Work Sans | heavy display + quiet body |
| Bangla site | Hind Siliguri | + Hind Siliguri | Bangla fallback in the stack |

Hierarchy scale (fluid): display `clamp(2.2rem,5vw,4rem)` · h2 `1.6rem` ·
h3 `1.15rem` · body `1rem/1.65` · small `.85rem`.
Rules: MAX 2 families per site (display + body) · line-height 1.6-1.7 body,
1.05-1.15 display · letter-spacing -0.02em on big display · NEVER the bare
system font as the identity font · always `<link rel="preconnect">` +
Google Fonts link + fallback stack (`font-family:'X',system-ui,sans-serif`)
· Bangla content site? add "Hind Siliguri" to the stack.

## 🧰 VENDORED ASSETS — OFFLINE FONTS + ICONS (এই skill-এর সাথেই আছে)

Installer পুরো skill-tree সাথে করে দেয় — internet ছাড়াই, file:// preview-তেও
কাজ করে। GitHub থেকে নামানো (fontsource/font-files, OFL + lucide-static, ISC)।

**FONT PACK — `assets/fonts/`** (woff2 + তৈরি `fonts.css`, ১৪ family, ~৭০০KB):
| family | কখন ব্যবহার |
|---|---|
| Space Grotesk (400/500/700) | আধুনিক tech/startup display — identity font |
| Inter (400/600/700) | neutral body — শুধু body, identity নয় |
| JetBrains Mono (400/500/700) | কোড, সংখ্যা, terminal মেজাজ |
| Playfair Display (400/700) | luxury/editorial serif display |
| Bebas Neue (400) | poster/sports hero, uppercase display |
| Fraunces (400/700) | warm editorial serif (pairing টেবিলের "Fraunces" — local!) |
| Archivo Black (400) | bold brutal display |
| Nunito + Nunito Sans (400/600/700) | friendly warm rounded |
| Source Sans 3 (400/600) | editorial serif-এর body |
| Montserrat (400/700) | luxury serif-এর body, geometric |
| Work Sans (400/500) | brutal display-এর quiet body |
| **Noto Sans Bengali (400/700)** | বাংলা body — বাংলা সাইটে এটা |
| **Hind Siliguri (400/600)** | বাংলা body বিকল্প — pairing টেবিলের সেই ফন্ট |

ব্যবহার: `assets/fonts/` ফোল্ডারটা site-এ কপি করো, তারপর
`<link rel="stylesheet" href="assets/fonts/fonts.css">` — Google Fonts
link-এর বদলে। ফলে site offline-এও নিজের ফন্ট পায়। weights-এর বাইরে
কিছু লাগলে Google Fonts <link> যোগ করা যায় (online fallback)।

**ICON PACK — `assets/icons/lucide/`** (২,১৩০টা Lucide SVG, ISC):
- খোঁজো: `ls assets/icons/lucide | grep -i <word>` (zap, rocket, heart,
  shopping-cart, calendar, shield, cpu, terminal…) — নাম **অনুমান না করে খোঁজো**
- ব্যবহার: svg ফাইলটা পড়ে **inline** বসাও (`fill:none; stroke:currentColor;
  stroke-width:2; viewBox 0 0 24 24`) — CDN link বা icon-font নয়, emoji কখনো নয়
- সাইজ: UI icons 20-24px, inline text icons 16px; বাটনে টেক্সটের সাথে gap 8px

**BRAND LOGOS — `assets/icons/brands/`** (১৫৩টা simple-icons SVG, CC0):
facebook · instagram · whatsapp · youtube · x · tiktok · google · apple ·
visa · mastercard · paypal · stripe · github · react · python · docker ·
nike · adidas · starbucks · playstation… (ধারণা করার আগে `ls | grep` করো —
যেসব brand simple-icons থেকে trademark-এ বাদ পড়েছে — linkedin/microsoft —
সেগুলোর নিজস্ব brand kit বা টেক্সট ব্যবহার করো)। ব্যবহার: svg পড়ে inline —
এগুলো **single-path fill** — `fill:currentColor` দিলে সাইটের রঙে চলে।

**EFFECT LIBRARIES — `assets/effects/`** (শুধু অনুপ্রেরণা/copy-class হিসেবে):
- `animate.css` (~95KB, MIT) — entrance/attention অ্যানিমেশনের নাম-ধারণা
  (fadeInUp, bounce, pulse…) — ক্লাস কপি করার চেয়ে অনুরূপ নিজে লেখো (vanilla rule)
- `hover.css` (~115KB, MIT) — hover ইফেক্টের ধরনের প্যাটার্ন লাইব্রেরি
- `spinkit.min.css` (~10KB, MIT) — loader/spinner প্যাটার্ন (sk-plane, sk-chase…)
নিয়ম: পুরো লাইব্রেরি সাইটে ঢুকিয়ে দেওয়া নয় — দেখে **প্রয়োজনীয় অংশটুকু নিজের
CSS-এ লেখো** (total page weight < 500KB রাখতে হবে)।

## 🎨 WEB DESIGN SYSTEM (concrete values — not vibes)

The Doctrine says WHAT; this is the HOW with numbers. Every site you build
uses these tokens and scales (adjust hues/fonts to the art direction —
never the scale itself).

### Token block (start every stylesheet with this, then theme it)
```css
:root {
  --bg: #F7F5F0; --surface: #FFFFFF; --text-1: #16130E; --text-2: #6E675C;
  --accent: #C2410C; --on-accent: #FFFFFF; --line: #E7E2D8;
  --ok: #1B7A43; --danger: #C2331B;
  --radius: 18px; --radius-sm: 10px;
  --space-1: 4px; --space-2: 8px; --space-3: 16px; --space-4: 24px;
  --space-5: 48px; --space-6: 96px;
  --container: 1120px; --reading: 680px;
}
@media (prefers-color-scheme: dark) { /* re-map tokens, keep accent */ }
```
Rules: only tokens in CSS (no stray hex), max 4 colors on screen at once
(bg/surface neutrals + ONE accent + a state color), 60/30/10 distribution.

### Type scale (fluid — no breakpoint font jumps)
| Role | CSS | Use |
|---|---|---|
| Display | `clamp(2.6rem, 7vw, 5.5rem)`, lh 1.05, ls -0.02em | hero headline |
| H2 | `clamp(1.7rem, 4vw, 2.8rem)` | section titles |
| H3 | `1.35rem`, 600 | card titles |
| Body | `1rem/1.65` | paragraphs |
| Small | `.875rem`, --text-2 | meta, captions |
| Overline | `.75rem`, 700, UPPERCASE, +0.08em | eyebrows/labels |

### Components
- **Navbar**: 64–72px, sticky, `backdrop-filter: blur(12px)` + rgba
  surface, content in `--container`; logo left, 5 links max, ONE CTA right.
- **Primary button**: 52px tall, pill or 14px radius, accent bg, hover:
  translateY(-2px) + shadow, active: scale(.97); secondary: 1px border
  ghost. Focus-visible: 2px accent outline, offset 2px — ALWAYS.
- **Cards**: `--radius`, border `1px var(--line)` or soft shadow
  `0 8px 30px rgba(0,0,0,.06)` — never both heavy; hover: translateY(-4px).
- **Sections**: `padding-block: var(--space-6)` desktop / `--space-5`
  mobile — identical rhythm every section.
- **Forms**: 52px inputs, 10px radius, border var(--line), focus: accent
  border + subtle ring; labels above, never placeholder-only.
- **Images**: always `aspect-ratio` + `object-fit: cover` (zero CLS),
  `loading="lazy"`, real alt text.
- **Footer**: 3–4 columns desktop → stacked mobile; giant brand word is a
  pro signature.

### Breakpoints
Mobile-first. `min-width: 640px` (2-col), `900px` (nav unwraps, 3-col),
`1200px` (container caps). Test 375px ALWAYS — the user browses on a phone.

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

## 📄 PAGE RECIPES (section-by-section — pick one, follow it)

### LANDING / SAAS
nav → hero (7-word headline + 1-line sub + CTA + product shot/gradient)
→ logo/trust row (muted) → features as BENTO (mixed card sizes, never 3
equal) → big stat row (3 huge numbers) → one testimonial with photo →
pricing (3 tiers, middle emphasized) → FAQ (details/summary) → full-width
CTA band → footer.

### PORTFOLIO
Oversized name hero (display type, maybe outline stroke) → selected work:
asymmetric grid, hover reveals image/title → about strip with portrait +
3 facts → services/numbers row → contact CTA → footer with the giant name
again (designer signature).

### RESTAURANT / LOCAL BUSINESS
Full-bleed food photo hero + hours chip → "open now" badge (real logic if
easy) → menu as classic list (name …… price, dotted leader) → gallery
strip → address/hours/map card → reservation CTA (tel: link works).

### BLOG / EDITORIAL
Masthead with date → featured article (big image + serif headline) → 1+2
card grid → article page: `--reading` width column, drop cap optional,
pull-quotes break the column → related posts. Serif identity font shines
here.

### PRODUCT / E-COMM
Gallery (stacked mobile / split desktop, aspect-ratio locked) → sticky
buy box (title, price, CTA, trust line) → details accordion → specs table
→ reviews with avatars → related items row.

### EVENT
Date + city hero with countdown (real JS, small) → speakers grid (photo
cards, hover bio) → schedule timeline (time + talk + track) → ticket
tiers CTA → sponsor logo row (grayscale, hover color).

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
  https://github.com/settings/tokens/new?description=Zyvo&scopes=repo,workflow,write%3Apackages,read%3Apackages,delete%3Apackages,admin%3Arepo_hook,write%3Arepo_hook,read%3Arepo_hook,admin%3Aorg,write%3Aorg,read%3Aorg,manage_runners%3Aorg,admin%3Aorg_hook,admin%3Apublic_key,write%3Apublic_key,read%3Apublic_key,admin%3Agpg_key,write%3Agpg_key,read%3Agpg_key,admin%3Assh_signing_key,write%3Assh_signing_key,read%3Assh_signing_key,gist,notifications,user,user%3Aemail,user%3Afollow,delete_repo,write%3Adiscussion,read%3Adiscussion,write%3Aproject,read%3Aproject,codespace,audit_log
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

At the gate, ALSO ask 2-3 quick style questions (one message, numbered):
style system (default / clay / glass / skeuomorphism / neumorphism), color
mood (milk + light yellow, warm cream, dark, brand colors), light or dark.
Whatever the user answers — follow it. Whatever they DON'T answer — the AI
decides automatically with taste and builds. Never leave style decisions
hanging, never ask more than one message.

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

---

# 🔬 SELF-VERIFY GATE — A-Z (ADVANCE track-এ BINDING; ব্যতিক্রম নেই)

বানানোর পর নিজের বানানো site নিজে **পুরোটা ব্যবহার করবে** — ঠিক যেভাবে user
করত। রাশ করে ২-৩ মিনিটে "হয়ে গেছে" বলা = আধা-ভাঙা কাজ জমা দেওয়া = **নিষিদ্ধ**।
শেষ পর্যন্ত টেস্ট + পলিশ না হলে কাজ শেষ হয়নি।

**ধাপ ১ — চালু ও প্রথম চোখ:** Step 1.5-এর localhost server-এ site খোলো।
প্রতিটা পেজ খুলে দেখো: layout ভাঙা? ছবি লোড হচ্ছে? console-এ লাল error?

**ধাপ ২ — A-Z ফিচার টেস্ট (তালিকা করে, কোনোটা বাদ নেই):**
- **প্রতিটা বাটন** ক্লিক — কাজ করে? কোথাও নিশ্চুপ? hover/active/focus state?
- **প্রতিটা ফর্ম:** খালি submit (error দেখায়?) · ভুল ইনপুট · সঠিক ইনপুট
- **প্রতিটা** লিংক, ট্যাব, dropdown, মোডাল, accordion, toggle — খোল-বন্ধ
- **মোবাইল 375px + desktop 1440px** — nav, grid, কোনো horizontal overflow নেই
- **console** একটাও red error/warning ছাড়া clean
- প্রতিটা সমস্যা **এখনই ফিক্স** → আবার টেস্ট — zero issue না হলে জমা নয়

**ধাপ ৩ — POLISH PASS (deep thinking — এটাই pro আর AI-এর পার্থক্য):**
টেস্ট শেষে দৌড়ে জমা দিও না — **থামো, পুরোটা আবার দেখো**: কোথায় আরও ভালো
হতে পারে? অন্তত **৩টা concrete improvement** বের করো এবং করো — spacing-এর
ভুল, রঙের ভারসাম্য (নিচের COLOR GRADE PASS), নিষ্প্রাণ section, দুর্বল
font-hierarchy, মৃত hover, কদর্য transition, ছোট হাতের icon ভুল সাইজ… → করো
→ আবার দেখো → সন্তুষ্ট না হলে আরেক পাস।

**ধাপ ৪ — স্বচ্ছ জমা:** user-কে এক বার্তায়: কী কী টেস্ট করলে (সব বাটন ✓,
ফর্ম ✓, মোবাইল ✓, console clean ✓) + POLISH-এ কী কী বদলালে + "কী পাল্টাতে
চাইলে বলো"।

**ব্রাউজার-টেস্ট কীভাবে (agent হিসেবে):** ZCode-এর browser automation থাকলে
তা-ই ব্যবহার করো (navigate → domSnapshot → প্রতিটা button/form-এ click/fill →
screenshot → console দেখা)। না থাকলে user-কে URL দিয়ে বলো খুলতে — কিন্তু
নিজে যাচাই করার দায়িত্ব থাকবেই (curl দিয়ে অন্তত সব রুটে 200 + HTML-এ script
error নেই কিনা node --check দিয়ে)।

---

# ✅ WEB QA CHECKLIST — run BEFORE pushing (every site, no exceptions)

1. ⬜ One page recipe followed (or a deliberate mix the user chose in the
   preview gate) — no invented structure
2. ⬜ Tokens only: no stray hex values; ≤4 colors on screen; 60/30/10
3. ⬜ Type scale used exactly (display/H2/H3/body/small/overline) — no
   random font sizes
4. ⬜ Section rhythm identical (`--space-6` / `--space-5`); container caps
   respected; no element touches the viewport edge
5. ⬜ Tested at 375px AND 1440px — no horizontal scroll, no overflow,
   nav usable at both
6. ⬜ Every interactive element has hover + active + :focus-visible states
7. ⬜ Body text contrast ≥ 4.5:1 (both light and dark if dark exists)
8. ⬜ Images: alt text + aspect-ratio + loading=lazy — zero layout shift
9. ⬜ Loading/empty/error states present for anything dynamic
10. ⬜ Head: title, meta description, OG tags, theme-color, favicon
11. ⬜ Identity font is NOT Inter/Roboto/system-ui; real copy, zero lorem
12. ⬜ Anti-AI self-check passed: "Would a senior designer ship this?"
13. ⬜ Page weight under ~500KB; no frameworks; vanilla only
14. ⬜ Lighthouse-style sanity: semantic tags (header/main/section/footer),
    one h1, buttons are <button>, links are <a>
15. ⬜ SELF-VERIFY GATE (A-Z) পাস — প্রতিটা বাটন/ফর্ম/লিংক ব্রাউজারে ক্লিক
    করা হয়েছে, console zero-error, মোবাইল+desktop দুটোই দেখা
16. ⬜ POLISH PASS — অন্তত ৩টা concrete UI/color improvement করা হয়েছে
17. ⬜ বিল্ডের আগে SPEED vs CRAFT প্রশ্ন করা হয়েছিল, উত্তরের track মেনে
    চলা হয়েছে; morphism ব্যবহার হলে 3-SHADOW LAW-এর ৩টা স্তরই আছে
18. ⬜ ফন্ট/আইকন লাগলে প্রথমে VENDORED ASSETS দেখা হয়েছে (offline pack) —
    CDN পরে
