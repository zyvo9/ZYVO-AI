---
name: webdev
description: Build modern websites/web apps and deploy them LIVE on GitHub Pages — scaffold a beautiful responsive site, push to GitHub, enable Pages and hand the user a live URL. Zero load on the user's phone. Use when the user asks to create/build a website, landing page, portfolio, web app, or says "website banao".
---

# Website Builder (GitHub Pages)

Build beautiful websites WITHOUT any load on the user's phone. You write
the files, push to GitHub, enable GitHub Pages, and hand over a LIVE URL.
The phone only writes text files.

## Golden rules

1. Always produce a MODERN, good-looking design — never bare default HTML.
   Follow the Design System below, and fetch inspiration with WebFetch from
   https://m3.material.io, https://www.refactoringui.com or real showcase
   sites when the app type is uncommon.
2. Default to a **single self-contained index.html** (inline CSS + JS, no
   build step) — GitHub Pages serves it instantly. Split into multiple
   files only when the site truly needs it.
3. The site MUST be responsive (mobile-first — the user is on a phone).
4. Sources live in `$HOME/<sitename>` — never in shared storage.
5. NEVER put the user's GitHub token inside any committed file.

## Requirements checklist (do this first)

- `git` installed: `pkg install -y git`
- User has a GitHub account
- User has a **Personal Access Token** with `repo` scope. Give them this
  DIRECT link (lands on token creation with the scope pre-checked):
  https://github.com/settings/tokens/new?scopes=repo&description=Zyvo%20website
  They click "Generate token" and paste it to you immediately (shown once).
- Site topic/purpose and rough content from the user.

## Step 1 — Design pass

- Pick a palette that fits the topic (dark tech, warm food, calm health...).
- Layout: hero → features → content → footer, or dashboard grid — mobile
  first, test widths 360px+.
- Typography: system font stack or one Google Font via <link> (fine on
  Pages). Titles large, body 16px+, line-height 1.6.
- Motion: subtle transitions only (0.2-0.3s), no heavy libraries.
- If the user wants something you haven't designed before, WebFetch a
  reference (docs/templates) and adapt — always write the final code
  yourself, never copy a whole site.

## Step 2 — Scaffold

Write under `$HOME/<sitename>/`:
- `index.html` — complete, polished, content-filled (real copy, not lorem
  ipsum), inline `<style>` and `<script>` where practical
- `.nojekyll` — EMPTY file (skips Jekyll processing, faster deploys)
- extra assets/files only if needed

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
3. Enable Pages (one API call, no UI needed):
```
curl -s -X POST -H "Authorization: token <TOKEN>" \
  -H "Accept: application/vnd.github+json" \
  -d '{"source":{"branch":"main","path":"/"}}' \
  https://api.github.com/repos/<user>/<repo>/pages
```
4. The live URL is `https://<user>.github.io/<repo>/` — first deploy takes
   1–2 minutes. Verify:
```
curl -s -o /dev/null -w "%{http_code}" https://<user>.github.io/<repo>/
```
   (200 = LIVE. Give the user this URL.)

## Step 4 — Iterate

Content/design changes: edit index.html → commit → push → the live site
updates in ~1 minute. Tell the user this — it is the magic of the flow.

## Pitfalls

- Missing `.nojekyll` → Jekyll may mangle files starting with `_`.
- Pages first build: wait 1–2 min before testing the URL.
- Never commit the token; never echo it.
- Repo must be PUBLIC for free Pages on personal accounts.
- If Pages enable returns 404, the token may lack scope — the link in the
  checklist covers it (repo scope is enough for Pages).
