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
