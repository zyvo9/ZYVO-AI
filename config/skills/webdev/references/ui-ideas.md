# UI/UX IDEA LIBRARY — 123 curated rules, palettes & resources

> Source: Morad's personal TikTok design collection (studied image-by-image,
> 2026-09-07). Read this file BEFORE any design pass. Use together with the
> design system in SKILL.md — this file is the "why", SKILL.md is the "how".

## 1. UX laws (name them in your reasoning, apply them in your layout)

- **Hick's Law** — fewer choices = faster decisions. Cut options.
- **Fitts's Law** — bigger, closer targets are faster to hit. CTA in the
  thumb zone, bottom of the screen.
- **Jakob's Law** — users expect your app to work like the apps they
  already know. Use familiar patterns, don't invent navigation.
- **Miller's Law** — working memory ≈ 7±2 items. Chunk information into
  cards/sections.
- **Gestalt set** — Proximity (related = close), Similarity (alike looks
  grouped), Uniform Connectedness (shared border/bg = one unit), Common
  Region (card defines group), Continuity (aligned rows read as lines).
- **Pareto** — ~20% of features serve ~80% of usage. Build those first.
- **10 design principles** — Contrast, Repetition, Alignment, Proximity,
  Hierarchy, Balance, White space, Consistency, Scale, Unity.

## 2. Forms (the #1 place beginners fail)

- Minimum fields: 3 fields convert better than 5 — every extra field costs
  completions. Ask later what you can ask later.
- **Boxes, not underlines** — bordered/filled inputs read as tappable.
- **Input masks guide users** — `MM/DD/YYYY`, `(___) ___-____` show the
  expected format inside the field.
- Labels left-aligned, one column, vertical rhythm (no zig-zag layouts).
- Add an **"Other"** option instead of a very long option list.
- Long lists (countries) → **searchable select**: let users type AND scroll.
- Multi-select interests → **toggle chips**, not a wall of checkboxes.

## 3. Buttons & interaction

- Generous side padding on buttons; 48–56dp height; full-width pill CTA
  docked at the bottom (thumb zone — Fitts).
- Primary vs secondary must be obvious at a glance: filled accent vs
  outlined/ghost. Never two filled buttons competing.
- Cut the verb when the meaning is clear: "New Window", not "Open New
  Window".
- Words that push: "Start Learning Now" beats "Subscribe". Verbs + outcome.
- Make links look clickable: accent color + arrow ("Read more →").
- Never two primary actions on one screen.

## 4. Icons

- **Familiar & recognized** (home/search/save/profile) — never invent
  metaphors users must decode.
- **One consistent style** per app — never mix filled + outline in one bar.
- Simple beats detailed (a simple house reads better than an illustrated
  one at 24dp).
- Scalable: must stay clear at 20dp and 48dp.
- Modern, not outdated (no floppy-disk/save, no funnel/filter-era glyphs).
- Right proportions: icon size/weight must match its text.
- Libraries: **Phosphor Icons, Feather Icons, Heroicons**, Icons8,
  Streamline, IconScout, Iconify, Iconbuddy.

## 5. Color

- ONE accent; limit the whole palette to **≤ 4 colors** (8 is chaos).
- Soft/neutral backgrounds carry the app; saturated color only for accent
  and states.
- Dark mode: **desaturate** accents slightly — neon burns on black.
- Money amounts: `+green / −red`, bold, right-aligned.
- Soft background tints (10–12% accent) for icon circles and chips.

## 6. Typography

- UI sans: **Inter, Poppins, Manrope** — simple and readable. Decorative
  display fonts only for one-off hero words (luxury serif on cream etc.).
- Clear 3-level hierarchy everywhere: big bold value → gray secondary →
  tiny uppercase overline.
- Highlight the ONE important number per screen ($4.5M ↑11%, huge; the
  rest small).

## 7. Layout & space

- 4-column grid; side margins ≥16dp (up to 24dp); gutters optional.
- **White space is a feature.** Crammed = cheap.
- **Group related elements** together (proximity) — scattered = confusing.
- **Remove unnecessary elements** — every box/button must earn its place.
- Design **small frame first** (375×812), then scale up.
- Use constraints/auto-layout so screens adapt to every size.
- **Soft shadows or borderlines** — blur 20–60, 4–16% alpha, tint
  #001230; or a clean 1dp line. Never heavy black shadows.
- Maintain clear visual hierarchy: one hero element per screen.

## 8. Language & delight (what makes apps feel alive)

- Human-like microcopy: "Looks great!", "Take a new photo" — not
  "Confirm and continue".
- **Celebrate the end**: completion screens with a checkmark/emoji burst +
  progress ("7.5/10 — Congratulations!") — the last impression sticks.
- Prioritize & highlight the important information; the rest goes quiet.

## 9. Platform correctness

- Use the platform's own system components (Material on Android, Cupertino
  patterns on iOS). Mixing platforms reads as fake instantly.

## 10. The pro design flow

Inspiration → Wireframes → Colors/Fonts/UI kit → Icons & illustrations →
Photos → Mockup → **user picks (preview gate)** → build.

## 11. Resources (from the cards)

- **Palettes:** colorhunt.co, happyhues.co, colors.co, color.adobe.com,
  khroma.co
- **Fonts:** fonts.google.com, fontsource.com
- **Icons:** see §4
- **Photos:** unsplash.com, pexels.com, pixabay.com, burst.shopify.com,
  kaboompics.com, reshot.com
- **Illustrations:** undraw.co, storyset.com, openpeeps.com, humaaans.com
- **Mockups:** smartmockups.com, mockupworld.co, placeit.net
- **Wireframes/flows:** miro.com, whimsical.com, figma.com, wireframe.cc
- **Inspiration:** mobbin.com, pttrns.com, dribbble.com, behance.net,
  awwwards.com, land-book.com, collectui.com

## 12. Ready-made palettes (extracted from the collection — pick by mood)

| Mood | Palette |
|---|---|
| Neon SaaS dark | bg #0F0F0F · accent #C7FF2E · white — fitness/analytics |
| Deep green + lime | #144425 · #D3FA53 · #057E0E · #E4E9D5 — travel/nature |
| Grocery fresh | #004B24 · #108A11 · #FF7006 · #FB091A — food delivery |
| Travel orange | #FE813C · #BC655A · #727E8E · #DEDFDB — warm photo-led |
| Event bold blue | #0249E1 · #8D80EC · #DAF971 · #E3D55A — tickets |
| Playful fintech | #202D41 · #6667FB · #C8FF3C · #EFEFEF — banking + mascots |
| Dashboard coral | #FE5B3A · #F70A41 · #976EEE · #FAFCFC — analytics |
| Cream & yellow | #F6F6F4 · #FFDB5E · #303030 · #FEEDE9 — soft finance |
| Multi-accent playful | #7477FF · #F66854 · #F9CD61 · #C5D4CA — mood/social |
| Education soft | #F5F378 · #DCC1FF · #EC704B · #111111 — learning apps |
| Elegant green SaaS | #004839 · #E9F8BE · #FFFFFF — premium web |
| Beauty cream | #FE813C · #BC655A · #DEDFDB — skincare/luxury |

## 13. WEBSITE STYLE DIRECTIONS (from the 9 web references — pick ONE per site, commit fully)

Each direction is a complete personality: palette + fonts + layout moves.
Preview 2-3 of these in the UI preview gate, then build the winner fully.

### A. Dark Editorial Studio
Black #0A0A0A canvas, oversized white display type (5-8vw), ONE warm accent
(orange #FF4D00). Signature move: a full-width MARQUEE strip (CSS scroll-
ing text band) separating sections, giant brand name in the footer, work
grid with hover-reveal images. Fonts: Archivo Expanded / Space Grotesk.

### B. Luxury Cream Serif
Cream #F7F2EA bg, deep espresso text, hairline rules everywhere. Display
serif (Playfair/Cormorant, italic accents), tiny uppercase sans labels.
Full-bleed photography with generous margins, "About —" style inline
markers, French-editorial spacing. For restaurants, fashion, beauty.

### C. Magazine Editorial
Newsprint feel: huge serif headlines (8vw) overlapping images, italic
pull-quotes, multi-column text blocks, image collages with mixed sizes,
thin borders. Cream/white + black + one red accent. Like a printed
magazine that happens to scroll.

### D. Clean Product Modern
White canvas, near-black text, one vivid brand color. Big friendly sans
headline (Clash Display/General Sans), product photo breaking the text
column, circular rotating text badge (SVG textPath), minimal top nav.
For SaaS, tools, hardware.

### E. Bento Grid Portfolio
Playful grid of MIXED-size cards (bento), each with a real image/picsum
seed, bright 2-accent palette (yellow #FFDB5E + green), fat rounded
corners (24-32px), sticker-style labels. For portfolios, agencies,
creative work.

### F. Soft 3D Organic
Pastel gradient background (large blurred blobs), floating 3D-ish objects
(CSS/SVG shapes with soft shadows), glassy cards (backdrop-filter blur),
rounded-everything. For apps, wellness, playful products.

### G. Brutalist Bold
Massive condensed type filling the viewport (Bebas/Anton), hard black on
white or neon-on-black, visible grid lines, huge index numbers (01/02/03),
zero decoration. Confidence through scale. For studios, events, fashion.

### H. Minimal Luxury Product
One product, enormous whitespace, tiny navigation, thin serif details,
slow fade-in reveals. Almost nothing on screen — the product IS the design.
For premium single-product stores.

### I. Dark Glass Tech
Near-black #0B0E14, gradient mesh glow orbs, glass cards (rgba white 4-6%
+ blur), neon accent (#7C5CFF or #00E5A0), monospace labels, subtle grain.
For web3, dev tools, AI products.

## 14. Conversion details that sell (from the refs)

- Social proof row: avatar cluster + "Trusted by 2,000+ teams"
- Logos of known brands in one muted row
- "No credit card required" under the CTA (small, gray)
- One stat row with big numbers (99.9% uptime, 4.9/5 rating)
- Founder quote with signature-style italic serif
- Rotating circular badge "SCROLL - EXPLORE - SCROLL -" (SVG textPath)
- Marquee ticker of press names / product words

## 15. More directions & components (second batch)

### J. Data Dashboard (dark analytics)
Near-black #0D0F14, sidebar nav (64px icons+labels), content = KPI cards
row (4-up: label + huge value + delta chip) + chart cards (rounded 16px,
subtle grid lines) + data table (monospace numbers, right-aligned).
Neon accent ONE (cyan #22D3EE or lime #A3E635). Font: Space Grotesk +
JetBrains Mono for numbers.

### Gradient credit-card component (fintech)
390×220 card, 24px radius, diagonal gradient (two brand tones), chip SVG,
masked number in mono with 4px letter-spacing, bank logo top-right,
name/expiry bottom. Stack 2-3 cards with -60px overlap on a dark hero.

### Logo/icon system rules
Simple (one metaphor), scalable (clear at 16px AND 512px), memorable
(distinctive silhouette), works in ONE color. Test: squint — still
recognizable? App icons: consistent squircle, bold glyph, subtle
top-to-bottom gradient, no text inside small icons.

## 16. Font pairings that always work (Google Fonts)

| Vibe | Display | Body |
|---|---|---|
| Editorial luxury | Playfair Display (italic accents) | Source Sans 3 |
| Bold modern | Archivo Black / Anton | Inter |
| Friendly startup | Clash Display* / Fraunces | Manrope |
| Technical calm | Space Grotesk | Inter |
| Humanist warm | DM Serif Display | DM Sans |
| Brutalist | Bebas Neue | IBM Plex Sans |
*Clash Display via fontshare.com — else Fraunces.
Rule: display font ONLY for headlines; body always the body font.
