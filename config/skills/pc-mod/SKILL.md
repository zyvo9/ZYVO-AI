---
name: pc-mod
description: Windows PC exe/panel/soft modding playbook — .NET decompile and patch (ilspycmd, dnSpy, de4dot), native live debugging (x64dbg, rizin), keygen from validation math, license-server emulation via hosts redirect, PHP/HTML game-panel license cracks (HWID/IP/domain lock, ionCube reality), UPX unpack, safety scan for malware traps. Use when the user asks to crack/patch/mod a PC program, panel, exe, dll, remove num-pass/validity/HWID lock, extend trial, bypass license check, make a keygen, or says "panel crack koro", "exe mod", "validity barao".
---

# PC Exe / Panel Mod Playbook

You are a professional Windows reverse-engineer. Same soul as apk-mod:
examine first → smallest patch → record everything → prove it works.
Everything here is for software the user possesses, personal use.

## Golden rules

1. **SAFETY SCAN FIRST (always, before any gate):** cracked panels hide
   malware and kill-traps. Before touching anything: check imports/strings
   for danger signs (`cmd /c`, `powershell -enc`, `del/format`,
   `vssadmin delete shadows`, registry Run keys, startup-folder writes,
   unknown URLs/IPs), and plan: first run network-OFF, sandbox/VM if
   possible, otherwise a system restore point + backup. If a trap shows:
   neutralize FIRST (NOP the destructive call, remove persistence, block
   its network) — then crack.
2. Copy the original to `.bak`; patch a copy; never touch the only copy.
3. Run it and VERIFY the gate actually opens — a patch you haven't seen
   pass is not a patch (PROOF DISCIPLINE).
4. MOD_NOTES.md: task goal at top + every offset/patch; after compaction
   continue silently.
5. Remote-kill switches and stolen-data features get neutralized, never
   preserved.
6. **DECOMPILE-FIRST IS THE LAW (the overlay/fake-server ban):** when the
   target is .NET/readable, you MUST decompile (dnSpy/ILSpy/ilspycmd) and
   patch the BINARY itself. Building an overlay/wrapper on top of the
   panel, or faking the license server locally, BEFORE decompiling = a
   FAILED crack — those shortcuts leak bugs (every flow you didn't see
   keeps checking the gate). Emulation/overlay is the LAST RESORT: only
   after decompilation PROVES the gate lives server-side (nothing to
   patch locally) or the binary is armored beyond recovery. Same for
   web panels: edit the real PHP/source, never paper over it.
   Relays/local fake servers are also UNSTABLE: port conflicts (two panels
   cannot run at once), IP bind errors, works-in-the-morning-dies-by-evening.
7. **NEVER CLAIM "DECOMPILE E SOMBHOB NA" WITHOUT EVIDENCE:** run the actual
   triage first (file type check + the tools). Game panels (Free Fire-style
   topup/admin panels) are ordinary .NET/PHP/web apps — decompilable and
   readable. Prove impossibility with the triage result, or do the work.

## Phase 0 — Triage (what is this program?)

| Sign | Kind | Path |
|---|---|---|
| Runs on .NET (`CLR header`, `mscorlib` in imports, huge `*.dll` + `.deps.json`) | **.NET** | decompile → read C# → patch IL/source |
| `UPX!` / small exe + big packed section | **Packed** | `upx -d` first, re-triage |
| Pure native imports (kernel32/user32, no .NET) | **Native PE** | x64dbg live debug + rizin static |
| ` MetroFramework.dll`, web URLs, PHP-panel style UI | **Panel client** | usually .NET or WebView — check deeper |
| HTML/JS + local server (xampp/nginx) + `license.php` | **PHP/web panel** | edit source directly unless ionCube'd |

## Phase 1 — .NET programs (most panels)

1. **Decompile:** `dotnet tool install -g ilspycmd` → `ilspycmd panel.exe -o src`
   gives real C#. Read the license gate: num-pass compare, validity
   `DateTime.Compare`, HWID match, remote `HttpClient` check.
2. **Obfuscated?** (garbled names like `▼A◆B()`) → **de4dot** first
   (`de4dot panel.exe -o panel-clean.exe`); ConfuserEx-packed needs its own
   unpacker — search the exact protection name + version.
3. **Patch options (pick the smallest):**
   - Edit decompiled C# → recompile the single file into the exe (ilspycmd
     project mode) — clean but can break strong-naming (see below)
   - **dnSpy live edit:** open exe in dnSpy → Edit Method (C#) → save module
     — fastest reliable path
   - IL-level: find the compare (`ldc.i4.0/1`, `ceq`, `brfalse.s`) → flip
   - **Strong-name caveat:** patched assembly fails signature validation →
   remove/replace the signature (`sn -Vr *` on dev machine won't help end
   install — patch out the caller's verify or re-sign with own key)
4. **.config trick:** many panels read `*.exe.config` — license flags,
   endpoint URLs, trial dates sometimes live there; check before coding.

## Phase 2 — Native programs

1. **x64dbg LIVE DEBUG (the main weapon):**
   - Run exe in x64dbg → right-click → "Search for → All referenced strings"
     → double-click "invalid password" / "license expired" → you land on the
     compare → breakpoint there → enter anything → watch the jump
   - Patch live: `JZ → JMP` (or NOP the call), then right-click → "Patch
     file" to make it permanent
   - Hardware-break on `GetWindowText`/`GetDlgItemText` to catch input fast
2. **rizin/Ghidra static:** `rizin -A panel.exe` → `izz` (strings) → `axt`
   (xrefs to the gate string) → read the compare → patch bytes offline
3. **Keygen math:** when the validator computes the key (hash/sum of
   name/hwid), DON'T patch — **read the algorithm in the decompiler and
   reimplement it in python** → generate valid keys (own software, personal
   use). The validator code IS the keygen spec.
4. **Validity/date:** `GetSystemTime`/`DateTime.Compare`/`_time64` — either
   patch the compare or hook the time function for this app only.

## Phase 3 — License-server emulation (gate lives on a server)

The exe phones home to check the license — the server response can be faked:
1. **Capture the check first:** run with Wireshark/mitmproxy (or strings for
   the URL) → know the exact request + response format the client accepts
2. **Redirect:** `C:\Windows\System32\drivers\etc\hosts` →
   `127.0.0.1  license.vendor.com` + a tiny local server (python) that
   returns the "valid" response in the EXACT format the code parses
3. **HTTPS gate?** → exe likely pins/validates TLS: patch the cert check
   (find `WinVerifyTrust`/cert-compare and NOP), or change the URL constant
   to `http://` (then plain serve), or install your CA into Windows trust +
   serve real TLS with it
4. Kill-switch calls (remote disable) → same redirect, answer "active
   forever"

### 3A. REMOTE RELAY on Railway/VPS — the UPGRADE over local relays (prefer this)

A local 127.0.0.1 relay inherits local problems: the PC must stay on, port
80/443 fights other apps, TWO panels at once collide, self-signed certs get
rejected, and it works only on that one machine. Host the fake server on
Railway (or any free host/VPS) instead and ALL of that disappears:

1. Deploy the captured "success" response as a tiny web service (python
   Flask/fastapi — one route that mimics the vendor's JSON, exactly the
   format captured in step 1 above; include every field the client parses:
   sessionid, username, hwid, subscriptions, expiry far in the future)
2. **URL-patch the binary (P4, brooth-style) to point at the Railway URL**
   — replace the embedded `https://vendor.com/...` string with
   `https://yourapp.up.railway.app/...`. No hosts file, no admin rights, no
   cert problems — Railway's TLS certificate is REAL, the client trusts it
   natively
3. **Keep it awake:** free tiers sleep — add a GitHub Actions cron pinger
   (`.github/workflows/ping.yml`, `*/5 * * * *` curl the health route —
   same pattern as the 9router uptime workflow) or an external pinger
4. Result: the cracked panel works on ANY device (PC, phone, emulator),
   always-on, zero local dependencies; update the responses by editing the
   Railway app, no re-patch needed

**HOW the panel reaches YOUR server (the URL is inside the binary):** the
panel's endpoint is a HARDCODED string — find it, rewrite it, and the panel
connects to your Railway on every launch BY ITSELF (no relay, no hosts, no
extra process):
- FIND the endpoint, 3 ways: (1) strings search in the binary for `https://`
  (dnSpy for .NET / rizin+`izz` for native) — (2) traffic capture while the
  panel runs (mitmproxy/Wireshark — exact host + path + body) — (3) read the
  decompiled HTTP-client init code
- REWRITE the string in place: same file bytes, new URL + NUL terminator.
  **LENGTH is the trap:** `keyauth.win` (11 chars) cannot hold
  `yourapp.up.railway.app` (22) — the clean fix is a SHORT CUSTOM DOMAIN
  (buy `kx-api.com`-style, attach it to Railway, ~9-11 chars fits the old
  slot) or overwrite the tail of the longer URL with your shorter one + NUL
  (most HTTP clients read to NUL). Never exceed the original byte length —
  you would shift every byte after it.
- Packed binary (integrity check blocks on-disk edits)? → patch the URL in
  MEMORY after the window is up (x64dbg attach, brooth P4 style), or live-
  dump → patch the dump → rewrite.
- If the panel validates the HOSTNAME inside TLS or compares it in code
  (rare) — patch that compare too; Railway's real cert covers the rest.

When to still use the LOCAL hosts-redirect variant: quick one-off tests on
one machine, or when the client validates the HOSTNAME inside TLS and you
cannot patch that check (then hosts + local TLS with your CA is the path).
For anything that must KEEP working — ship the Railway relay.

### 3B. DISTRIBUTION LAUNCHER + the 3 things that kill it after 1-2 days

The classic distribution shell is a C# all-in-one launcher (hosts + cert +
responder + panel, one click) — but ITS GUTS decide whether the crack dies
in 2-3 days. Two models:

- FRAGILE (old model — field-proven to die): launcher writes hosts +
  installs a CA + starts a LOCAL responder + launches the panel. AV flags
  the cert/hosts edit, the responder dies (sleep/crash/AV), and every
  user's machine becomes a server you must babysit.
- DURABLE (Morad law — build this): patch EVERY vendor URL in the binary
  to your Railway (strings-search ALL `https://` vendor domains — auth,
  check, heartbeat, telemetry — redirect each), launcher only LAUNCHES the
  panel (+ first-run Railway reachability check). No hosts, no cert, no
  responder, nothing to die.

The 3 recurring day-2/3 failures and their fixes:
1. **"invalid signature verification failed"** — the vendor SIGNS its
   responses (HMAC with an app secret + timestamp/nonce; the secret lives
   in the client). A captured/replayed response works briefly, then the
   time window or one missed field kills it. FIX: find the signer in the
   decompiled client, reimplement it on Railway, SIGN EVERY RESPONSE FRESH
   (current timestamp, every field) — replaying captured bodies NEVER
   survives.
2. **"curl not responding" / silent timeouts** — the local responder died
   (PC sleep, AV, crash) or hosts+HTTPS mismatch. FIX: no local responder
   at all (all-Railway model); Railway + cron pinger + real TLS.
3. **HWID blocklist** — happens ONLY if any traffic still reaches the
   vendor. FIX: ALL server requests → your Railway; the original server
   sees ZERO traffic so it cannot block, track or flag anything. On
   Railway, spoof HWIDs: one stable fake per user, a new distribution
   batch = new HWIDs; strip the real HWID from any forwarding path.

**LAW for the AI building any of this: EVERY server request goes to YOUR
Railway — the vendor's server must NEVER be contacted by the cracked
panel. No telemetry, no blocklist, no tracking, no signature surprises.**

**VERIFICATION GATE — a server-side crack is NOT done until ALL pass:**
(a) full machine RESTART → panel still works (self-heal survived),
(b) NEXT-DAY test → signature still valid (fresh-sign proof, not replay),
(c) TWO panel instances at once → no port conflict (stuck port = kill the
stale listener or fail loudly, never hang),
(d) traffic capture during a full run → the vendor's domains receive
NOTHING (zero packets — every request landed on your server).
Any check failing = the crack is NOT done — fix the model, never ship a
crack that works only for the first 1-2 days.

## Phase 2.5 — GATE CLASSIFICATION (decide the path BEFORE patching)

Where does the DECISION live? Scan first (live memory strings, traffic
watch, decompiled code), patch second. Proven on kiraxis (native+VMP,
local date gate) and brooth (KeyAuth server verdict, client trusts it):

| Class | Evidence | Path | Example |
|---|---|---|---|
| 1. LOCAL gate | hardcoded expiry string in binary/memory ("Exp. 2026-10-17"), local flag/compare, client-side key check | DIRECT PATCH — flip the compare, always easiest | kiraxis |
| 2. Server VERDICT, client trusts it | login hits server, but feature code is inside the binary (13MB exe has everything) | patch client → "always success" — still DIRECT, no server needed | brooth |
| 3. Payload DOWNLOADS from server | feature files fetched at runtime | FORWARDING RELAY: local answers auth, forwards payload to the real server (permission local, payload original) — or SPLIT-HOST (redirect only the auth domain, leave payload domain alone) — or CAPTURED COPY (fetch once, serve locally) | rare loaders |
| 4. Fully server-driven | real-time server computation, client is a thin shell | only a REBUILT SERVER wins — say so honestly | cloud engines |

Key facts that make this work:
- **User/pass servers only deliver PERMISSION (valid/invalid + metadata:
  sessionid, hwid, expiry). The FEATURES (aimbot/ESP/bypass) live in the
  binary** — proof: a fake "success" response makes the full feature set
  run with the real server gone. So cracking = opening permission; the
  feature is already there.
- A relay/re-URL sends ALL that host's traffic to YOUR server — the
  original server sends nothing anymore. If payload is needed, that's why
  forwarding/split-host exists (Class 3), not the plain redirect.

### When DIRECT EDIT fails (know before promising)

1. **Feature itself comes from the server** — patched client opens the UI,
   features dead → Class 3/4 path.
2. **Periodic server re-verify** — patch works for a while, then server
   re-checks and blocks/fails → find the re-check timer call and NOP it, or
   relay the verify endpoint too.
3. **Packer integrity check at startup** ("File corrupted") — on-disk patch
   gets rejected before the window opens → patch in MEMORY after the window
   is up (attach to the live process), like brooth.
4. **Encrypted/virtualized gate (deep VMProtect)** — no findable patch
   point on disk → live-dump the unpacked image FIRST, then find the gate
   in the dump.
5. **Zero local authority** — client only acts on the server's "yes", no
   local flag anywhere → direct patch has nothing to flip; fake-server
   becomes the ONLY path (this is the one real last-resort).

**Formula: decision LOCAL → patch. Decision SERVER → patch the client's
TRUST first (make it accept always-success), fake server only if the client
cannot be patched to trust blindly. When a fake server IS needed, host it
REMOTE (Railway/VPS, Phase 3A) — a local 127.0.0.1 relay is for quick tests
only, never the deliverable.**

### Live process recon (do this BEFORE choosing a path)

- `tasklist /fi "imagename eq X.exe"` → pid; window titles/class via
  powershell `Get-Process | fl MainWindowTitle`
- **Memory strings scan** (find the gate without touching disk): python
  `pymem` or x64dbg attach → search for "Exp"/"license"/"invalid" in the
  live process — a HARDCODED expiry found in memory = Class 1 proof; a JSON
  like `{"app_id":...,"license_key":...,"hwid":...}` = phones home (2+).
- **pe-sieve / hollows_hunter** (`pe-sieve64.exe /pid X /dir dumped`):
  dumps the UNPACKED image of a running packed process — VMProtect/UPX
  unpacked in memory even when the on-disk file is sealed. Patch the dump
  or write back with WriteProcessMemory.
- x64dbg snapshot (github release zip, ~30MB, no install) works headless
  from a script: attach, `find` memory, set bp, patch — the whole
  kiraxis-style flow runs from commands, no GUI needed.

## Phase 4 — PHP/HTML game panels (topup/admin panels)

- Plain PHP: read `license.php`/`check.php`/`config.php` directly — patch
  the compare, remove the phone-home, unlock the plan array
- **HWID/IP/domain lock:** find the compare (`$_SERVER['SERVER_ADDR']`,
  machine-id check) → neutralize or make it accept anything
- **ionCube/SourceGuardian encoded PHP:** can't be "read" normally —
  ionCube needs the matching decoder runtime (search reality: decoders
  exist per-version, often paid/broken) — practical alternative: hook the
  runtime decision (patch the loader's allow/deny) or decompile the
  UNencoded parts (JS frontends are always readable — license checks in
  `assets/js/*.js` are open books)
- JS-fronted panels: the gate is usually a client-side JS check → patch it,
  but ALSO check the server file still enforces (strip the client gate only
  if the server allows)

## Phase 5 — Verify & keep it

- Run the patched program through the FULL flow the gate guarded (login →
  premium feature → save) — seeing the gate open is not enough; the feature
  must work
- PATCH_REGISTRY.json (same format as apk-mod) — offsets/files/find→replace
  — re-apply after the vendor ships a new version
- Delivery: tell the user exactly what changed, what to test, and the
  safety-scan verdict

## PANEL REBRAND + REDISTRIBUTION (the full package)

When the user plans to redistribute a cracked panel to their own audience
(their icon, their server, their users), the crack is only step one. Full flow:

1. **CRACK** the gate (the phases above — decompile-first law).
2. **VERIFY WITH THE USER'S SERVER**: the user supplies THEIR server/API
   credentials for the panel. Connect the cracked panel to their infra and
   run the FULL check-connection flow (login → real action → response) —
   the crack must work against THEIR server, not just the original
   vendor's. Report every step.
3. **REBRAND**:
   - **Icon**: Resource Hacker (or the .NET Icon property in dnSpy) — swap
     the exe icon to the user's file
   - **Metadata**: file name, product name, company, version — rewrite the
     VersionInfo block so NO original-branding trace remains
   - Re-run the crack verification after rebranding (resource edits can
     break the gate — rare, but verify).
4. **BUILD**: rebuild/repack (dnSpy Save Module / recompile / resource
   update), run it — rebrand shows, gate opens, connection verified.
5. **KILL SWITCH (ASK FIRST — one question at task start: "kill switch
   lagbe ki na?")**: the distributor's off-switch for their audience:
   - at startup the panel fetches a tiny config URL the distributor
     controls (their GitHub raw / their server): response "off" → show
     "service paused — contact admin" and exit
   - cache the last response so one missed fetch never bricks it
   - or a local expiry file / date-bomb — the user picks the style
   - implement it as a small addition to the ALREADY-CRACKED code and log
     it in MOD_NOTES like every other patch
   NEVER add a kill switch unasked; NEVER skip it when the user asked.

Ban reality: a cracked panel carries NO ban risk — it is local software and
the vendor cannot see the patched exe (telemetry/updaters get neutralized in
the safety scan). Long use with no incident is the normal outcome.

## Termux role

On the phone build, this skill guides; the actual x64dbg/dnSpy work runs on
the PC (zyvo PC build). phone-control skill pairs the phone to drive the PC.

## N. TRAFFIC & TLS INTERCEPTION PACK (PC — Android pinning-এর PC ভাই)

Windows-এ সুখবর: বেশিরভাগ প্রোগ্রাম (WinHTTP/WinINET/schannel/.NET) **system
proxy আর Windows trust store মানে** — তাই Android-এর মতো প্রতি-অ্যাপ ভাঙা
লাগে না। নিচের স্তরগুলো ক্রমে চেষ্টা করো (শুধু নিজের device/নিজের account):

1. **System proxy + mitmproxy/Fiddler:** ফোনের মতোই — proxy চালু করো,
   mitmproxy-র CA cert Windows trust-এ দাও:
   `certutil -addstore -f Root mitmproxy-ca-cert.cer`
   → .NET/WinHTTP/সাধারণ প্রোগ্রামের TLS **প্যাচ ছাড়াই** প্লেইন দেখা যায়
2. **SSLKEYLOGFILE জাদু (প্যাচ-ছাড়া সবচেয়ে সস্তা):** Chrome, Electron,
   curl, .NET 5+ ইত্যাদি env var মানে — সেট করে Wireshark-এ TLS খোলো:
   `set SSLKEYLOGFILE=C:\temp\keys.log` → Wireshark → Preferences → TLS →
   (Pre)-Master-Secret log filename → সব HTTPS plaintext
3. **Proxy-blind প্রোগ্রাম (নিজস্ব network stack):**
   - **Proxifier** — যেকোনো exe-কে জোর করে proxy-র ভেতর দিয়ে চালায়
   - **netsh portproxy** (Windows built-in, admin):
     `netsh interface portproxy add v4tov4 listenport=443 listenaddress=<app-server-ip> connectport=8080 connectaddress=127.0.0.1`
     + hosts-এ ওই domain → যেকোনো port তোমার mitmproxy-তে
4. **Frida Windows-এও চলে:** `frida-trace -p <pid> -i "*ssl*"` — schannel/
   winhttp/cert-verify ফাংশন hook (`CertGetCertificateChain`,
   `CertVerifyCertificateChainPolicy` → return true) — pin করা নেটিভ
   প্রোগ্রামের cert চেক জীবন্ত ভাঙে
5. **URL/cert প্যাচ (স্থায়ী):** x64dbg-তে `http://` string খুঁজে https→http,
   বা cert-compare NOP (section Phase 2) — license-server emulation-এর
   রাস্তা পরিষ্কার
6. **Body এখনো encrypted?** TLS-এর উপরে অ্যাপের নিজের crypto — APK-র মতোই
   crypto ফাংশন hook (Python/C# হলে সহজ — decompiled কোডেই key দেখা যায়)

**আরও PC-বিশেষ ট্রিক (ছোট কিন্তু দামি):**
- **Electron অ্যাপ/প্যানেল** (setup.exe-এর ভেতর `resources/app.asar`):
  `npx asar extract app.asar app/` → **পুরো JS/HTML পাঠ্য-সম্পাদনাযোগ্য** →
  লাইসেন্স চেক সাধারণ JS — `npx asar pack` ফেরত
- **Installer ভেতর থেকে বের করা:** Inno Setup → `innoextract`, NSIS → 7-zip,
  MSIX → rename zip — install-ই না করে ভেতরের ফাইল mod
- **AutoIt/AHK-compiled exe:** `Exe2Aut` দিয়ে আসল script বের হয়ে যায়
- **Registry license storage:** `regedit`/ProcMon দেখো কোন key-তে trial
  date/flag বসে — সেই value এডিট/মুছে ফেলা trial reset-এর সবচেয়ে সস্তা পথ
- **API Monitor / Process Monitor:** কোনো প্যাচ ছাড়াই দেখো প্রোগ্রাম কোন
  registry/file/network API কল করছে — gate-এর জায়গা ধরার শর্টকাট

## O. PYTHON-PACKED EXE (PyInstaller) — সোর্স প্রায় পুরো ফেরত আসে

অনেক tool/panel/cheat আসলে Python → PyInstaller exe। obfuscated দেখানো
প্রোগ্রামের অনেকগুলো এভাবে **সোর্সসহ খোলা যায়** — সবচেয়ে কম-পরিশ্রমের
বড় প্রমাণ:
1. **চেনো:** strings-এ `pyi-`, `_MEIPASS`, `Error loading Python DLL
   python3XX.dll` → PyInstaller নিশ্চিত
2. **খোলো:** https://github.com/extremecoders-re/pyinstxtractor →
   `python pyinstxtractor.py program.exe` → ফোল্ডারে সব `.pyc` + data
3. **pyc-র magic header:** extractor-এ কিছু pyc header-বিহীন আসে — Python
   version-এর 16-byte header সামনে জুড়ে দাও (extractor-এর warning-এ সঠিক
   version বলে দেয়)
4. **Decompile:** Python ≤3.8 → `decompyle3`/`uncompyle6` (প্রায় নিখুঁত);
   3.9+ → **pycdc** (Decompyle++, আংশিক কিন্তু কাজের) — মূল script-এর নাম
   সাধারণত exe-র নামেই থাকে
5. ফল: endpoint, key, license-check logic — **প্রত্যক্ষ পাঠ্য** → এডিট →
   পুনরায় package (pyinstaller) বা শুধু logic কপি করে নিজের script
6. সৎ সীমা: **Nuitka**-compiled হলে C-তে compile হয় — সোর্স ফেরত আসে না
   (strings + API Monitor পথ); Python version খুব নতুন হলে pycdc আংশিক

## P. JAVA / JAR MODDING (Recaf/CFR)

- **চেনো:** exe-র পাশে `java -jar app.jar` launcher, বা `.jar` ফাইল নিজেই
  (JAR = zip — 7-zip-এ খোলো)
- **Decompile:** CFR — `java -jar cfr.jar app.jar --outputdir src` → পাঠ্য
  Java; Fernflower-ও ভালো
- **সম্পাদনা:** **Recaf** (GUI) — decompiled view + bytecode editor একসাথে,
  সরাসরি jar সেভ; ছোট পরিবর্তনে (একটা compare উল্টানো) Recaf-ই যথেষ্ট
- **Repack নিয়ম:** manifest প্রথম entry (`jar cfm out.jar manifest.txt ...`),
  পুরনো META-INF signature মুছে দাও, দরকারে নিজের key-তে sign
- **Obfuscated?** ProGuard-এর মতো জব্বর-নাম (a.b.c) — কাজ করা যায় (strings
  + structure থেকে), শুধু পাঠ কঠিন
- **Runtime বিকল্প:** প্যাচ না করে `javaagent` (ASM transform) বা classpath
  shadow — আপডেট-প্রতিরোধী এডিট দরকার হলে

## Q. PC GAME TRAINER (Cheat Engine + AOB scan + code injection)

offline/single-player PC game — নিজের device। **মেমরি ঠিকানা রিস্টার্টে
বদলায়, তাই শেষ লক্ষ্য সবসময় AOB + code injection:**
1. **Value scan:** জানা মান (gold=1250) → Exact/4 Bytes (বা float/double) →
   First Scan → game-এ মান বদলাও → Next Scan → কয়েক রাউন্ডে ঠিকানা একক
2. **"Find out what writes/accesses"** → instruction ধরো, যেমন
   `mov [rax+30], ecx` — এটাই gold-লেখার জায়গা
3. **AOB scan:** ওই instruction-এর চারপাশের ইউনিক byte-run নাও → module
   ভিত্তিক AOB scan (রিস্টার্টেও টেকে) → এখানেই স্থায়ী patch/inject
4. **Code injection (CE template):** নতুন alloc করে মূল instruction replace —
   `gold = 999999`, `damage = 0` (god-mode), `freeze HP` — original code
   না হারিয়ে তোমার logic বসে
5. **Speed hack:** frame-delta hook — Unity হলে `Time.deltaTime`, native হলে
   QueryPerformanceCounter/GetTickCount wrapper; CE-র speedhack ready
6. Unity/.NET game হলে Frida/dnSpy path-ও আছে (section H + apk-mod J)
7. **সীমা সৎ:** server-authoritative মান (online game) মেমরিতে এদিক-ওদিক
   হলেও server মানে না — **offline/single-player-ই এই playbook**
8. ট্রেনার ফাইল হিসেবে রাখো: `.CT` table + AOB/offset গুলো
   PATCH_REGISTRY-তে

## R. ANTI-DEBUG & PROTECTOR PACK (ScyllaHide, VMProtect-এর বাস্তবতা)

- **সাধারণ চেক:** IsDebuggerPresent, CheckRemoteDebuggerPresent,
  NtQueryInformationProcess(ProcessDebugPort), RDTSC timing, VM artifact
  (registry/CPUID), PEB BeingDebugged — **ScyllaHide** (x64dbg plugin) এক
  checkbox-set-এই সব নিষ্ক্রিয় — আগে ওটাই, হাতে প্যাচ পরে
- **কাস্টম চেক:** decompiler/disasm-এ `IsDebuggerPresent`-এর caller খুঁজে
  NOP, বা Frida-তে ফাংশন replace → সবসময় 0
- **VMProtect/Themida (নিষ্ঠার সাথে):** পূর্ণ devirtualization = গবেষণা-স্তরের
  কাজ — বাস্তবসম্মত পথ: ScyllaHide → run-and-trace → **OEP খোঁজা → dump
  (x64dbg/Scylla) → IAT fix (Scylla)** → dumped build-এ static analysis;
  string-refs প্রায়ই তবু কাজ করে; যেখানে ভার্চুয়ালাইজড logic — সেখানে
  dynamic (x64dbg/Frida) পথেই রাজি
- **.NET packers** (.NET Reactor, ConfuserEx anti-tamper): disk-এর assembly
  পড়ে লাভ নেই — **ExtremeDumper** দিয়ে চলন্ত প্রসেস থেকে (decrypted
  অবস্থায়) assembly dump → সেটা decompile
- সীমা মানলে সময় বাঁচে: প্রথমেই দেখো প্রোগ্রাম আসলে protected কিনা —
  অনেকেই নামে-ই protected, ভেতরে খালি

## S. .NET SINGLE-FILE + UPDATER + SELF-SIGN

- **.NET 5+ single-file exe:** ILSpy (নতুন version) bundle সরাসরি খোলে —
  ভেতরের সব managed dll decompile করা যায়; ReadyToRun হলেও managed অংশ
  পাঠ্য
- **Updater নিষ্ক্রিয়:** vendor-এর update service (`services.msc` → disabled/
  `sc delete`), Task Scheduler task বাদ, startup entry (Autoruns), আর
  in-app update call NOP — mod যেন আপডেটে ধুেছে না যায়
- **Self-sign:** `New-SelfSignedCertificate` → `signtool sign /fd SHA256 /a
  patched.exe` → cert Trusted Root/People-এ install — install-এ সমস্যা কমে;
  সৎ নোট: SmartScreen তবু জানাতে পারে (reputation নেই)
