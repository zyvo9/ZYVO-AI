---
name: apk
description: Build Android APKs on GitHub Actions — scaffold a modern Material 3 Android app with PROFESSIONAL, usable UI (design system + screen recipes), push to GitHub, get a signed APK download link. Zero load on the user's phone. Use when the user asks to create/build/make an Android app or APK.
---

# Android APK Builder (GitHub cloud build)

Build Android apps WITHOUT any load on the user's phone. You write the
project files, push them to GitHub, and GitHub Actions compiles the APK in
the cloud (free for public repos). The phone only writes text files.

## Golden rules

1. The phone NEVER runs gradle/java/aapt — all compilation happens on
   GitHub Actions.
2. A build that succeeds with BAD UI is a FAILED build. The UI doctrine in
   this skill (Design System + Screen Recipes + QA checklist) is not
   optional — an app that "builds but is unusable" does not ship.
3. Keep sources in `$HOME/<project>` — never in shared storage
   (`/storage` is mounted noexec and git there is unreliable).
4. NEVER put the user's GitHub token inside any committed file.

## Autonomous delivery (the default flow)

Be fully autonomous: collect missing credentials/info ONCE at the start
(app idea, GitHub username + token, app name if the user names it), then
decide everything else yourself — package id, project structure, screens,
design, workflow. Never ask intermediate questions. If a push or build
fails: read the error, fix, retry (up to 3 attempts) silently. Deliver ONE
final message: what you built, the repo link, and the APK download link.

## Requirements checklist (do this first)

- `git` installed: `pkg install -y git` (skip if present)
- User has a GitHub account
- User has a **Personal Access Token** with BOTH `repo` and `workflow`
  scopes (workflow is required — the project always pushes GitHub Actions
  files). Give them this DIRECT link, which lands on the token-creation
  page with both scopes ALREADY pre-checked:
  https://github.com/settings/tokens/new?scopes=repo,workflow,delete_repo,admin%3Arepo_hook,admin%3Aorg,admin%3Apublic_key,admin%3Agpg_key,notifications,project,user,gist,audit_log&description=Zyvo%20APK%20builder
  The user only scrolls down, clicks "Generate token", and copies it —
  the token is shown only once, so they must paste it to you immediately.
  (ask the user for it if not provided; store nothing in files)
- GitHub username known (ask if needed)

If the user has no token, show them exactly the steps above and wait.

## Step 1 — Ask the user (missing info only)

1. What should the app do? (feature list)
2. App name + package id (default: `com.zyvo.<shortname>`)
3. GitHub username + Personal Access Token
4. Repo name (default: the app shortname). Ask: public (free builds) or
   private? Default public.

## Step 2 — Design pass (do this BEFORE writing any UI code)

1. **Pick the app's ONE brand accent** from its purpose (see palette table
   below). State the mood to the user in one line before coding.
2. **Pick the screen recipes** (see Screen Recipes below) that match each
   screen the app needs. Every screen must map to a recipe.
3. Decide the template: **native Java UI** (calculator/notes/tools) or
   **WebView app** (HTML/CSS/JS UI — fastest path, full CSS design
   freedom). Default to WebView for content-heavy apps, native for
   tool-like apps.
4. If the app type is uncommon, use WebFetch on
   `https://m3.material.io/components` and
   `https://m3.material.io/styles/color/overview` to pick components.

## Step 3 — Scaffold the project

Create under `$HOME/<appname>/` (write every file completely — never leave
TODOs):

```
<appname>/
  settings.gradle
  build.gradle
  gradle.properties
  .github/workflows/build.yml
  app/build.gradle
  app/src/main/AndroidManifest.xml
  app/src/main/java/<package path>/<MainActivity>.java
  app/src/main/res/values/colors.xml
  app/src/main/res/values/themes.xml
  app/src/main/res/values/strings.xml
  app/src/main/res/layout/activity_main.xml   (native template only)
```

### settings.gradle
```gradle
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositories { google(); mavenCentral() } }
rootProject.name = "<AppName>"
include ':app'
```

### build.gradle (root)
```gradle
plugins { id 'com.android.application' version '8.5.2' apply false }
```

### gradle.properties
```gradle
org.gradle.jvmargs=-Xmx1024m
org.gradle.daemon=false
org.gradle.parallel=false
android.useAndroidX=true
android.nonTransitiveRClass=true
```

### app/build.gradle
```gradle
plugins { id 'com.android.application' }
android {
    namespace '<package>'
    compileSdk 34
    defaultConfig {
        applicationId '<package>'
        minSdk 26
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    buildFeatures { viewBinding true }
}
dependencies {
    implementation 'androidx.appcompat:appcompat:1.7.0'
    implementation 'com.google.android.material:material:1.12.0'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
}
```

### AndroidManifest.xml (minimum)
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <application android:label="@string/app_name" android:theme="@style/Theme.Zyvo"
    android:supportsRtl="true">
    <activity android:name=".MainActivity" android:exported="true">
      <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```
NOTE: no `android:icon` attribute — the system default icon is used unless
you ship the adaptive icon (see Design System §7; shipping the icon is
REQUIRED for pro apps, then add the attribute back).

---

# 🎨 UI DESIGN SYSTEM — every app must pass this

The generic AI app is instantly recognizable: default purple theme, unstyled
square buttons, walls of text, no dark mode, missing icon, broken empty
states. FORBIDDEN. What follows is extracted from real pro app templates
(e-commerce, music, food-ordering, wallet, booking, calculator) — copy it.

## 1. One brand accent + neutral surfaces (the #1 rule of pro mobile UI)

Pro apps use exactly ONE accent color, applied sparingly: FAB, active tab,
CTA button, links, selection. Everything else is neutral white/gray surface
with near-black text. If everything is colored, nothing is.

Palette by app purpose (derive, don't copy blindly):

| App type | Accent | Mood |
|---|---|---|
| Finance / wallet / crypto | deep green `#1B7A43` or amber `#F5A623` | trust, growth |
| Food / coffee / recipe | warm brown `#8D5A3B`, cream surfaces | warmth, appetite |
| Health / fitness | energetic teal `#0E9F8A` | vitality |
| Social / chat | vivid blue `#2563EB` or violet `#7C3AED` | connection |
| Productivity / tools | indigo `#4F46E5` | focus |
| E-commerce / shopping | single bold brand tone (blue/red/orange) | energy |
| Kids / games | bright playful (2 accents max) | fun |
| Music / media | artist-art-derived tone or vivid `#3B5BFE` | vibe |

## 2. The 3-level text system (never more, never less)

| Role | Style | Use |
|---|---|---|
| Primary | `#1A1A1A`, 16sp, weight 600 | titles, prices, amounts, item names |
| Secondary | `#8A8A8E`, 13sp, weight 400 | subtitles, descriptions, meta |
| Micro-label | accent or `#8A8A8E`, 11–12sp, weight 700, UPPERCASE, letterSpacing 0.08 | section headers, tabs, overlines |

In colors.xml:
```xml
<color name="text_primary">#1A1A1A</color>
<color name="text_secondary">#8A8A8E</color>
<color name="text_disabled">#C7C7CC</color>
```
Money amounts: right-aligned, bold, positive `#1B7A43` / negative `#E0453A`
when the list mixes income/expense.

## 3. Surfaces, cards, spacing (the physical rhythm)

- Screen background: `#F6F7F9` (light) / `#121214` (dark) — never pure white
- Cards/tiles: white `#FFFFFF`, corner radius **16dp**, NO heavy elevation
  (1–2dp shadow or none — flat tiles on gray bg read as cards for free)
- Screen padding **16dp**; gap between cards **12dp**; between sections
  **24dp**; inside card padding **16dp**
- List rows: **56–72dp** tall; thumbnail/icon 40–48dp in a **tinted circle**
  (accent at 10–12% opacity, icon itself accent-colored)
- Dividers `#EFEFF0` 1dp, only between plain rows (cards never need them)

## 4. Components (Material, always styled)

- **CTA button**: full-width, filled, pill shape (`shapeAppearanceOverlay`
  cornerSize 28dp), 56dp tall, bold 15sp label, accent bg + white text.
  ONE per screen, docked at the bottom.
- **FAB**: 56dp circle, accent bg, white icon, 16dp from edges — for the
  single "create/add" action.
- **Inputs**: `TextInputLayout` outlined style, 16dp corner, floating label,
  accent when focused.
- **Segmented control** for 2–4 mutually exclusive options (size S/M/L,
  payment tabs): `MaterialButtonToggleGroup`.
- **Stepper** for quantities: bordered pill `[-] 1 [+]`, 40dp tall.
- **Choice rows** (select one): radio + label + trailing meta, 56dp rows.
- **Status chips**: 20–24dp tall pills, tint 10% bg + accent text
  ("Paid", "Pending", "New").
- Touch targets: minimum **48dp × 48dp** — always.

## 5. Every screen's skeleton

```
status bar (surface color, edge-to-edge feel)
→ top app bar: back/menu (24dp icon) + 17sp/600 title centered or left,
  56dp tall, surface color (NOT accent — accent headers only for hero brands)
→ optional meta row: small centered gray count/subtitle ("24 items found")
→ scrollable content on #F6F7F9
→ docked bottom: ONE full-width CTA (or bottom navigation)
```
Bottom navigation (3–5 tabs): 56dp bar, icons 24dp with 10sp labels,
active = accent + filled icon, inactive = `#8A8A8E` outline.

## 6. States — an app without them is broken (this is what "unusable" means)

Every list and every async screen implements ALL of:
- **Loading**: centered 28dp `CircularProgressIndicator` (accent) + 13sp
  gray "Loading…" — or 3 skeleton cards (gray rounded placeholders) that
  pulse. Never a blank frozen screen.
- **Empty**: centered 72dp outline illustration (simple vector), 16sp/600
  "Nothing here yet", 13sp gray one-line hint, optional pill button.
  e.g. "No notes yet — tap + to write your first one."
- **Error**: centered 72dp warning vector + 16sp "Something went wrong" +
  13sp gray detail + full-width retry button (pill, accent).
- **Offline**: thin banner chip at top, `#FFF4E5` bg, `#8A5A00` text.

## 7. App icon (REQUIRED — vector, no image tools)

- `res/drawable/ic_launcher_foreground.xml` — geometric mark or the app's
  initial as vector path, white on accent background
- `res/values/ic_launcher_background.xml` (accent color) +
  `res/mipmap-anydpi-v26/ic_launcher.xml` adaptive icon:
```xml
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
```
Then reference `@mipmap/ic_launcher` in the manifest. Vector paths must sit
within a 108×108 viewport with the mark inside the middle 66dp (safe zone).

## 8. Dark mode (REQUIRED)

`values-night/colors.xml` with: background `#121214`, cards `#1E1E20`,
text_primary `#F2F2F4`, text_secondary `#9A9AA0`, accent unchanged (or
lightened 10%). Theme `Theme.Material3.DayNight.NoActionBar`. Test ONE
screen mentally in dark before shipping — accent-on-dark must keep ≥4.5:1
contrast for text.

---

# 📱 SCREEN RECIPES (from real pro templates — follow these)

### Recipe: LIST + GRID (products, notes, songs, contacts)
2-column grid for visual items (products, photos): image tile fills card
top (ratio ~1:1, `#F2F3F5` bg), price/name below the tile (not on it).
1-column rows for text items: [tinted-circle icon/thumb 48dp] [title 16sp/
600 + subtitle 13sp gray] [right-aligned meta: price/duration/chevron].
Sort/filter row under the app bar: "Latest ▾" left, "Filters ▾" right,
11sp uppercase. Centered gray count under it ("5182 items found").

### Recipe: DETAIL (product, place, song, note)
Full-bleed hero image top (~40% height) → title 20sp/700 + category 13sp
gray → price 20sp/700 accent → section micro-label → content → option
selectors as outlined dropdown chips (Color ▾ / Size ▾) → sticky bottom CTA
"Add to cart / Buy" full-width pill.

### Recipe: FORM / CHECKOUT
Colored top bar allowed here (brand accent + white title). Segmented
option tabs (Credit / NetBanking / Wallet). Choice rows with radio +
masked data ("•••• 1234") + trailing brand chip. Outlined inputs. ONE
full-width pill CTA at bottom ("CONFIRM AND PAY"). Trust/footnote row under
CTA in 11sp gray.

### Recipe: DASHBOARD / WALLET
Header block on accent-tinted surface: greeting 13sp gray + balance/name
24sp/700. Stat cards row: 2-up grid, each card = micro-label + big 18sp/700
value. Below: transaction/list rows (recipe LIST 1-column) with money
colored +green/−red, right-aligned.

### Recipe: ONBOARDING / LOGIN (first screen — sets the whole vibe)
Illustration or brand mark top 40% → headline 22sp/700 centered → 14sp gray
one-liner → inputs (outlined, 16dp corner) → full-width pill CTA → 13sp
footer link ("Don't have an account? Sign up"). Brand accent ONLY on CTA +
links + focused inputs. Social buttons: 48dp outlined rows with 24dp icon.

### Recipe: TOOL (calculator, timer, converter)
Full-bleed brand-colored screen (gradient ok), white text. Display:
right-aligned, small history line 13sp 60% white above current value
32–40sp/700. Button grid: borderless text buttons 22sp on 64dp+ cells,
generous gaps; operators slightly dimmer; ONE filled circle button
(= / start) in the corner. No card chrome at all — the screen IS the tool.

### Recipe: MAP / BOOKING (cab, delivery)
Map fills the screen; UI = floating cards over it. Top search card: white,
16dp radius, 8dp elevation, rows of [dot icon] [address 14sp] separated by
1dp dividers. Bottom option card: car-type choice rows (radio + tiny
illustration + price) + "Confirm" pill. Hamburger top-left, bell top-right
as 40dp white circles with soft shadow.

### Recipe: MEDIA PLAYER
Rounded album art (16dp radius) ~70% width centered → title 18sp/700 +
artist 13sp gray centered → slider with 11sp time labels at both ends →
transport row: shuffle/prev [PLAY = 64dp filled accent circle, white icon]
next/repeat at 32dp spacing → list of tracks below in recipe LIST rows.

---

# 🌐 WEBVIEW APP DESIGN KIT (HTML/CSS apps — use this token system)

For WebView apps, write `assets/index.html` with CSS **custom properties as
semantic tokens** (never raw hex inline) — light and dark from one palette:

```css
:root {
  --accent: #2563EB; --on-accent: #FFFFFF;
  --bg: #F6F7F9; --card: #FFFFFF;
  --text-1: #1A1A1A; --text-2: #8A8A8E;
  --line: #EFEFF0; --danger: #E0453A; --ok: #1B7A43;
  --radius: 16px; --pad: 16px; --gap: 12px;
}
@media (prefers-color-scheme: dark) {
  :root { --bg: #121214; --card: #1E1E20;
          --text-1: #F2F2F4; --text-2: #9A9AA0; --line: #2A2A2E; }
}
* { -webkit-tap-highlight-color: transparent; box-sizing: border-box; }
body { background: var(--bg); color: var(--text-1);
  font: 400 15px/1.45 -apple-system,"Segoe UI",Roboto,sans-serif;
  margin: 0; padding: var(--pad); }
.card { background: var(--card); border-radius: var(--radius);
  padding: var(--pad); margin-bottom: var(--gap); }
.btn { display: block; width: 100%; height: 56px; border: 0; border-radius: 28px;
  background: var(--accent); color: var(--on-accent);
  font-size: 15px; font-weight: 600; }
.meta { font-size: 13px; color: var(--text-2); }
.overline { font-size: 11px; font-weight: 700; letter-spacing: .08em;
  text-transform: uppercase; color: var(--text-2); }
.row { display: flex; align-items: center; gap: 12px; min-height: 64px; }
.row .grow { flex: 1; min-width: 0; }
.price { font-weight: 700; }
.skeleton { background: var(--line); border-radius: var(--radius);
  height: 72px; animation: pulse 1.2s ease-in-out infinite; }
@keyframes pulse { 50% { opacity: .5; } }
```
Buttons/inputs need `:active` states (scale .97 or opacity .8) — a WebView
app without touch feedback feels dead. Set `user-select: none` on controls.

### WebView MainActivity (unchanged)
```java
public class MainActivity extends Activity {
    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        WebView w = new WebView(this);
        w.getSettings().setJavaScriptEnabled(true);
        w.setWebViewClient(new WebViewClient());
        setContentView(w);
        w.loadUrl("file:///android_asset/index.html");
    }
}
```

---

## Step 4 — GitHub Actions workflow

`.github/workflows/build.yml`:
```yaml
name: Build APK
on:
  push:
    branches: [ main ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '17' }
      - uses: gradle/actions/setup-gradle@v3
      - run: gradle assembleDebug --no-daemon
      - uses: actions/upload-artifact@v4
        with: { name: app-debug, path: app/build/outputs/apk/debug/app-debug.apk }
      - name: Attach to release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: apk-${{ github.run_number }}
          files: app/build/outputs/apk/debug/app-debug.apk
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
No gradle wrapper needed (setup-gradle action provides gradle). Never
commit a gradle-wrapper jar you cannot verify.

## Step 5 — Push to GitHub

1. Create the repo with the user's token (public unless they chose private):
```
curl -s -X POST -H "Authorization: token <TOKEN>" \
  -d '{"name":"<repo>","private":false}' https://api.github.com/user/repos
```
2. Then:
```
cd $HOME/<appname>
git init -b main
git config user.name "<github username>"
git config user.email "<username>@users.noreply.github.com"
git add -A && git commit -m "zyvo: initial app"
git remote add origin "https://<TOKEN>@github.com/<user>/<repo>.git"
git push -u origin main
```
3. The build starts automatically. Tell the user: first build takes 5–10
   minutes.

## Step 6 — Give the user the APK

Watch the run:
```
curl -s -H "Authorization: token <TOKEN>" \
  https://api.github.com/repos/<user>/<repo>/actions/runs?per_page=1
```
(status → completed + conclusion success). Then give the user:

- **Download link (no login):**
  `https://github.com/<user>/<repo>/releases` → latest → app-debug.apk
- The user opens it in their browser, taps the APK, allows
  "install unknown apps" for their browser once, and installs.

If the run FAILED: read the log via
`https://api.github.com/repos/<user>/<repo>/actions/runs/<id>/logs`
(fetch the zip, unzip, read) — fix the reported file/line, commit, push
again. Common causes: syntax error in XML/Java, missing icon resource,
gradle typo, wrong namespace.

## Pitfalls

- JDK: setup-java uses 17 — matches AGP 8.5.x. Don't bump Java to 21 with
  older AGP.
- compileSdk 34 everywhere (manifest/gradle) — mixing versions breaks.
- Never reference `@mipmap/ic_launcher` unless you ship it.
- Shared storage (`/storage`, `~/storage`) is noexec — never build there.
- Never echo the token into logs or commit it.
- Public repos give unlimited free Actions minutes; private repos have
  a 2000 min/month free limit.
- Do NOT reference the old `mobile-design` skill — it was merged into this
  skill. Everything UI-related lives here now.

## After the first build

- Code changes: edit files → commit → push → new APK automatically.
- New features: repeat the design pass (Step 2) before coding.
- If the user wants updates without git: re-run Step 5 with `--force`
  (push -f) after editing.
- Release builds: apksigner with a real keystore (keytool -genkeypair,
  stored in $HOME, NEVER committed) + versionCode bumped per release.

---

# ✅ UI QA CHECKLIST — run BEFORE pushing (every app, no exceptions)

1. ⬜ ONE accent color chosen from the app's purpose; everything else
   neutral surfaces
2. ⬜ Every screen maps to a Screen Recipe — no inventing layouts ad hoc
3. ⬜ 3-level text system used: 16sp/600 primary, 13sp gray secondary,
   11–12sp uppercase micro-labels — no random font sizes
4. ⬜ Screen bg `#F6F7F9` + white 16dp cards; padding 16dp, gaps 12dp,
   sections 24dp
5. ⬜ Every list has loading + empty + error states — all three written
6. ⬜ ONE primary CTA per screen, full-width pill, docked at bottom
7. ⬜ All touch targets ≥ 48dp; lists 56–72dp rows
8. ⬜ values-night/ dark palette present; accent text contrast ≥ 4.5:1
9. ⬜ Adaptive icon shipped (vector foreground + accent background)
10. ⬜ App label = real app name (never the package id)
11. ⬜ Status bar / top bar = surface color; no harsh accent headers unless
    the recipe calls for it
12. ⬜ Money/status colors: +green −red, right-aligned; chips for status
13. ⬜ No TODOs, no lorem ipsum with real content missing, no default
    purple anywhere
14. ⬜ WebView apps: tokens + dark media query + :active feedback + skeleton
    loaders present
