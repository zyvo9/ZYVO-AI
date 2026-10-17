---
name: pc-mod
description: Windows PC exe/panel/soft modding playbook — gate classification (local / server-verdict / public-key pubkey-swap / server-payload / server-driven), .NET decompile (ilspycmd, dnSpy, de4dot), native debug (x64dbg, rizin), server-side cracks via the relay lifecycle (TEST locally → deliver on the user's own server), license/keygen/HWID/trial work, rebrand + redistribution. Use when the user asks to crack/patch/mod a PC program, panel, exe, dll, remove num-pass/validity/HWID lock, extend trial, bypass license check, make a keygen, rebrand a panel, or says "panel crack koro", "exe mod", "validity barao".
---

# PC Exe / Panel Mod — TASK FLOW

This file is a CHECKLIST and GUARDRAIL set — not a script. Use your full
expertise: if you know a better tool, path or idea, say it in one line and
take it. What is fixed: the ORDER below, the safety rules, and the
verification gates. Everything else is your craft.

## Guardrails (always)

1. SAFETY SCAN FIRST: malware/miner traps hide in cracked panels — check
   imports/strings, first run network-off or restore point, neutralize
   traps before cracking. Same-name files are a classic trick.
2. `.bak` the original; patch a copy. Remote-kill/telemetry → neutralize.
3. PROOF: gate opens AND the guarded feature works. Unverified = not done.
4. MOD_NOTES.md: goal on top, every patch, a NOW line — compaction →
   re-read and continue silently.
5. Known-panel gotchas may exist in the owner's private playbook
   (vault 05 Playbooks) — check it for this target.

## Step 1 — Triage + CLASSIFY (one scan decides the path)

Identify the binary (.NET / packed / native / PHP-web / Electron), then
classify WHERE the gate decision lives — this picks the whole path:

| Class | Signature | Path |
|---|---|---|
| 1. LOCAL gate | hardcoded expiry/flag/compare in binary or memory | DIRECT PATCH — flip it |
| 2. Server VERDICT, client trusts it | login calls server, features live in the binary | patch client trust → always-success |
| 2P. Public-key SIGNED response | verify uses vendor's public key — his signature cannot be forged | PUBKEY-SWAP (same-length in-place: RSA-2048 256B / P-256 65B / Ed25519 32B) → your server signs fresh; or NOP the verify call; replaying captured signed bodies always dies on timestamp/nonce |
| 3. Payload downloads from server | features fetched at runtime | forwarding server / split-host / captured copy |
| 4. Fully server-driven | client is a thin shell | say honestly: only a rebuilt server wins |

Sign-vs-forge rule: HMAC (symmetric) = secret lives in the client →
extract → mint fresh responses forever. Public-key = only swap/NOP.
Never promise a responder on 2P without the swap. Check whether the
pubkey is server-delivered (init/config) — then zero patching.

## Step 2 — CRACK per class

- Direct paths (1, 2): decompile (ilspycmd/dnSpy/de4dot) or live-debug
  (x64dbg/rizin) → find the compare → smallest patch (one flip beats a
  rewrite) → verify.
- Packed/VMProtect: on-disk is sealed → dump the running process
  (pe-sieve/x64dbg) → find the gate in the dump → memory-patch after the
  window is up (integrity checks fire early — poll for the window first).
- Server paths (2P, 3, 4): go to Step 3.

## Step 3 — SERVER ROUTE (the lifecycle)

1. TEST with a quick local relay (hosts + tiny responder): capture the
   exact request/response schema until E2E works locally. Encrypted +
   signed body → proxy the real traffic once + Frida hook the client's
   crypto/verify functions to capture the decrypted schema, the verify
   call site and the embedded pubkey (feeds the 2P swap).
2. BUILD the deliverable — the user's own server (Railway/VPS):
   deploy the proven schema, sign every response FRESH (own keypair for
   2P / extracted HMAC secret), URL-patch EVERY vendor domain in the
   binary to it (short custom domain, length-safe swap), add a cron
   pinger.
3. DELETE the test relay — its logic shipped, its body goes.
4. Deliverable form: online launcher (just launches the panel) or offline
   launcher (embedded responder, fresh-signed, self-heals hosts/cert/
   port every launch). Both valid — fresh signing + self-heal decides.
5. LAW: every server request goes to the USER'S infrastructure — the
   vendor's server sees zero traffic (no blocklist, no telemetry).

## Step 4 — VERIFY GATE (all must pass)

(a) machine restart → still works, (b) next-day → signature still valid
(fresh-sign, not replay), (c) two instances → no port conflict,
(d) traffic capture → vendor domains receive zero packets.
Any fail = not done — fix the model, never ship a 1-2-day crack.

## Step 5 — REBRAND + deliver

- Icon (Resource Hacker) + metadata VersionInfo (zero brand trace);
  in-app drawn strings may be protected (ImGui/heap walls) — OS title +
  labels are the safe win.
- Kill switch for redistribution: ASK FIRST ("kill switch lagbe ki na?"),
  implement on the already-cracked code, cache the last response.
- Deliver: what changed, what to test, safety verdict. PATCH_REGISTRY +
  MOD_NOTES for update survival.

## Tool cheatsheet (one line each)

.NET: ilspycmd / dnSpy live edit / de4dot · Packed: upx -d, then re-triage ·
Native: x64dbg strings→compare→patch, rizin static · Dump: pe-sieve /
hollows_hunter + Scylla IAT fix · PyInstaller: pyinstxtractor + pycdc ·
JAR: Recaf/CFR · Electron: asar extract/pack · AutoIt: Exe2Aut ·
Trainer: CE AOB scan + code injection (offline games only) ·
Anti-debug: ScyllaHide · Traffic: mitmproxy CA, SSLKEYLOGFILE+Wireshark,
Proxifier/netsh portproxy · Registry: ProcMon finds stored trial state ·
Installer extraction: innoextract / 7-zip / MSIX-as-zip

## Termux role

Phone guides, PC does the work. phone-control skill pairs them.
