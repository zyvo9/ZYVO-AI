---
name: pc-mod
description: Windows PC exe/panel/soft modding playbook — gate classification FIRST (local / server-verdict / public-key-signed pubkey-swap / server-payload / server-driven), .NET decompile and patch (ilspycmd, dnSpy, de4dot), native live debugging (x64dbg, rizin), keygen from validation math, server-side cracks via the relay lifecycle (TEST with a local relay → BUILD the deliverable as a Railway server or an embedded launcher responder — fresh signing, self-healing), PHP/HTML game-panel license cracks (HWID/IP/domain lock, ionCube reality), UPX/VMProtect dump workflows, safety scan for malware traps. Use when the user asks to crack/patch/mod a PC program, panel, exe, dll, remove num-pass/validity/HWID lock, extend trial, bypass license check, make a keygen, rebrand a panel, or says "panel crack koro", "exe mod", "validity barao".
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
6. **ANALYZE-FIRST IS THE LAW (classify before you patch):** never pick a
   path blind — decompile/dump/scan until you know WHERE the decision
   lives (Phase 0.5 gate classification). Building an overlay/wrapper
   BEFORE analyzing = failed crack (you paper over gates you never saw).
   Faking the server is NOT banned — it is a LIFECYCLE (Phase 3.0): a
   quick local relay proves the schema (TEST), then its proven logic
   ships inside a deliverable — the Railway server (3A, online) or the
   embedded launcher responder (3B, offline) — always with FRESH signing
   and SELF-HEALING. What kills cracks is a LOOSE relay left running as
   the product: unmanaged responder scripts, replayed signatures,
   hosts/cert edits nothing repairs — works in the morning, dead by
   evening. Same for web panels: edit the real PHP/source, never paper
   over it.
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

## Phase 0.5 — GATE CLASSIFICATION (decide the path BEFORE patching — READ THIS FIRST)

Where does the DECISION live? Scan first (live memory strings, traffic
watch, decompiled code), patch second. Proven on kiraxis (native+VMP,
local date gate) and brooth (KeyAuth server verdict, client trusts it):

| Class | Evidence | Path | Example |
|---|---|---|---|
| 1. LOCAL gate | hardcoded expiry string in binary/memory ("Exp. 2026-10-17"), local flag/compare, client-side key check | DIRECT PATCH — flip the compare, always easiest | kiraxis |
| 2. Server VERDICT, client trusts it | login hits server, but feature code is inside the binary (13MB exe has everything) | patch client → "always success" — still DIRECT, no server needed | brooth |
| 2P. Server verdict, PUBLIC-KEY SIGNED response | verify uses the vendor's public key; you CANNOT forge his signature (his private key stays on his server) | PUBKEY-SWAP: replace the client's EMBEDDED public key with YOUR public key (same-length in-place byte swap — RSA-2048 modulus 256B, ECDSA P-256 65B, Ed25519 32B) → your server signs every response fresh with your private key. First CHECK where the pubkey lives: server-delivered (init/config response) = just serve YOUR pubkey, zero patching. Alternative: NOP the client's verify call. Replaying his captured signed bodies ALWAYS dies on timestamp/nonce | modern auth'd panels |
| 3. Payload DOWNLOADS from server | feature files fetched at runtime | FORWARDING server: yours answers auth, forwards payload to the real server — or SPLIT-HOST (redirect only the auth domain, leave the payload domain alone) — or CAPTURED COPY (fetch once, serve locally) | rare loaders |
| 4. Fully server-driven | real-time server computation, client is a thin shell | only a REBUILT SERVER wins — say so honestly | cloud engines |

Key facts that make this work:
- **User/pass servers only deliver PERMISSION (valid/invalid + metadata:
  sessionid, hwid, expiry). The FEATURES (aimbot/ESP/bypass) live in the
  binary** — proof: a fake "success" response makes the full feature set
  run with the real server gone. So cracking = opening permission; the
  feature is already there.
- **Symmetric vs asymmetric signing decides what you can forge:** HMAC
  (symmetric) = the secret lives in the client → extract it → you can
  mint fresh valid responses forever (kiraxis path). Public-key
  (asymmetric) = client holds only the public key → forging is
  impossible → pubkey-swap or verify-NOP (class 2P) is the ONLY way a
  responder of your own can ever work. Never promise an embedded/Railway
  responder on a 2P gate without the swap.
- A URL re-point sends ALL that host's traffic to YOUR server — the
  original server sends nothing anymore. If payload is needed, that's
  why forwarding/split-host exists (Class 3), not the plain redirect.

### When DIRECT EDIT fails (know before promising)

1. **Feature itself comes from the server** — patched client opens the UI,
   features dead → Class 3/4 path.
2. **Periodic server re-verify** — patch works for a while, then server
   re-checks and blocks/fails → find the re-check timer call and NOP it, or
   serve the verify endpoint on your server too.
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
cannot be patched to trust blindly. When a fake server IS needed, follow
the LIFECYCLE (Phase 3.0): TEST with a quick local relay, then BUILD the
deliverable as either the Railway server (online, Phase 3A) or the
embedded-responder launcher (offline, Phase 3B) — the loose relay itself
never ships, only its logic does.**

### Live process recon (do this BEFORE choosing a path)

- `tasklist /fi "imagename eq X.exe"` → pid; window titles/class via
  powershell `Get-Process | fl MainWindowTitle`
- **Memory strings scan** (find the gate without touching disk): python
  `pymem` or x64dbg attach → search for "Exp"/"license"/"invalid" in the
  live process — a HARDCODED expiry found in memory = Class 1 proof; a JSON
  like `{"app_id":...,"license_key":...,"hwid":...}` = phones home (2+).
  Windows API trap (kiraxis-proven): PowerShell P/Invoke needs the
  4-PARAMETER VirtualQueryEx (3-param returns 0 regions) and OpenProcess
  access flags 0x08|0x10|0x20 (+0x400 if needed); the window may take
  5-10s to appear → retry loop until it does.
- **pe-sieve / hollows_hunter** (`pe-sieve64.exe /pid X /dir dumped`):
  dumps the UNPACKED image of a running packed process — VMProtect/UPX
  unpacked in memory even when the on-disk file is sealed. Patch the dump
  or write back with WriteProcessMemory.
- x64dbg snapshot (github release zip, ~30MB, no install) works headless
  from a script: attach, `find` memory, set bp, patch — the whole
  kiraxis-style flow runs from commands, no GUI needed.

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

## Phase 3 — Server-side gates: TEST relay first, then a DELIVERABLE

The exe phones home; the response can be faked — but only through the
LIFECYCLE (3.0 below): what you build here is the PHASE-T TEST relay
(one machine, throwaway). Its job is to learn the exact schema; the
deliverable then comes from 3A (Railway server, online) or 3B (embedded
launcher responder, offline).

TEST setup (quick, one machine):
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
5. Response encrypted + public-key signed you cannot replay? Use this
   phase as RESEARCH: proxy the real traffic once + Frida hook on the
   client's crypto/verify functions to capture the DECRYPTED schema and
   locate the verify call + embedded pubkey — that is exactly what the
   pubkey-swap (Phase 0.5, class 2P) needs.

### 3.0 THE RELAY LIFECYCLE — TEST with it, BUILD without it

The relay is a TOOL, used in the right phase — never "never used":

**PHASE T — TEST (relay stays):** classify the gate (memory strings,
traffic watch). For a server-verdict gate, stand up a QUICK local relay
(hosts redirect + small responder) and PROVE the hypothesis: fake
"success" → panel opens? → capture and refine the exact response format
(JSON fields, HMAC math) until it works E2E locally. The relay here is
your lab instrument — it teaches you what the server says and what the
client believes.

**PHASE B — BUILD (relay logic migrates, relay body is thrown away):**
take the PROVEN response logic from the test relay and move it into the
PERMANENT home, then DELETE the loose relay:
- ONLINE deliverable: the logic becomes a Railway/VPS service → URL-patch
  the binary to it (Phase 3A) → remove the hosts entry and kill the dev
  responder
- OFFLINE deliverable: the logic becomes an EMBEDDED responder inside the
  launcher (Phase 3B, 9MProfessor-style — hosts/cert/responder managed
  automatically by the exe itself) → the separate test scripts are deleted
Either way the RUNNING product never depends on a loose relay process —
the relay's BRAIN ships inside the product, the relay's BODY is removed.

**PHASE V — VERIFY without the relay:** machine restart, next-day
signature, two instances, zero vendor traffic (the gate in 3B). Only then
is the crack done.

### 3A. DELIVERABLE (ONLINE): YOUR OWN SERVER on Railway/VPS

This is the class-2P/2/3 online deliverable — NOT a relay: your server
IS the license server. No hosts file, no admin rights, no cert problems,
no responder process on the user's PC; works on ANY device, always-on:

1. Deploy the PROVEN schema from the test phase as a tiny web service
   (python Flask/fastapi — routes that mimic the vendor's JSON exactly;
   every field the client parses: sessionid, username, hwid,
   subscriptions, expiry far in the future)
2. **For class-2P gates (public-key signed): swap the pubkey** — replace
   the client's EMBEDDED vendor public key with YOUR public key
   (same-length in-place byte swap) and SIGN EVERY RESPONSE FRESH with
   your private key (see Phase 0.5 class 2P). For HMAC gates: implement
   the client's signer server-side, sign fresh (never replay)
3. **URL-patch the binary** — replace the embedded `https://vendor.com/...`
   with `https://yourapp.up.railway.app/...` (LENGTH trap below)
4. **Keep it awake:** free tiers sleep — add a GitHub Actions cron pinger
   (`.github/workflows/ping.yml`, `*/5 * * * *` curl the health route —
   same pattern as the 9router uptime workflow) or an external pinger
5. Result: the cracked panel works on ANY device (PC, phone, emulator),
   always-on, zero local dependencies; update responses/keys by editing
   the Railway app, no re-patch needed

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

When to still use the LOCAL hosts-redirect variant: the PHASE T test relay
(fast hypothesis proof), and one real deliverable case — when the client
validates the HOSTNAME inside TLS and you cannot patch that check (then
hosts + local TLS with your CA is the path). Otherwise the ONLINE
deliverable ships as your Railway server.

### 3B. DISTRIBUTION LAUNCHER + the 3 things that kill it after 1-2 days

The classic distribution shell is a C# all-in-one launcher (hosts + cert +
responder + panel, one click) — both models below are VALID deliverables;
what decides survival is FRESH SIGNING + SELF-HEALING, not which model:

- OFFLINE model (9MProfessor-proven, no server needed): launcher writes
  hosts + installs its own CA + runs an EMBEDDED TLS responder + launches
  the panel. Survives when: every response is signed FRESH (never
  replayed), and the launcher SELF-HEALS on every run (re-adds hosts entry
  if AV removed it, re-checks the cert, restarts the responder thread,
  checks the port is free before binding). Fully offline — works with no
  internet at all. HMAC gates: the extracted secret lives in the launcher.
  2P (public-key) gates: do the pubkey-swap in the panel first, then the
  launcher signs with ITS OWN private key (same secret-exposure class as
  HMAC — acceptable per the user's choice).
- ONLINE model (all-Railway — no hosts/cert/responder on the user's PC):
  patch EVERY vendor URL in the binary to your Railway (strings-search ALL
  `https://` vendor domains — auth, check, heartbeat, telemetry — redirect
  each), launcher only LAUNCHES the panel (+ first-run reachability
  check). Nothing on the user's machine to babysit; keys/tiers editable
  centrally.
- What ACTUALLY dies in 1-2 days is neither model itself — it is a LOOSE
  relay setup: replayed captured signatures, an unmanaged responder script
  that dies (sleep/crash/AV), or manual hosts/cert edits with no self-heal.

The 3 recurring day-2/3 failures and their fixes:
1. **"invalid signature verification failed"** — the vendor SIGNS its
   responses (HMAC with an app secret + timestamp/nonce; the secret lives
   in the client). A captured/replayed response works briefly, then the
   time window or one missed field kills it. FIX: find the signer in the
   decompiled client, reimplement it on Railway, SIGN EVERY RESPONSE FRESH
   (current timestamp, every field) — replaying captured bodies NEVER
   survives.
2. **"curl not responding" / silent timeouts** — a responder died (PC
   sleep, AV, crash) or hosts+HTTPS mismatch. FIX by model: ONLINE — there
   IS no responder on the user's PC (all-Railway + cron pinger); OFFLINE —
   the launcher's embedded responder must self-heal (restart its thread,
   free the port, re-add hosts/cert) on every launch.
3. **HWID blocklist** — happens ONLY if any traffic still reaches the
   vendor. FIX: ALL server requests → your Railway; the original server
   sees ZERO traffic so it cannot block, track or flag anything. On
   Railway, spoof HWIDs: one stable fake per user, a new distribution
   batch = new HWIDs; strip the real HWID from any forwarding path.

**LAW for the AI building any of this: EVERY server request goes to YOUR
infrastructure — the Railway server (online model) or the embedded
responder (offline model). The vendor's server must NEVER be contacted by
the cracked panel. No telemetry, no blocklist, no tracking, no signature
surprises.**

**VERIFICATION GATE — a server-side crack is NOT done until ALL pass:**
(a) full machine RESTART → panel still works (self-heal survived),
(b) NEXT-DAY test → signature still valid (fresh-sign proof, not replay),
(c) TWO panel instances at once → no port conflict (stuck port = kill the
stale listener or fail loudly, never hang),
(d) traffic capture during a full run → the vendor's domains receive
NOTHING (zero packets — every request landed on your server).
Any check failing = the crack is NOT done — fix the model, never ship a
crack that works only for the first 1-2 days.

### 3C. YOU ARE THE VENDOR NOW — key distribution (Discord storefront)

Once YOUR server answers the panel, keys are YOURS to mint — the business
layer on top of the deliverable:

1. **Discord bot = the storefront** (runs beside your Railway server,
   sharing the signing secret): user sends the payment screenshot (SS) →
   bot shows the plan list (trial + tiers with prices) → user picks a plan
2. **Owner approval (v1, anti-fake-SS):** the bot forwards the SS + user's
   Discord ID to the owner's DM; the owner reacts ✅ → only then a key is
   minted. (Later: automatable — v1 manual keeps fake screenshots out.)
3. **Mint = the same secret the server signs with:** key format exactly
   what the responder validates (e.g. `PREFIX-YYMMDD-<sig>` — expiry INSIDE
   the key, stateless; or DB-backed keys on Railway). Bot and server MUST
   share one secret/algorithm or keys mismatch.
4. **Trial abuse control:** the free trial is once per Discord ID —
   persistent log (file/DB) keyed by Discord ID.
5. **Log every mint** (date, Discord ID, plan, key, expiry) — support and
   revocation need it.
6. Never ship the master/owner key to any user; per-user keys only.

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
