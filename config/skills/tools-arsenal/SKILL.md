---
name: tools-arsenal
description: Curated on-demand tool arsenal for Termux — decryption/decoding (ciphey, blackboxprotobuf, CyberChef), reverse engineering (frida, mitmproxy, rizin, upx, binwalk), network & automation (httpx, aiohttp, jq, nmap), media (yt-dlp, ffmpeg). Use when a task needs a specialized tool — decrypt/decode something, hook or capture traffic, inspect a binary, automate requests, extract media — or before writing a complex parser by hand ("ei tool ta diye kora jay?").
---

# Tools Arsenal — দরকারি tool হাতের নাগালে (install-on-demand)

নিয়ম: **কোড লেখার আগে দেখো — এই কাজের জন্য তৈরি tool আছে কিনা।** এক লাইনের
install-এ যেটা হয়, ২০০ লাইনের parser লেখা যুদ্ধ নয়। Install করা যায় না বা
ভারী হলে কাছাকাছি বিকল্প ব্যবহার করো। সব tool নিজের কাজে — অন্যের সিস্টেমে নয়।

## Decode / Decrypt (রহস্যের টেক্সট খোলা)

| Tool | Install (Termux) | কখন |
|---|---|---|
| **ciphey** | `pip install ciphey` (ভারী — না হলে নিচের বিকল্প) | অজানা cipher/encoding **স্বয়ংক্রিয়ভাবে** চেনে-খোলে: `ciphey "ciphertext"` — base/hex/rot/caesar সন্দেহ হলে প্রথম চেষ্টা |
| **CyberChef** (online) | https://gchq.github.io/CyberChef | browser-এ drag-recipe decode — জটিল chain (b64→xor→zlib) চোখে দেখে বানানো যায়; "Magic" operation = ciphey-র মতো |
| **blackboxprotobuf** | `pip install blackboxprotobuf protobuf` | **protobuf বিনা-schema decode** — `decode_message(bytes)` দিলে field-number/type map ফেরত দেয়; wire-probing-এর সেরা বন্ধু |
| **pyCryptodome** | `pip install pycryptodome` | AES-CBC/ECB হাতে (OB55-এ যেমন: key+iv জানা থাকলে byte-exact round-trip) |
| **hashlib/hexdump** | builtin / `pip install hexdump` | দ্রুত hash, hex view |
| CyberChef (offline zip) | https://github.com/gchq/CyberChef/releases (zip build) | সম্পূর্ণ offline দরকার হলে PC-তে |

**মনে রাখো:** base85/base64/hex-এর পার্থক্য `head -c 4` magic দিয়েই বোঝা যায়;
zlib magic = `78 9C/01/DA`; gzip = `1F 8B`; protobuf = ছোট binary যেখানে
tag-byte = `(field<<3)|wiretype`।

## Reverse Engineering / Modding

| Tool | Install | কখন |
|---|---|---|
| **frida-tools** | `pip install frida-tools` + rooted ফোনে frida-server | চলন্ত অ্যাপের ফাংশন hook (crypto/network/detection) — apk-mod skill section F |
| **objection** | `pip install objection` | Frida-র উপর ready-made: `objection explore`, ssl pin disable, hooking সহজ করে |
| **mitmproxy** | `pip install mitmproxy` | অ্যাপের প্রতিটা HTTPS request/response ধরা (proxy mode) — সাথে CA cert |
| **rizin** | `pkg install rizin` | native exe/so disassemble (`rizin -A binary`) |
| **upx** | `pkg install upx` | packed exe/unpack (`upx -d`) |
| **binwalk** | `pip install binwalk` | firmware/asset-ভরা binary-তে embedded ফাইল খোঁজা + extract |
| **exiftool** | `pkg install exiftool` | ছবি/ফাইলের metadata (GPS, সফটওয়্যার, তারিখ) |
| **hbctool** | `pip install hbctool` | React Native Hermes bytecode disassemble/reassemble (`assets/index.android.bundle`) |
| **reflutter** | `pip install reflutter` | Flutter অ্যাপের snapshot patch + traffic log |
| **Il2CppDumper** (PC) | https://github.com/Il2Cpp-Paradise/Il2CppDumper | Unity IL2CPP — global-metadata.dat + libil2cpp.so → C# কাঠামো (dump.cs) |
| **dnSpy/ILSpy** (PC) | https://github.com/dnSpy/dnSpy | Unity Mono + .NET panel exe সোজা C# এডিট |
| **de4dot** (PC) | https://github.com/de4dot/de4dot | obfuscated .NET (ConfuserEx ইত্যাদি) unpack |
| **x64dbg** (PC) | https://x64dbg.com | native exe live debug — string-ref → breakpoint → JZ→JMP |
| **Wireshark** (PC) | https://www.wireshark.org | নিজের device-এর সব network traffic (SSLKEYLOGFILE দিলে TLS-ও) |
| **pyinstxtractor + pycdc** | https://github.com/extremecoders-re/pyinstxtractor · https://github.com/zrax/pycdc | PyInstaller exe খুলে Python সোর্স ফেরত |
| **Recaf/CFR** (PC) | https://github.com/Col-E/Recaf | Java JAR decompile + bytecode এডিট |
| **Cheat Engine** (PC) | https://www.cheatengine.org | PC game trainer: scan, AOB, code injection |
| **ScyllaHide/ExtremeDumper** (PC) | x64dbg plugin / https://github.com/wwh1004/ExtremeDumper | anti-anti-debug; .NET packer-এর runtime dump |
| **apktool/jadx** | PC-তে (Windows build-এ আছে) | decompile java/kotlin — ফোনে APKTool M (user) |
| **libimobiledevice/adb** | `pkg install android-tools` | adb logcat/pull — apk-mod নোট দেখো |

## Network / Automation

| Tool | Install | কখন |
|---|---|---|
| **httpx** | `pip install httpx` | async requests, HTTP/2 — batch automation |
| **aiohttp/websockets** | `pip install aiohttp websockets` | parallel worker, গেমের live socket |
| **scapy** | `pip install scapy` | raw packet তৈরি/পড়া (নিজের LAN-এ) |
| **nmap** | `pkg install nmap` | নিজের LAN/নিজের host scan |
| **jq** | `pkg install jq` | JSON শেল-এ ছাঁটা: `curl … | jq .field` |
| **curl-impersonate** (link) | https://github.com/lwthiker/curl-impersonate | TLS fingerprint ব্লক হলে (শেষ অস্ত্র) |

## Media / Files

| Tool | Install | কখন |
|---|---|---|
| **yt-dlp** | `pip install yt-dlp` | ভিডিও/অডিও নামানো (supports হাজার সাইট) |
| **ffmpeg** | `pkg install ffmpeg` | convert/cut/mux — audio/video সব |
| **gallery-dl** | `pip install gallery-dl` | ছবি/গ্যালারি নামানো |
| **qpdf/pypdf** | `pkg install qpdf` / `pip install pypdf` | PDF merge/split/unlock (নিজের ফাইল) |

## ব্যবহারের মন্ত্র

1. **আগে চেনো, পরে decode করো** — `file`, `head -c`, magic bytes; অনুমানে
   ciphey ছাড়া ডুবো না
2. **এক tool ব্যর্থ = শেষ নয়** — ciphey না পারলে CyberChef Magic, সেটাও না
   পারলে ধাপে ধাপে হাতে (b64 → XOR sweep → zlib)
3. **heavy install ব্যর্থ হলে** ছোট বিকল্প: ciphey না হলে
   `pip install base64 rot13…` নয় — নিজের ৩০-লাইনের decoder (XOR sweep
   সহ সব বেস) — proto-endpoint-probe skill-এ pattern আছে
4. Install করা প্রতিটা নতুন tool আর তার ব্যবহার-শিক্ষা **skill-এ রেখে দাও**
   (self-improvement) — পরের সেশন শূন্য থেকে শুরু করবে না
