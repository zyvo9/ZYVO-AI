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

## STAGE 4 — tcpdump → Wireshark (proxy-বাইপাস traffic-ও)

```bash
pkg install tcpdump
su -c "tcpdump -i any -w /sdcard/cap.pcap"   # শেষ করতে Ctrl-C
```
- PC-তে Wireshark-এ খোলো; non-TLS সব প্লেইন (DNS, HTTP, গেমের socket
  handshake); TLS শুধু আকার/টাইমিং দেয় (SNI-তে ডোমেইন নাম দেখা যায়!)
- নির্দিষ্ট অ্যাপের port জানা থাকলে ফিল্টার: `tcp port 443 and host <ip>`
- SNI বের করা: `tshark -r cap.pcap -T fields -e tls.handshake.extensions_server_name | sort -u`

## STAGE 5 — DNS capture (এনক্রিপ্টেড অ্যাপেরও গন্তব্য ফাঁস)

```bash
su -c "tcpdump -i any port 53 -w /sdcard/dns.pcap"
tshark -r dns.pcap -T fields -e dns.qry.name | sort -u
```
- অ্যাপ কোন ডোমেইনে কথা বলে (API, টেলিমেট্রি, ad, CDN) — body এনক্রিপ্টেড
  হলেও DNS ফাঁস করে দেয়; মৃত server যাচাইতেও কাজে লাগে

## STAGE 6 — Frida crypto hook (TLS-উপরের encryption খোলা)

Java অ্যাপে সবচেয়ে সস্তা — **universal crypto logger**:
```js
Java.perform(function(){
  var Cipher = Java.use('javax.crypto.Cipher');
  Cipher.doFinal.overload('[B').implementation = function(b){
    var out = this.doFinal(b);
    console.log('[CIPHER] op=' + (this.opmode===1?'ENCRYPT':'DECRYPT') +
      ' alg=' + this.getAlgorithm() + ' len=' + b.length);
    return out;
  };
});
```
- একইভাবে `Mac.doFinal`, `MessageDigest.digest`; native অ্যাপে
  `mbedtls_*`/OpenSSL `EVP_*` hook — plaintext আর key দুটোই ধরা পড়ে
- অ্যাপের নিজস্ব crypto (মেটাডেটা strings-এ নাম) — সেটাও hook (apk-mod F)

## STAGE 7 — logcat deep

```bash
su -c "logcat -c"   # পুরনো মুছে
adb logcat -v time | grep -iE "http|url|api|endpoint|token|error"
```
- বহু অ্যাপ নিজের endpoint/retry/error log করে; `-f /sdcard/log.txt` দিয়ে
  ফাইলে জমাও

## STAGE 8 — Replay / fuzz (নিজের account, paced)

1. mitm log থেকে একটা request নাও (endpoint, headers, body)
2. python-এ replay → response তুলনা (baseline)
3. **একবারে একটা ফিল্ড বদলাও** → response বদল দেখে validation map বানাও
   (wire-probe oracle)
4. Pacing: একই server-এ ব্যার্স্ট মানেই 429 — 1.5s+ gap, সর্বোচ্চ ৪ worker
5. প্রতিটা ফল `*_results.json`-এ — PROOF DISCIPLINE (200 ≠ success)

## STAGE 9 — Game socket sniff (গেমের নিজস্ব TCP/UDP প্রোটোকল)

1. **Port খোঁজো:** `su -c "ss -tunp" | grep <game-pkg>` — চলন্ত socket-এর
   remote ip:port ধরা পড়ে
2. **tcpdump ওই pair-এ:** `tcpdump -i any host <ip> -w game.pcap` — handshake
   ও packet rhythm দেখো
3. **Content দরকার হলে:** Frida-তে অ্যাপের send/recv hook — Java:
   `SocketOutputStream.write`/`SocketInputStream.read`; native:
   `libcurl`/`send`/`recv`/`WSASend` — buffer hexdump করে ফাইলে
4. Structure বোঝা গেলে নিজের client (apk-mod C) বা local server (G)

## STAGE 10 — OWN-NETWORK WIFI AUDIT (শুধু নিজের router/network)

**Device discovery — ফোনেই হয় (এটাই "১০-১৫টা name দেখা"):**
```bash
pkg install nmap termux-api        # Termux:API app + অনুমতি লাগবে
termux-wifi-connectioninfo          # নিজের SSID/BSSID/IP
su -c "iw dev wlan0 scan" | grep -E "SSID|signal"   # কাছের নেটওয়ার্ক
nmap -sn 192.168.0.0/24             # LAN-এর প্রতিটা ডিভাইস (IP+MAC)
nmap -sn --unprivileged 192.168.0.0/24
ip neigh                            # ARP-এ যারা জীবন্ত
nmap --script dns-service-discovery 192.168.0.0/24   # hostname নাম
```
- MAC-এর প্রথম ৩ byte = **vendor** (Samsung/ESP32/Xiaomi…) — কোনটা কী বোঝা যায়
- Router-এর admin page (gateway IP) → client list-এ hostname-ও দেয়
- এতেই ১০-১৫টা ডিভাইসের নাম+vendor+IP ম্যাপ হয়ে যায়

**WPS / Pixie Dust — সত্যি সীমা (মিথ্যা আশা নয়):**
- ফোনের stock WiFi chip-এ **monitor mode / packet injection নেই** —
  reaver/bully/OneShot ফোনে চলবে **না** (এজন্যই ESP32-র জন্ম)
- **বাস্তব পথ:** (১) ESP32 + **Marauder** firmware (scan/deauth/beacon/probe —
  ফোন বা PC থেকে BLE/web UI দিয়ে চালানো), (২) PC + monitor-mode USB adapter
  → `airodump-ng` → **OneShot** (pixie dust:
  `python3 oneshot.py -i wlan0mon -b <BSSID>`) বা reaver (online pin brute)
- **আগে যাচাই:** router কি WPS-ই চালু আছে? Pixie Dust পুরনো/vulnerable
  chip-এই কাজ করে — নতুন router-এ সময় নষ্ট
- **নীতি:** শুধু **নিজের router** — অস্পষ্ট হলে এক লাইনে জিজ্ঞেস ("nijer
  router naki onner?"); onner হলে refuse + বিকল্প (lab/virtual router)
- deauth/beacon-জাতীয় আক্রমণও শুধু নিজের নেটওয়ার্কে (নিজের device kick/test)

## নিয়ম

- নিজের device, নিজের account, ব্যক্তিগত ব্যবহার — অন্যের ট্রাফিক/নেটওয়ার্ক কখনো নয়
- প্রতিটা সেশনের capture ফাইল session ফোল্ডারে রাখো; শেখা নতুন pattern এই skill-এ যোগ করো (self-improvement)
- User "koto powerful" শুনতে ভালোবাসে, কিন্তু সীমা সৎভাবেই বলো — মিথ্যা আশা দেওয়া মানে পরে ভাঙা ভরসা

## STAGE 11 — DEFAULT-KEY ALGORITHMS (ফোনেই হয়, ESP32/monitor লাগে না)

Router-দের **ডিফল্ট WiFi password অনেকটাই SSID/MAC থেকেই গাণিতিকভাবে
তৈরি হয়** — SSID দেখেই candidate key বের করা যায়। Monitor mode লাগে না,
তাই ফোনেই চলে (পুরনো Router Keygen অ্যাপ এটাই করত, open-source):

**Algorithm পরিবার (SSID/BSSID pattern → key):**
| পরিবার | চেনার উপায় | ধরন |
|---|---|---|
| **Arcadyan** | নির্দিষ্ট SSID format (ISP routers) | hash-chain থেকে key — open-source impl আছে |
| **Belkin** | Belkin-নাম + MAC সম্পর্ক | MAC/serial-ভিত্তিক 8-char |
| **Thomson/SpeedTouch** | `XXXXYYYYYY` hex SSID | বছর+serial wordlist থেকে candidate |
| **multiSSID** | এক router-এ `SSID` + `SSID-5G` জোড়া | এক algorithm দুটো SSID-ই cover করে |
| **Discus/Eircom** | `Discus--`/`eircom` ধাঁচ | MAC থেকে key |
| **Netfaster/Wlan_XXXX** | `Wlan_` + MAC শেষ | ছোট keyspace |
| **Ono/Teletu/Pirelli/VodafoneXX** | ISP SSID pattern | MAC/serial ভিত্তিক |
| **TP-Link (পুরনো)** | MAC-ভিত্তিক default | প্যাটার্ন সেট |

**ফোনে ফ্লো (Termux):**
1. SSID+MAC সংগ্রহ: `termux-wifi-scaninfo` / `su -c "iw dev wlan0 scan"`
2. Pattern match → algorithm বাছাই → candidate key generate (python impl —
   **Router Keygen Android** open-source: github.com/routerkeygen/routerkeygenAndroid
   — এইখানেই সব algorithm-এর বাস্তবায়ন আছে; তুলে নিয়ে port করো)
3. Online **DB lookup** বিকল্প: **3WiFi** (3wifi.stascorp.com, API key) —
   BSSID দিলে জানা default key ফেরত; **wpa-sec** (handshake submit পথ —
   monitor লাগে, ফোনে নয়)
4. Candidate টেস্ট (নিজের/অনুমোদিত router): root → `cmd wifi connect <ssid>
   <pass>` বা `wpa_cli` — সফল connect-ই প্রমাণ (PROOF DISCIPLINE)
5. **রুট বোনাস — নিজের ফোনের সেভ করা password ফেরত:**
   `su -c "cat /data/misc/wifi/WifiConfigStore.xml" | grep -i PreSharedKey`
   (পুরনো Android-এ সোজা; নতুন Android-এ encrypted store — root helper
   দরকার) → একই password QR বানিয়ে শেয়ারও করা যায়

**সত্যি সীমা:**
- কাজ করে শুধু **ডিফল্ট-password router**-এ (পুরনো/ISP-দেওয়া hardware) —
  user নিজে random password বসালে algorithm ব্যর্থ
- Random password ভাঙা = handshake crack = **monitor mode লাগবেই** (ফোনে নয়)
- WPA3/SAE-যুক্ত নতুন router-এ পুরনো algorithm প্রযোজ্য নয়
- **নীতি:** নিজের router বা লিখিত অনুমতি — অস্পষ্ট হলে একবার জিজ্ঞেস; onner
  হলে refuse (এক লাইন + বিকল্প)

**Router admin default-credential অডিট (একই পরিবার):** gateway IP-তে
admin/admin, admin/password, vendor-default তালিকা ট্রায়াল (নিজের router) —
দেখে নাও তোমার router কতটা নিরাপদ; সাথে LAN device-দের web-interface
default-cred চেক (printer/camera সবচেয়ে দুর্বল)
