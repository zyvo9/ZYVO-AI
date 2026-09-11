---
name: phone-control
description: Android phone control — screen দেখা, tap/swipe/text, app খোলা — সব wireless debugging দিয়ে, root ছাড়া। zyvo নিজে ফোন চালাতে পারে (screenshot দেখে → action নেয় → verify করে)। Use when the user asks to control the phone, tap/open something on screen, take screenshots, automate phone UI, অথবা ফোন চালানোর কথা বলে।
---

# Phone Control (vision loop — root ছাড়াই)

zyvo ফোনের **নিজের screen দেখতে পারে আর tap/swipe/text করতে পারে** —
wireless debugging এর ভিতর দিয়ে (Shizuku-র মতো, কিন্তু Shizuku লাগে না)।

```
screencap নাও → ছবিটা দেখো (vision) → সিদ্ধান্ত নাও → input tap/swipe
→ আবার screencap → verify → পরের ধাপ... (লুপ)
```

## ⛔ আগে জেনে নাও (সত্যি সীমা)

1. **Bank/login স্ক্রিন কালো আসবে** — Android secure screen block করে।
   বাইপাস করবে না। ওই ধরনের কাজে user-কে বলবে নিজে করতে।
2. প্রতিটা ধাপে screenshot → vision → action ≈ ৫-১৫ সেকেন্ড — ধৈর্য ধরো।
3. Android 11+ লাগবে (wireless debugging pairing-এর জন্য)।
4. তোমার vision model লাগবে — `auto/best-vision` router ব্যবহার করো।

## 🔧 একবারই লাগবে: Setup (user-এর সাথে, ধাপে ধাপে)

**User-কে বলো:** Settings → Developer options → **Wireless debugging** ON
করো → তারপর split-screen করে (zyvo একপাশে, settings আরেক পাশে) থাকো।
তারপর "Pair device with pairing code" চাপো — **dialog খোলা রাখো** (৬
ডিজিটের code দেখাবে)।

তারপর তুমি (agent) চালাও:

```bash
command -v adb >/dev/null || pkg install -y android-tools
adb mdns services
```

- Output-এ `_adb-tls-pairing._tcp` লাইন খুঁজো → তাতে `IP:PORT` আছে
  (auto-detect! user কিছু টাইপ করবে না)
- **User-কে জিজ্ঞেস করো:** "Settings-এ যে ৬ ডিজিটের code দেখাচ্ছে সেটা বলো"
- তারপর:

```bash
adb pair <IP:PORT> <CODE>       # paired ✓
adb mdns services               # এবার _adb-tls-connect._tcp খুঁজো
adb connect <IP:PORT>           # connected ✓
adb devices                     # নিজের serial দেখাবে — তারপর সব কমান্ড চলবে
```

- Connect port-টা প্রতিবার বদলায় — প্রতিবার `adb mdns services` থেকে নাও।
- **দৈনিক ব্যবহারে:** প্রতিবার launch-এ connected কিনা check করো — না
  থাকলে `adb connect` (code লাগবে না, pairing মনে থাকে)।

## 👁️ Vision loop (এটাই মূল কাজ)

```bash
# দেখো (screenshot → PNG)
adb exec-out screencap -p > /storage/emulated/0/ZYVO/screen.png
```

তারপর **ওই PNG-টা নিজে Read করো (image)** — দেখো স্ক্রিনে কী আছে,
কোথায় কী লেখা, কোন button কোথায়। তারপর কাজ:

```bash
adb shell input tap 540 1200          # tap (x y স্ক্রিন-অনুযায়ী)
adb shell input swipe 540 1800 540 800 # scroll
adb shell input text "hello"           # লেখা বসানো (focus থাকলে)
adb shell input keyevent 66            # enter
adb shell am start -a android.settings.WIFI_SETTINGS   # settings page খোলা
```

**নিয়ম:** প্রতিটা action-এর পরে আবার screenshot নাও — ফল verify করে তবেই
পরের ধাপ। একবারে অনেক action ঢোকাবে না।

## 🛡️ Safety (user-এর ফোন — এটা পবিত্র)

- Delete/uninstall/payment/OTP-জাতীয় কিছুতে **আগে জিজ্ঞেস করো**
- user যা বলেছে তার বাইরে কিছু tap করবে না
- Screen-এ password field দেখলে চোখ ফিরিয়ে আনো — না লিখলে ভালো

## 📦 যা যা কাজে লাগবে

- `android-tools` (adb) — একবার install
- Read tool (vision) — screenshot দেখতে
- `auto/best-vision` — চোখ হিসেবে router

## কখন এই skill ব্যবহার করবে

- "Settings-এ গিয়ে WiFi off করে দাও"
- "এই app-এ গিয়ে এই setting change করো"
- "স্ক্রিনের screenshot নিয়ে দেখো কী আছে"
- যেকোনো phone-UI automation — যেটা হাতে করতে ৫+ ধাপ লাগে
