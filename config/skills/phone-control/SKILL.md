---
name: phone-control
description: Android phone control — screen দেখা, tap/swipe/text, app খোলা, screenshot — সব wireless debugging দিয়ে, root ছাড়া। zyvo নিজে ফোন চালাতে পারে (screenshot দেখে → action নেয় → verify করে)। Pairing: user dialog-এর IP:PORT + code বললেই সাথে সাথে pair। Use when the user asks to control the phone, tap/open something on screen, take screenshots, automate phone UI, open/change phone settings, অথবা ফোন চালানোর কথা বলে।
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

### ধাপ C — Pairing (⚠️ এখানেই আগেরবার আটকে ছিলাম — এই নিয়ম মানো)

**সত্যি:** `adb mdns services` ফোনে কাজ করে না (Termux multicast lock ছাড়া
নিজের pairing service খুঁজে পায় না — প্রমাণিত)। তাই port scan/auto-detect
করার চেষ্টা কোরো না। সঠিক নিয়ম: **user dialog-এর মানগুলো বলবে, তুমি
সাথে সাথে pair করবে।**

1. User-কে বলো: **"Pair device with pairing code"** tap করো → dialog-এ
   দেখাবে: **pairing IP:PORT + ৬ ডিজিটের code** — তিনটাই লাগবে
2. ⏱️ dialog **~৬০ সেকেন্ডেই বন্ধ হয়** — তাই user-কে আগেই বলো split-screen
   করে রাখতে, আর তুমি সাথে সাথে কাজ করো
3. user বললে (যেমন: "192.168.0.113:43294, code 553210") সাথে সাথে:

```bash
adb pair 192.168.0.113:43294 553210     # → Successfully paired to ...
```

4. তারপর connect — **মূল page-এর port** (pairing port না, এটা আলাদা):
   user-কে বলো Wireless debugging page-এ "IP address & port" পড়তে

```bash
adb connect 192.168.0.113:37551         # user-এর দেখানো মূল port
adb devices                              # <ip:port>  device  ← চালু ✓
```

5. এরপর সব vision loop কমান্ড চলবে। Wireless debugging toggle বন্ধ বা
   ফোন restart হলে আবার user-কে নতুন port পড়তে বলতে হবে (pairing মনে থাকে)

## 📡 STAGE 2 — প্রতিদিনের ব্যবহার (connect check)

প্রতি session-এর শুরুতে:

```bash
DEV="$(adb devices | grep -m1 'device$' | cut -d' ' -f1)"
# খালি হলে → user-কে বলো Wireless debugging page-এর "IP address & port"
# পড়তে (mdns-এ খোঁজা যায় না) — পেলেই: adb connect <ওই IP:PORT>
# এরপর সব কমান্ড:  adb -s "$DEV" shell ...
```

Pairing মনে থাকে — একবার pair হলে পরে শুধু connect-ই লাগে, code নতুন করে
লাগে না। (Wireless debugging toggle বন্ধ করলে বা ফোন restart হলে
user-কে নতুন port পড়তে বলবে।)

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
| `adb pair` failed / timeout | dialog-এর IP:PORT আর code ঠিক কিনা মেলাও; dialog নতুন করে খুলে user-কে আবার বলতে দাও, সাথে সাথে pair |
| `device offline` / `unauthorized` | Wireless debugging toggle off→on, আবার pair |
| port বদলে গেছে | স্বাভাবিক — user-কে মূল page-এর "IP address & port" পড়তে বলো, সেটা দিয়ে connect |
| screenshot কালো | Secure screen — ওই কাজ user-কে দাও |
| `input text` স্পেস কাজ করছে না | স্পেসের জায়গায় `%s` দাও |
| কিছুই হচ্ছে না | `adb kill-server && adb start-server` তারপর connect আবার |

## 🧪 শেষ কথা

প্রতিটা কাজের শেষে user-কে বলো কী হলো — কোথায় গেলে, কী tap হলো, এখন
স্ক্রিনে কী আছে (screenshot থেকে)। সন্দেহ হলে থামো, user-কে দেখাও।
