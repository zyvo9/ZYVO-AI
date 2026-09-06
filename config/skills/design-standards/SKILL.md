---
name: design-standards
description: Premium design standards for anything zyvo builds — color systems, typography scales, spacing, component quality, layout patterns, and motion standards. Generates a DESIGN.md brief first and holds every build to it. Use before/while building any website, app, or video; also use to audit and upgrade something that looks plain, generic, or AI-made.
---

# Design Standards (the zyvo quality bar)

Every website, app, or video zyvo builds must pass this bar. Write a
DESIGN.md brief first (mood, palette, type, motion), build against it,
then self-check. This is how zyvo avoids the generic AI look.

## The forbidden list (instant redo)

- Blue-purple gradients (#3B82F6 → #8B5CF6) as the whole identity
- Uniform 3-column card rows with identical cards
- Inter/Roboto/system-ui as the identity font
- Emoji as the hero visual
- Lorem ipsum or placeholder text shipped to the user
- Everything centered with no layout personality
- Animations that fire all at once

## Design brief (write this BEFORE coding)

Fill these and state them to the user:
1. **Mood**: 3 words (e.g. "warm, handcrafted, bold")
2. **Palette**: 60% dominant + 30% secondary + 10% accent — derived from
   the subject (coffee → espresso/cream/burnt-orange; fintech → deep
   navy/mint), never default framework colors
3. **Type pairing**: identity font with character (Fraunces, Playfair,
   Bebas Neue, DM Serif, Space Grotesk) + clean body font. Google Fonts
   via <link> is fine.
4. **Layout concept**: editorial asymmetry / split screen / bento with
   mixed sizes / oversized type / full-bleed sections — one concept, not
   a card grid.
5. **Motion**: 2-3 signature moves max (hero stagger, hover lift, scroll
   reveal) — everything else stays still.

## Color system rules

- 60/30/10 distribution. Test contrast (body text ≥ 4.5:1).
- Dark mode: darken surfaces, never pure black on pure white text
  (use #0d0f14 + #e6e8ee-class tones).
- One accent color for actions — everything else supports.

## Typography rules

- Scale: 12 / 14 / 16 / 20 / 28 / 40 / clamp(3rem, 8vw, 7rem) for display.
- Line-height: 1.6 body, 1.1 headlines. Letter-spacing tight on big type.
- Max measure ~65 characters per line for paragraphs.

## Spacing system

- Scale: 4 / 8 / 16 / 24 / 48 / 96. Consistent rhythm.
- Section padding generous; related items tight. Whitespace is design.

## Component quality bar

- Buttons: filled pill for primary, outlined for secondary, clear
  hover/press/focus states.
- Cards: 12-16px radius, subtle border or shadow — never both heavy.
- Forms: labels above inputs, visible focus rings, real validation text.
- Every interactive element responds (hover/press/focus).

## Imagery

- Real-feeling content: picsum.photos with fixed seeds, hand-made SVG
  shapes/patterns, CSS gradients as art — no generic stock feel.
- Alt text on every image.

## Motion standards (paired with the remotion/motion skills)

- Animate only transform/opacity. Entrances: cubic-bezier(0.16, 1, 0.3, 1),
  400-700ms, staggered 50-100ms.
- Scroll reveals once per element. Hover lifts 2px max. Press compresses
  0.97. Respect prefers-reduced-motion (shorter fades, no big moves).
- If a motion doesn't aid hierarchy or feedback, cut it.

## Self-check before shipping

Ask, section by section: "Would a senior designer ship this? Can someone
tell this was AI-made from a screenshot?" If yes to the second question,
redo that section with a different layout, palette shift, or better copy.
Then re-check contrast and responsive widths (360px+).
