---
name: viral-shorts-factory
description: Morad's personal 24/7 YouTube pipeline — trend radar finds viral/trending/informational stories, picks one, writes twist-test scripts, renders with the visual library (opuscar/vox-director/onetake/explainroo by story-type), US-English voice + Bangla dub (YouTube multi-audio), builds per-country thumbnails, publishes via Tabbit CLI (draft-first), and maintains the channel (48h analytics loop, comments draft, metadata tuning). Use ONLY when Morad asks for a new video, trend check, channel maintenance, dub/thumbnail work, or says "video banao / trend dekho / channel check koro / video upload koro".
---

# Viral Shorts Factory — ব্যক্তিগত ২৪/৭ পাইপলাইন (মালিক: Morad)

একটাই মাস্টার-রাউটার। সাব-ভিজ্যুয়াল-স্কিলগুলো **নাম ধরে** লোড হবে (অটো-ট্রিগার নয়)।
সব কাজ **এক-কর্মী কিউতে** (low laptop): একবারে একটাই ভারী কাজ — রেন্ডার চললে বাকি সব অপেক্ষা করবে।

## নীতি-গার্ড (AI নিজেই চালায় — Morad-এর সময় খরচ নয়)
1. **AUTO-LIVE:** ভিডিও পাবলিশ হয় সরাসরি নির্ধারিত স্লটে (scheduler) — অনুমোদন-লাইন নেই। শর্ত: নিচের সব গেট পাস। যেকোনো গেট ফেল = ওই ভিডিও draft-এ আটকে Morad-কে এক-লাইন জানানো।
2. **ক্যাপ:** দিনে ১-২ Shorts + ১ long (৪-৫ মিনিট) প্রতি ২-৩ দিনে। ঝড়ের বেগে ফার্ম নয়।
3. **টুইস্ট-টেস্ট:** শেষ লাইনে চমক না থাকলে গল্প বাদ — alto falto story নয়।
4. **শুধু নিজের ভিজ্যুয়াল:** অন্যের ফুটেজ/ছবি কখনো না (copyright strike = চ্যানেল-কিলার)। ভিজ্যুয়াল AI-নিজেই আঁকে (claude/zyvo)।
5. **ফ্যাক্ট-চেক:** ভাইরাল গল্পের মূল তথ্য websearch দিয়ে যাচাই; লেজেন্ড হলে "কথিত আছে" বলে ফ্রেম।
6. **থাম্বনেইল সততা:** ক্লিকবেট = কৌতূহল, মিথ্যা নয় — থাম্বনেইলে যা আছে ভিডিওতে তাই।
7. **সাপ্তাহিক ডাইজেস্ট:** Morad সপ্তাহে একবার সংক্ষেপ পাবে (কী পাবলিশ হলো, কোনটা চলল, গেট-ফেল কি হয়েছে) — দৈনিক ঝামেলা নেই।

## STAGE 1 — TREND RADAR (ক্রন/চাইলে হাতে)
- সোর্স: Google Trends + YouTube trending + Reddit rising — নিশ: trending / story / mystery / নস্টালজিয়া / interesting facts / kids-safe।
- স্কোর: গতি (২৪ঘ-তে উত্থান) × নিশ-ফিট × টুইস্ট-সম্ভাবনা − কপিরাইট-ঝুঁকি।
- আউটপুট: ড্যাশবোর্ডে টপ ৫ শর্টলিস্ট (topic + কেন গরম + প্রস্তাবিত স্টাইল)। Morad পিক করবে (অথবা auto-pick চালু থাকলে সর্বোচ্চ স্কোর)।

## STAGE 2 — STORY PICK
- ডুপ্লিকেট-চেক: নিজের আগের ভিডিও + বড় চ্যানেলের কভার হয়ে গেলে স্কিপ/বাঁক।
- সিরিজ-চিন্তা: বড় টপিক হলে ৩-ভিডিওর মিনি-সিরিজ (প্লেলিস্টে বাঁধা)।

## STAGE 3 — SCRIPT (cartoon-kit-এর ফর্মুলা, নিজের কথায়)
- হুক (প্রথম বাক্য = paradox) → সেটিং → escalation → pivot → টুইস্ট।
- Shorts ৩০-৬০ সে; long ৪-৫ মিনিট (~২.৮ শব্দ/সে)। প্রথম ৩০ সেকেন্ড = সব।

## STAGE 4 — VISUAL LIBRARY (গল্পের ধরন → স্কিল, নাম ধরে লোড)
- **opuscar** (প্রাইমারি): story/mystery/ইতিহাস/নস্টালজিয়া — ৬৬টা হাতে-আঁকা স্টাইল থেকে গল্পে মানানসই একটা; পরের ভিডিওতে ভিন্নটা (একঘেয়ে = নীতি-ঝুঁকি)।
- **vox-director**: নিউজ/তথ্য/paper-collage ফিল।
- **onetake**: continuous-camera ইমারসিভ গল্প।
- **explainroo**: দ্রুত Shorts + লোকাল TTS (Kokoro) + Whisper টাইমিং।
- Blender/GPU-জাতীয় কিছু নয় — সব CPU-ফ্রেন্ডলি। Low laptop: long রেন্ডার = রাত-শিফট; শান্ত দৃশ্যে স্টিল-শট মিশিয়ে ফ্রেম-খরচ কমানো।
- QUALITY GATE (AI self-check, মানুষ-অনুমোদন নয়): লুক-শিট AI নিজে দেখে ট্র্যাপ-লিস্ট মেপে (flat/untextured = বাইপাস, মিররড টেক্সট, ভাঙা কম্পোজিশন) + অটো pixel-check (color-variance, contrast, ink-presence)। ফেল = নিজে ঠিক করে আবার; ৩ চেষ্টায় ফেল = গল্প বাদ + digest-এ নোট। পাস = সরাসরি রেন্ডার।

## STAGE 5 — VOICE + DUB (YouTube multi-audio — অফিসিয়াল ফিচার)
- প্রাইমারি: **US English** (রেভিনিউ-টার্গেট)। ডাব: **Bangla** (একই ভিডিওতে দ্বিতীয় অডিও-ট্র্যাক — BD-তে বাংলা বাজবে)।
- ভয়েস: লোকাল TTS (Kokoro) বা Morad-রেকর্ডেড। ডাব = অনুবাদ → TTS → টাইমিং-ম্যাচ।
- ভবিষ্যৎ ভাষা (DA/NO/IS/LB-জাতীয়) = আরও ট্র্যাক, একই প্রক্রিয়া।

## STAGE 6 — THUMBNAIL (per-country + clickbait-সততা)
- Shorts-এ লাগে না; long-এ: কার্টুন key-frame + ≤৩ শব্দ + ইমোশন মুখ + কনট্রাস্ট।
- ভ্যারিয়েন্ট ৩টা (A/B); দেশভিত্তিক: US-এ EN, BD-তে BN — ট্যাবিট দিয়ে প্রতি দেশে সেট।
- টাইটেল+ট্যাগ: কৌতূহল-হুক + নিশ-কিওয়ার্ড; মিথ্যা প্রতিশ্রুতি নয়।

## STAGE 7 — PUBLISH (Tabbit CLI — প্রমাণিত ফ্লো)
- ট্যাবিটে চ্যানেল লগইন থাকে; zyvo ট্যাবিট চালিয়ে করে: YouTube Studio → upload → title/desc/tags → thumbnail (per-country) → ভাষা-অডিও ট্র্যাক → **schedule** (স্লট: US সকাল/সন্ধ্যা + সামান্য jitter)।
- **AUTO-LIVE:** সব গেট পাস করলে সরাসরি scheduled স্লটে লাইভ; যেকোনো ফেল = draft + Morad-কে এক-লাইন। Morad যেকোনো সময় "oi video dekhe bolo" বললে দেখাবে।
- Shorts vs long: যথাযথ ফরম্যাট; long-এ end-screen + প্লেলিস্ট বাঁধা (সিরিজ)।
- মানুষের-গতি pacing: আপলোডের মাঝে স্বাভাবিক বিরতি; বার্স্ট আপলোড নয়।

## STAGE 8 — CHANNEL MAINTENANCE (নিয়মিত — Tabbit দিয়েই)
- **৪৮ঘ অ্যানালিটিক্স লুপ:** প্রতি ভিডিওর retention/CTR/ভাষা-ভাগ → কোন টপিক/স্টাইল/ভাষা চলছে → পরের Trend Radar-এ ওজন।
- **কমেন্ট:** নতুন কমেন্ট তালিকা → সৎ+বন্ধুত্বপূর্ণ উত্তর সরাসরি পোস্ট (বিতর্ক/রক্ষণাবেক্ষণ-জাতীয় হলে খসড়া + digest-এ নোট)।
- **মেটাডেটা টিউন:** খারাপ CTR-এ টাইটেল/থাম্বনেইল সোয়াপ প্রস্তাব।
- **পুরনো ভিডিও রিভাইভ:** হঠাৎ চলতে থাকা পুরনো ভিডিও পেলে সেটার জাতে নতুন কনটেন্টে প্রাধান্য।

## SETUP (একবার)
- Tabbit CLI পেয়ারড + চ্যানেল লগইন (প্রমাণিত — Morad আগে zyvo দিয়ে আপলোড পর্যন্ত করানো)।
- ভিজ্যুয়াল-স্কিলগুলো ইনস্টল: opuscar, vox-director, onetake, explainroo।
- tools: node 22+, python3+numpy, ffmpeg, Playwright Chromium, Kokoro TTS।
- ক্রন: trend-radar প্রতি ৬ঘ + maintenance দৈনিক + long-render রাত-শিফট।

## ভুল-থেকে-শেখা
- একই স্টাইল পরপর ২ ভিডিওতে = নীতি-ঝুঁকি + একঘেয়ে → স্টাইল ঘোরাও।
- গেট বাদ দিলে: মনিটাইজেশন ক্ষতি (ব্যান না) — তাই গেট কখনো বাদ নয়।
- সাব-স্কিল description লক: ভিজ্যুয়াল-স্কিলগুলো শুধু এই ফ্যাক্টরি ডাকলেই লোড হবে — ভুল স্কিল উঠে ভিডিও নষ্ট হওয়া বন্ধ।
