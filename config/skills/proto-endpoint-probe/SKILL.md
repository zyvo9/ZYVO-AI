---
name: proto-endpoint-probe
description: MITM / traffic capture & protocol probing on the user's own rooted Android phone — mitmproxy-on-phone with transparent iptables redirect, root system-CA install, Frida unpinning, protobuf wire-probe oracle, endpoint semantics, capture-to-replay workflow. Use when the user asks to capture/sniff an app's traffic, see which endpoint/server an app talks to, MITM an app, decode protobuf, find API endpoints, replay requests, or says "traffic dhorbo", "endpoint dekha jay", "mitm setup koro".
---

# Proto Endpoint Probe — MITM + প্রোটোকল খোঁজা (নিজের rooted ফোনে)

ফোনেই পুরো টুলকিট থাকে (Termux + root) — PC ছাড়াই অ্যাপের প্রতিটা request
চোখের সামনে। সব কাজ **নিজের device + নিজের account** — অন্যের ট্রাফিক নয়।

## ⛔ সত্যি সীমা (আগে জেনে নাও)

- Proxy-তে পড়ে শুধু **TCP/HTTP(S)** — গেমের রিয়েল-টাইম socket (UDP/নিজস্ব
  TCP প্রোটোকল) এখানে আসে না; ওগুলো দরকার হলে Frida/socket hook
- **Android 7+ অ্যাপ user-CA বিশ্বাস করে না** — তাই CA কে সিস্টেম স্টোরে
  ঢুকিয়েতে হয় (root দিয়ে, নিচে)
- অ্যাপ **TLS-এর উপরেও নিজের crypto** চালালে body এনক্রিপ্টেড দেখাবে —
  endpoint তবু দেখা যায়; content দরকার হলে অ্যাপের crypto ফাংশন hook করে
  key বের করো
- Secure screen (bank/login/OTP) কালো

## STAGE 1 — MITM সেটআপ (একবার)

```bash
command -v mitmweb >/dev/null || pip install mitmproxy
mitmweb --mode transparent --listen-host 127.0.0.1 -p 8080 &   # dashboard :8081
# CA → system store (root):
HASH=$(openssl x509 -inform PEM -subject_hash_old -in ~/.mitmproxy/mitmproxy-ca-cert.pem | head -1)
su -c "mount -o rw,remount /system 2>/dev/null || mount -o rw,remount /"
su -c "cp ~/.mitmproxy/mitmproxy-ca-cert.pem /system/etc/security/cacerts/$HASH.0"
su -c "chmod 644 /system/etc/security/cacerts/$HASH.0"
# traffic redirect (root) — undo: -D দিয়ে একই নিয়ম
su -c "iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDIRECT --to-ports 8080"
su -c "iptables -t nat -A OUTPUT -p tcp --dport 80  -j REDIRECT --to-ports 8080"
```
- Non-HTTP port-ও দরকার হলে `--dport <port>` একইভাবে যোগ
- Undo: `iptables -t nat -F OUTPUT` (সাবধানে — শুধু নিজের নিয়ম থাকলে)

## STAGE 2 — PINNED অ্যাপ (cert মানবে না) → Frida unpin

```bash
pip install frida-tools
# frida-server (অ্যাপ-ভেদে version) push করে root-এ চালাও, তারপর:
frida -U -f com.target.app --no-pause -s unpin.js
```
`unpin.js`-এ দুই স্তর (apk-mod skill section F-এর বিস্তারিত):
- **Java:** `javax.net.ssl.TrustManager`/`SSLContext.init` → খালি trust-all
  manager; OkHttp `CertificatePinner.check` → return-void
- **Native (BoringSSL/libcurl অ্যাপ):** `X509_verify_cert` → always 1,
  `SSL_CTX_set_verify` → SSL_VERIFY_NONE
- যাচাই: mitmweb dashboard-এ অ্যাপের request প্লেইন দেখা গেলেই সফল

## STAGE 3 — পড়া ও ব্যবহার

- অ্যাপে প্রতিটা action একবার করে করো — প্রতিটার পেছনের endpoint + header +
  body mitm log-এ জমা হয়
- Binary body = সাধারণত protobuf → `blackboxprotobuf.decode_message(bytes)`
  দিয়ে field-map বের করো (tools-arsenal)
- **Wire-probe oracle:** এক ফিল্ডে invalid UTF-8 পাঠাও — 400 = চেনা string,
  200 = অজানা wiretype; field ≥ 16 = multi-byte varint key `(f<<3)|wt`
- এরপর নিজের client/replay script (apk-mod section C/D) — কিন্তু PROOF
  DISCIPLINE: 200 ≠ success, observable পরিবর্তনই প্রমাণ

## এই type-এর আর যা যা করা যায় (observability পরিবার)

| কৌশল | কী দেয় | কীভাবে |
|---|---|---|
| **tcpdump → Wireshark** | proxy-বাইপাস socket traffic-ও (দেখা যায়, TLS ছাড়া) | `pkg install tcpdump; su -c "tcpdump -i any -w cap.pcap"` → PC-তে খোলো |
| **DNS capture** | অ্যাপ কোন ডোমেইনে যাচ্ছে (মৃত server যাচাইসহ) | mitmproxy log + `tcpdump port 53`, বা নিজের dnsmasq |
| **Frida crypto hook** | TLS-উপরের encrypted body-র key/plaintext | অ্যাপের encrypt/decrypt ফাংশন (metadata strings থেকে নাম) hook |
| **logcat deep** | অনেক অ্যাপ নিজের endpoint/error log করে | `adb logcat | grep -iE "http|url|api"` |
| **VPN-service capture (no-root)** | root ছাড়া capture (HttpCanary/Packet Capture ধাঁচ) | user-CA সীমাই থাকে — root থাকলে system-CA পথই ভালো |
| **Replay/fuzz (নিজের account)** | endpoint-এর সীমা/behavior মাপা | ধরা request → ফিল্ড বদলে আবার → response তুলনা (oracle) |
| **Game socket sniff** | গেমের নিজস্ব TCP/UDP প্রোটোকল | tcpdump + port শনাক্ত → Frida socket hook (`send`/`recv`) |
| **MitM-বিপরীত: fake server** | অ্যাপকে নিজের উত্তর খাওয়ানো (dead game/license) | hosts/iptables → নিজের server (apk-mod G) |

## FF worked example (প্রমাণিত — রেফারেন্স)

- Auth: `ff-jwt-gen-api…/api/public/token?uid&password` → JWT →
  `clientbp.ppmainecoonghj.com/<Endpoint>` (মরা host: ggblueshark, ভারত: ind,
  US: us — হোস্ট-ম্যাট্রিক্স শিখো)
- Headers: `UnityPlayer/2018.4.12f1 (UnityWebRequest/1.0, libcurl/8.5.0-DEV)`,
  `Authorization: Bearer`, `X-GA: v1 1`, `X-GA-Sv: <ts>`,
  `ReleaseVersion: OB55`, `X-Unity-Version: 2018.4.12f1`
- AES-CBC: key `Yg&tc%DEuh6%Zc^8`, iv `6oyZDr22E3ychjM%` (PKCS7)
- Like schema: `like{1: uid int64, 2: region string}` — কিন্তু 200-empty ≠
  like হয়েছে (PROOF DISCIPLINE)
- Error semantics: 400 body/lookup · 401 host-ভেদে JWT reject · 500 len-1
  `b'\n'` raw body · 404 endpoint নেই · 503 dead cluster

## নিয়ম

- নিজের device, নিজের account, ব্যক্তিগত ব্যবহার — অন্যের ট্রাফিক কখনো নয়
- প্রতিটা সেশনের capture ফাইল session ফোল্ডারে রাখো; শেখা নতুন pattern
  এই skill-এ যোগ করো (self-improvement)
