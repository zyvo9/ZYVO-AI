---
name: phone-control
description: Android phone control — screen দেখা, tap/swipe/text, app খোলা, screenshot — সব wireless debugging দিয়ে, root ছাড়া। zyvo নিজে ফোন চালাতে পারে (screenshot দেখে → action নেয় → verify করে)। Shizuku-স্টাইল auto mDNS pairing। Use when the user asks to control the phone, tap/open something on screen, take screenshots, automate phone UI, open/change phone settings, অথবা ফোন চালানোর কথা বলে।
---

# Phone Control — zyvo নিজের ফোন চালায় (root ছাড়াই)

zyvo ফোনের **screen দেখতে পারে আর ছুঁতে পারে** — wireless debugging এর
ভিতর দিয়ে (adb over WiFi, Shizuku-র মতো)।

```
screencap নাও → ছবিটা নিজে দেখো (vision) → কোথায় কী আছে বুঝো
→ tap/swipe/text করো → আবার screencap → verify → পরের ধাপ… (লুপ)
```

## ⛔ আগে জেনে নাও (সত্যি সীমা — user-কে মিথ্যা আশা দিও না)

1. **Bank/login/OTP স্ক্রিন কালো আসবে** — Android secure screen block করে,
   root ছাড়া অসম্ভব। ওই ধরনের কাজ user-কে নিজে করতে বলো, আটকে থেকো না।
2. ধীর: প্রতিটা ধাপে screenshot → vision → action ≈ ৫-১৫ সেকেন্ড। তাই এটা
   "একটানা ট্যাপ করা"-র জন্য না — **৫+ ধাপের কাজ বলে দিলে শেষ করে দেওয়ার** জন্য।
3. **Android 11+** লাগবে (wireless debugging pairing-এর জন্য)।
4. তোমার চোখ = vision model — `auto/best-vision` router ব্যবহার করো।

## 🔧 STAGE 1 — একবারই লাগবে: Setup (user-এর সাথে, ধাপে ধাপে)

### ধাপ A — Termux-এ adb

```bash
command -v adb >/dev/null || pkg install -y android-tools
adb version    # Android Debug Bridge version দেখালেই হলো
```

### ধাপ B — ফোনে Wireless debugging চালু (user নিজে করবে)

User-কে বলো (সহজ বাংলায়, ধাপে ধাপে):
1. Settings → **About phone** → **Build number**-এ ৭ বার tap (Developer
   options খুলে যাবে)
2. Settings → System → **Developer options** → **Wireless debugging** ON
3. ওই page-টাই খোলা রাখো — ওখানে লেখা থাকে **IP address & port**
   (যেমন `192.168.0.112:37123`) — এটা connect port

### ধাপ C — Pairing (user split-screen করবে, তুমি auto-detect করবে)

1. User-কে বলো: **"Pair device with pairing code"** tap করো → dialog-এ
   একটা **আলাদা IP:PORT + ৬ ডিজিটের code** দেখাবে → **dialog খোলা রাখো**
2. এই dialog খোলা থাকা অবস্থায় pairing service **mDNS-এ broadcast করে** —
   তাই port তুমি **auto-detect** করতে পারবে (user টাইপ করবে না):

```bash
adb mdns services
# output-এ খুঁজো:  _adb-tls-pairing._tcp   <IP>:<PORT>
PAIR="$(adb mdns services | grep '_adb-tls-pairing' | grep -o '[0-9.]*:[0-9]*' | head -1)"
echo "pairing port: $PAIR"
```

3. **User-কে জিজ্ঞেস করো শুধু ৬ ডিজিটের code:** "Settings-এ যে ৬ সংখ্যার
   code দেখাচ্ছে সেটা বলো" — পেলে:

```bash
adb pair "$PAIR" "<CODE>"     # → Successfully paired ✓
```

4. এবার connect (main port — mdns-এ `_adb-tls-connect._tcp` থেকে, না পেলে
   user Wireless debugging page-এর "IP address & port" থেকে বলবে):

```bash
CONN="$(adb mdns services | grep '_adb-tls-connect' | grep -o '[0-9.]*:[0-9]*' | head -1)"
[ -z "$CONN" ] && CONN="<user-এর বলা ip:port>"
adb connect "$CONN"           # → connected to ...
adb devices                   # দেখাবে:  <ip:port>   device   ← ব্যস, control চালু
```

5. শেষ টেস্ট: `adb shell echo ok` → `ok` আসলে **setup complete** 🎉

**সমস্যা হলে:** নিচের Troubleshooting section দেখো।

## 📡 STAGE 2 — প্রতিদিনের ব্যবহার (connect check)

প্রতি session-এর শুরুতে:

```bash
DEV="$(adb devices | grep -m1 'device$' | cut -d' ' -f1)"
[ -z "$DEV" ] && {
  CONN="$(adb mdns services | grep '_adb-tls-connect' | grep -o '[0-9.]*:[0-9]*' | head -1)"
  [ -n "$CONN" ] && adb connect "$CONN"
  DEV="$(adb devices | grep -m1 'device$' | cut -d' ' -f1)"
}
# এরপর সব কমান্ড:  adb -s "$DEV" shell ...
```

Pairing মনে থাকে — প্রতিবার connect করলেই হয়, code আর লাগে না।
(Wireless debugging toggle বন্ধ করলে বা ফোন restart হলে user-কে বলবে।)

## 👁️ STAGE 3 — Vision loop (এটাই মূল কাজ — ধাপে ধাপে, একটা একটা করে)

```bash
# ১. screen resolution জেনে নাও (coordinate হিসাবের জন্য)
adb shell wm size        # যেমন: Physical size: 1080x2400

# ২. screenshot নাও (exec-out = binary-safe, ছবি নষ্ট হয় না)
mkdir -p /storage/emulated/0/ZYVO
adb exec-out screencap -p > /storage/emulated/0/ZYVO/screen.png

# ৩. ছবিটা নিজে Read করো (vision) — দেখো:
#    স্ক্রিনে কী আছে? টার্গেট কোথায়? (উপরে-নিচে-বামে-ডানে আনুমানিক অবস্থান)

# ৪. coordinate হিসাব: ছবিতে যেখানে দেখাচ্ছে × (resolution ÷ ছবির মাপ)
#    যেমন ছবির ১/২ উচ্চতায় বাম-মাঝে থাকলে 1080x2400-এ ≈ (540, 1200)

# ৫. action নাও (নিচের ACTION reference)

# ৬. আবার screenshot → ফল মিলাও → পরের ধাপ
```

**কঠোর নিয়ম:** প্রতিটা action-এর পরে screenshot না নিয়ে পরের action করবে
না। একটা একটা করে — দেখে — বিশ্বাস করে।

## 🎮 STAGE 4 — ACTION reference (সব কমান্ড)

```bash
D="adb shell"    # ছোট করে লেখার জন্য

# tap
$D input tap 540 1200

# long-press (একই জায়গায় ৮০০ms ধরে রাখা)
$D input swipe 540 1200 540 1200 800

# swipe / scroll (নিচ থেকে উপরে = scroll up)
$D input swipe 540 1800 540 700 300

# লেখা বসানো — ⚠️ স্পেস হলে %s দাও
$D input text "hello%sworld"

# keyevent: 66=enter 4=back 3=home 82=menu 26=power
$D input keyevent 4          # back

# app খোলা (package জানা থাকলে)
$D monkey -p com.android.settings -c android.intent.category.LAUNCHER 1

# app-এর তালিকা (package খুঁজতে)
$D pm list packages | grep -i wifi

# settings page সরাসরি
$D am start -a android.settings.WIFI_SETTINGS

# screenshot আবার (verify)
adb exec-out screencap -p > /storage/emulated/0/ZYVO/screen.png
```

## 📋 ফল কোথায় থাকবে

- screenshot: `Internal storage/ZYVO/screen.png` (File manager-এ দেখা যায়)
- agent-এর কাজের report: chat-এই দেখাও — "দেখলাম X ছিল, tap করলাম, এখন Y ✓"

## 🛡️ SAFETY (user-এর ফোন — এটা পবিত্র)

- Delete/uninstall/payment/OTP/password-জাতীয় কিছুতে **আগে জিজ্ঞেস করো**
- User যা বলেছে তার বাইরের কোনো screen-এ যাবে না
- Secure screen (কালো) পেলে থেমে user-কে বলো — বাইপাসের চেষ্টা করবে না

## 🔧 TROUBLESHOOTING

| সমস্যা | সমাধান |
|---|---|
| `adb mdns services` খালি | Pair dialog খোলা আছে কিনা; ফোন ও Termux এক WiFi-তে কিনা; WiFi-তে client isolation থাকলে hotspot দিয়ে চেষ্টা |
| `device offline` / `unauthorized` | Wireless debugging toggle off→on, আবার pair |
| port বদলে গেছে | প্রতিবার mdns থেকে auto-detect — হাতে মনে রাখার দরকার নেই |
| screenshot কালো | Secure screen — ওই কাজ user-কে দাও |
| `input text` স্পেস কাজ করছে না | স্পেসের জায়গায় `%s` দাও |
| কিছুই হচ্ছে না | `adb kill-server && adb start-server` তারপর connect আবার |

## 🧪 শেষ কথা

প্রতিটা কাজের শেষে user-কে বলো কী হলো — কোথায় গেলে, কী tap হলো, এখন
স্ক্রিনে কী আছে (screenshot থেকে)। সন্দেহ হলে থামো, user-কে দেখাও।
