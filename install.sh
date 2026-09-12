#!/data/data/com.termux/files/usr/bin/bash
#
# Zyvo installer + delta updater for Termux (Android aarch64)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/zyvo9/ZYVO-AI/main/install.sh | bash
#
# Update modes:
#   - runtime unchanged: downloads ONLY the code graph (~11MB) and re-attaches
#   - runtime changed / fresh install: full package
#   - wrapper + model-list config: always refreshed (KB)

set -euo pipefail

GITHUB_REPO="${1:-${ZYVO_REPO:-zyvo9/ZYVO-AI}}"
FORCE=false
for arg in "$@"; do [ "$arg" = "--force" ] && FORCE=true; done

BINARY_NAME="zyvo"
BIN="$PREFIX/libexec/zyvo/zyvo.bin"
META="$PREFIX/libexec/zyvo/update-meta"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}==>${NC} $1"; }
warn()  { echo -e "${YELLOW}==>${NC} $1"; }
die()   { echo -e "${RED}ERROR:${NC} $1" >&2; exit 1; }

# ---------------------------------------------------------------
# 1. Environment checks
# ---------------------------------------------------------------
[ -d "/data/data/com.termux" ] || die "This installer is for Termux only. Install Termux from F-Droid or GitHub: https://github.com/termux/termux-app/releases"

case "$(uname -m)" in
  aarch64|arm64) ;;
  *) die "Unsupported architecture: $(uname -m). Currently only aarch64 (64-bit ARM) phones are supported." ;;
esac

command -v curl >/dev/null 2>&1 || { info "Installing curl..."; pkg install -y curl; }
command -v zstd >/dev/null 2>&1 || { info "Installing zstd..."; pkg install -y zstd; }
command -v unzip >/dev/null 2>&1 || { info "Installing unzip..."; pkg install -y unzip; }

# ---------------------------------------------------------------
# 2. Dependencies
# ---------------------------------------------------------------
if ! command -v rg >/dev/null 2>&1; then
  info "Installing ripgrep..."
  pkg install -y ripgrep
else
  info "ripgrep already installed"
fi

# The wrapper's live model-list updater needs python — without it the
# active-model refresh silently skips and users see stale/dead models.
if ! command -v python >/dev/null 2>&1; then
  info "Installing python (needed for live model list)..."
  pkg install -y python
else
  info "python already installed"
fi

if [ ! -d "$HOME/storage/shared" ] && command -v termux-setup-storage >/dev/null 2>&1; then
  info "Requesting storage permission — press ALLOW (sessions will appear in /storage/emulated/0/ZYVO)"
  termux-setup-storage || true
fi

mkdir -p "$PREFIX/bin" "$PREFIX/libexec/zyvo" "$HOME/.config/zyvo"

# Latest wrapper deploys on every run
WRAPPER_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/android/wrapper.sh"
if curl -fsSL "$WRAPPER_URL" -o "$PREFIX/bin/${BINARY_NAME}.new" 2>/dev/null && [ -s "$PREFIX/bin/${BINARY_NAME}.new" ]; then
  chmod 755 "$PREFIX/bin/${BINARY_NAME}.new"
  mv "$PREFIX/bin/${BINARY_NAME}.new" "$PREFIX/bin/${BINARY_NAME}"
fi

# ---------------------------------------------------------------
# 3. Latest release info
# ---------------------------------------------------------------
info "Checking the latest release in ${GITHUB_REPO}..."
API_URL="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"
TMP_JSON="$(mktemp)"
HTTP_CODE="$(curl -sSL -o "$TMP_JSON" -w '%{http_code}' "$API_URL" || echo 000)"
if [ "$HTTP_CODE" = "404" ]; then
  rm -f "$TMP_JSON"
  die "No release published yet in ${GITHUB_REPO}. Run the build workflow first, then retry."
elif [ "$HTTP_CODE" != "200" ]; then
  rm -f "$TMP_JSON"
  die "GitHub API returned HTTP $HTTP_CODE. Check your internet connection."
fi
RELEASE_JSON="$(cat "$TMP_JSON")"
rm -f "$TMP_JSON"

asset_url() { echo "$RELEASE_JSON" | grep -o "\"browser_download_url\": *\"[^\"]*$1\"" | head -1 | grep -o 'https[^"]*' || true; }

LATEST_VERSION="$(echo "$RELEASE_JSON" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*android-v//; s/"//')"
[ -n "$LATEST_VERSION" ] || LATEST_VERSION="latest"
REMOTE_BUILD_ID="$(asset_url "build-id.txt" | xargs curl -fsSL 2>/dev/null | head -1 || echo unknown)"
GRAPH_META_URL="$(asset_url "graph-meta.txt")"
GRAPH_URL="$(asset_url "graph.bin.zst")"
REMOTE_CORE=""; REMOTE_GRAPH=""; REMOTE_TOTAL=""
if [ -n "$GRAPH_META_URL" ]; then
  GRAPH_META="$(curl -fsSL "$GRAPH_META_URL" 2>/dev/null || true)"
  REMOTE_CORE="$(echo "$GRAPH_META" | grep '^core=' | cut -d= -f2 || true)"
  REMOTE_GRAPH="$(echo "$GRAPH_META" | grep '^graph=' | cut -d= -f2 || true)"
  REMOTE_TOTAL="$(echo "$GRAPH_META" | grep '^total=' | cut -d= -f2 || true)"
fi
info "Latest: v${LATEST_VERSION} (build ${REMOTE_BUILD_ID})"

CONFIG_FILE="$HOME/.config/zyvo/zyvo.json"
deploy_skills() {
  # discover every skill in the repo (config/skills/<name>/SKILL.md)
  SKILLS_API="https://api.github.com/repos/${GITHUB_REPO}/contents/config/skills"
  LIST="$(curl -fsSL "$SKILLS_API" 2>/dev/null || true)"
  [ -n "$LIST" ] || return 0
  for NAME in $(echo "$LIST" | grep -o '"name": *"[^"]*"' | sed 's/"name": *"//;s/"//'); do
    SKILL_DIR="$HOME/.config/zyvo/skills/$NAME"
    SKILL_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/config/skills/$NAME/SKILL.md"
    mkdir -p "$SKILL_DIR"
    if curl -fsSL "$SKILL_URL" -o "$SKILL_DIR/SKILL.md.tmp" 2>/dev/null && [ -s "$SKILL_DIR/SKILL.md.tmp" ]; then
      mv "$SKILL_DIR/SKILL.md.tmp" "$SKILL_DIR/SKILL.md"
      info "skill deployed: $NAME"
    else
      rm -f "$SKILL_DIR/SKILL.md.tmp"
    fi
    # multi-file skills: fetch references/ folder too (e.g. lets-scroll)
    REFS_API="https://api.github.com/repos/${GITHUB_REPO}/contents/config/skills/${NAME}/references"
    REF_LIST="$(curl -fsSL "$REFS_API" 2>/dev/null || true)"
    if [ -n "$REF_LIST" ]; then
      mkdir -p "$SKILL_DIR/references"
      for RURL in $(echo "$REF_LIST" | grep -o '"download_url": *"[^"]*"' | grep -o 'https[^"]*'); do
        RFILE="${RURL##*/}"
        curl -fsSL "$RURL" -o "$SKILL_DIR/references/$RFILE" 2>/dev/null || true
        done
      fi
  done
  # remove skill folders that were renamed in the repo (known renames only —
  # never touch anything the user may have added themselves)
  OLDDIR="$HOME/.config/zyvo/skills/remotion"
  NEWDIR="$HOME/.config/zyvo/skills/motion-animation"
  if [ -d "$OLDDIR" ] && [ -f "$NEWDIR/SKILL.md" ]; then
    rm -rf "$OLDDIR"
    info "old skill removed: remotion (renamed)"
  fi
}

# ---------------------------------------------------------------
# 6c. Memory file (AGENTS.md) — deployed ONCE, never overwritten
#     (auto-loads in every session; the agent maintains it)
# ---------------------------------------------------------------
# Live model list source — the scanner gateway keeps only working models
MODELS_URL_FILE="$HOME/.config/zyvo/models-url"
if [ ! -f "$MODELS_URL_FILE" ]; then
  echo "https://omniroute-render-production-52cf.up.railway.app/active-models" > "$MODELS_URL_FILE"
  info "Live model list connected (scanner gateway)"
fi

AGENTS_FILE="$HOME/.config/zyvo/AGENTS.md"
AGENTS_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/config/AGENTS.md"
if [ ! -f "$AGENTS_FILE" ]; then
  if curl -fsSL "$AGENTS_URL" -o "$AGENTS_FILE.tmp" 2>/dev/null && [ -s "$AGENTS_FILE.tmp" ]; then
    mv "$AGENTS_FILE.tmp" "$AGENTS_FILE"
    info "Memory file created — zyvo will remember things across sessions"
  else
    rm -f "$AGENTS_FILE.tmp"
  fi
fi

# Older installs got AGENTS.md before the codebase-memory rules existed —
# append the rules section if the marker is missing (never touch memories).
RULES_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/config/agents-codebase-rules.md"
if [ -f "$AGENTS_FILE" ] && ! grep -q "Codebase memory (zyvo)" "$AGENTS_FILE" 2>/dev/null; then
  if curl -fsSL "$RULES_URL" -o "$AGENTS_FILE.tmp2" 2>/dev/null && [ -s "$AGENTS_FILE.tmp2" ]; then
    printf '
' >> "$AGENTS_FILE"
    cat "$AGENTS_FILE.tmp2" >> "$AGENTS_FILE"
    info "Codebase memory rules added to AGENTS.md"
  fi
  rm -f "$AGENTS_FILE.tmp2"
fi

# Older installs: append the user-treatment rules if the marker is missing
USER_RULES_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/config/user-treatment-rules.md"
if [ -f "$AGENTS_FILE" ] && ! grep -q "How to treat the user" "$AGENTS_FILE" 2>/dev/null; then
  if curl -fsSL "$USER_RULES_URL" -o "$AGENTS_FILE.tmp3" 2>/dev/null && [ -s "$AGENTS_FILE.tmp3" ]; then
    printf '
' >> "$AGENTS_FILE"
    cat "$AGENTS_FILE.tmp3" >> "$AGENTS_FILE"
    info "User-treatment rules added to AGENTS.md"
  fi
  rm -f "$AGENTS_FILE.tmp3"
fi

# Older installs: upgrade AGENTS.md to the v2 auto-memory protocol (marker check)
MEM2_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/config/agents-memory-upgrade.md"
if [ -f "$AGENTS_FILE" ] && ! grep -q "Auto-memory protocol" "$AGENTS_FILE" 2>/dev/null; then
  if curl -fsSL "$MEM2_URL" -o "$AGENTS_FILE.tmp4" 2>/dev/null && [ -s "$AGENTS_FILE.tmp4" ]; then
    printf '\n' >> "$AGENTS_FILE"
    cat "$AGENTS_FILE.tmp4" >> "$AGENTS_FILE"
    info "Auto-memory protocol v2 added to AGENTS.md"
  fi
  rm -f "$AGENTS_FILE.tmp4"
fi

# Privacy fix: older builds seeded personal facts ("Morad", GitHub handles,
# personal paths) into AGENTS.md — every device then used the same name.
# Strip ALL personal fingerprints and add the first-session rule; the agent
# re-learns the user's name per device.
if [ -f "$AGENTS_FILE" ] && grep -q "Known user facts (seeded" "$AGENTS_FILE" 2>/dev/null; then
  sed -i "/### Known user facts (seeded/,\$d" "$AGENTS_FILE"
  info "seeded facts block removed from AGENTS.md"
fi
if [ -f "$AGENTS_FILE" ] && grep -q "Moradmd\|Windows Credential Manager\|Dev machine: Windows 10 PC\|নাম/handle" "$AGENTS_FILE" 2>/dev/null; then
  sed -i '/Moradmd/d; /Windows Credential Manager/d; /Dev machine: Windows 10 PC/d; /full dossier lives in the vault/d; /github.com\/zyvoai\/ZYVO-AI/d; /নাম\/handle: \*\*Morad\*\*/d' "$AGENTS_FILE"
  if ! grep -q "First-session rule" "$AGENTS_FILE" 2>/dev/null; then
    printf '\n## First-session rule (name & identity)\n\nNEVER assume or hardcode any user name — every zyvo user is a\ndifferent person. In the FIRST conversation, gently ask what the user\nwants to be called (once, naturally), then save it in the User section.\nDo not address them by any name until they give one.\n' >> "$AGENTS_FILE"
  fi
  info "personal data stripped from memory (agent learns each user's name)"
fi

# Legacy config cleanup — pre-rebrand installs wrote ~/.config/opencode/
# opencode.json; it still registers a second "OmniRoute" provider in the
# model picker. Our config lives in ~/.config/zyvo/zyvo.json now.
LEGACY_CFG="$HOME/.config/opencode/opencode.json"
if [ -f "$LEGACY_CFG" ] && grep -q "OmniRoute" "$LEGACY_CFG" 2>/dev/null; then
  mv "$LEGACY_CFG" "$LEGACY_CFG.bak"
  info "legacy config moved to opencode.json.bak (was adding a duplicate provider)"
fi

# ---------------------------------------------------------------
# 6d. Obsidian vault (2nd brain) — deep memory the user can open
#     in the Obsidian app; agent writes session logs & dossiers here
# ---------------------------------------------------------------
VAULT="$HOME/storage/shared/Documents/ZyvoVault"
[ -d "$HOME/storage/shared" ] || VAULT="$HOME/.config/zyvo/vault"
if [ ! -f "$VAULT/00 Home/Memory Index.md" ]; then
  mkdir -p "$VAULT/00 Home" "$VAULT/01 User" "$VAULT/02 Projects" \
           "$VAULT/03 Credentials" "$VAULT/04 Sessions"
  cat > "$VAULT/00 Home/Memory Index.md" <<'EOF'
# ZyvoVault — Memory Index (2nd brain)

zyvo এই vault-এ গভীর memory রাখে। Obsidian app-এ এই ফোল্ডারটা "Open folder
as vault" দিয়ে খুললেই user সব দেখতে ও বদলাতে পারে।

## Agent-এর নিয়ম
- History দরকার হলে: আগে AGENTS.md (hot memory), তারপর এই index + দরকারি note।
- Lasting fact শিখলে **সেই মুহূর্তেই** সঠিক ফোল্ডারে লিখে ফেলো — পরের জন্য জমাতে না।
- কাজের session শেষে `04 Sessions/YYYY-MM-DD <বিষয়>.md` নোট: কী হলো, কী সিদ্ধান্ত, পরের ধাপ।
- Raw token/key কোথাও না — শুধু কোথায় সেভ আছে তার state (`03 Credentials/state.md`)।

## কাঠামো
- `01 User/` — user profile, পছন্দ
- `02 Projects/` — প্রতি project-এর একটি dossier
- `03 Credentials/state.md` — কোন credential কোথায় configure করা
- `04 Sessions/` — dated session logs
EOF
  info "Memory vault created: $VAULT (Obsidian app-এ খুললেই দেখা যাবে)"
fi

refresh_config() {
  # Data/wait budget: live config is ~4 KB, but waking a sleeping scanner
  # can cost 40s — install must stay fast. So: if the wrapper fetched a
  # live list <6h ago, keep it and skip the network entirely. Otherwise one
  # short 8s live try; on failure NEVER downgrade — keep the phone's current
  # list. Repo snapshot is only for fresh installs (no config at all yet).
  STAMP_FILE="$HOME/.config/zyvo/models.fetched"
  NOW="$(date +%s)"
  # set -e: a missing marker file must not abort the installer
  STAMP="$(cat "$STAMP_FILE" 2>/dev/null || echo 0)"
  case "$STAMP" in ''|*[!0-9]*) STAMP=0;; esac
  if [ "$(( NOW - STAMP ))" -lt 21600 ] && [ -s "$CONFIG_FILE" ]; then
    info "Model list already fresh ($(( (NOW - STAMP) / 3600 ))h old) — skipping download"
    return 0
  fi
  LIVE_URL="https://omniroute-render-production-52cf.up.railway.app/zyvo-config"
  if curl -fsSL -m 8 "$LIVE_URL" -o "$CONFIG_FILE.tmp" 2>/dev/null \
     && [ -s "$CONFIG_FILE.tmp" ] \
     && [ "$(head -c1 "$CONFIG_FILE.tmp" 2>/dev/null)" = "{" ] \
     && ! grep -q '"models":{}' "$CONFIG_FILE.tmp"; then
    [ -f "$CONFIG_FILE" ] && cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    date +%s > "$STAMP_FILE" 2>/dev/null || true
    info "Live active-model list fetched from scanner"
  else
    rm -f "$CONFIG_FILE.tmp"
    if [ -s "$CONFIG_FILE" ]; then
      warn "Scanner unreachable — keeping your current model list"
    else
      CONFIG_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/config/zyvo.json"
      if curl -fsSL "$CONFIG_URL" -o "$CONFIG_FILE.tmp" 2>/dev/null && [ -s "$CONFIG_FILE.tmp" ]; then
        mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        info "Fresh install — repo snapshot used (live list loads on first start)"
      else
        rm -f "$CONFIG_FILE.tmp"
        warn "Could not refresh config — keeping what you have"
      fi
    fi
  fi
}

# ---------------------------------------------------------------
# 4. Local state
# ---------------------------------------------------------------
INSTALLED=false; [ -f "$BIN" ] && INSTALLED=true
LOCAL_BUILD="none"; LOCAL_CORE=""; LOCAL_GRAPH=""
if [ -f "$META" ]; then
  LOCAL_BUILD="$(grep '^build=' "$META" | cut -d= -f2 || echo none)"
  LOCAL_CORE="$(grep '^core=' "$META" | cut -d= -f2 || echo 0)"
  LOCAL_GRAPH="$(grep '^graph=' "$META" | cut -d= -f2 || echo 0)"
fi

save_meta() {
  {
    echo "build=$REMOTE_BUILD_ID"
    echo "core=$REMOTE_CORE"
    echo "graph=$REMOTE_GRAPH"
    echo "total=$REMOTE_TOTAL"
  } > "$META"
}

# ---------------------------------------------------------------
# 5. Decide the update path
# ---------------------------------------------------------------
CURRENT=false
[ "$INSTALLED" = true ] && [ "$LOCAL_BUILD" = "$REMOTE_BUILD_ID" ] && CURRENT=true

NEED_FULL=false
NEED_GRAPH=false
if [ "$FORCE" = true ]; then NEED_FULL=true
elif [ "$CURRENT" = true ]; then NEED_FULL=false
elif [ "$INSTALLED" = false ]; then NEED_FULL=true
elif [ "$LOCAL_BUILD" = "none" ]; then NEED_FULL=true
elif [ -z "$REMOTE_CORE" ]; then NEED_FULL=true
elif [ "$REMOTE_CORE" = "$LOCAL_CORE" ]; then NEED_GRAPH=true
else NEED_FULL=true
fi

# ---------------------------------------------------------------
# 5a. Fast path: everything current
# ---------------------------------------------------------------
if [ "$CURRENT" = true ] && [ "$NEED_FULL" = false ] && [ "$NEED_GRAPH" = false ]; then
  refresh_config
  deploy_skills
  echo ""
  echo -e "${GREEN}✔ Everything up to date (v${LATEST_VERSION}, build ${REMOTE_BUILD_ID}).${NC}"
  echo "Start it with:  ${BINARY_NAME}"
  exit 0
fi

refresh_config

# ---------------------------------------------------------------
# 5b. Delta path: graph-only update (~11MB)
# ---------------------------------------------------------------
if [ "$NEED_GRAPH" = true ]; then
  info "Delta update available — downloading only the changed code graph..."
  TMP_DIR="$(mktemp -d)"
  GRAPH_ZST="${TMP_DIR}/graph.bin.zst"
  GRAPH_BIN="${TMP_DIR}/graph.bin"
  NEW_BIN="${TMP_DIR}/zyvo.new"

  curl -fL -C - --retry 3 --progress-bar "$GRAPH_URL" -o "$GRAPH_ZST" || die "Graph download failed."
  zstd -d -f "$GRAPH_ZST" -o "$GRAPH_BIN" || die "Graph decompress failed."
  ACTUAL=$(stat -c%s "$GRAPH_BIN" 2>/dev/null || echo 0)
  [ "$ACTUAL" = "$REMOTE_GRAPH" ] || die "Graph size mismatch ($ACTUAL != $REMOTE_GRAPH)."

  CORE_SIZE="$LOCAL_CORE"
  cp "$BIN" "${TMP_DIR}/old.bin"
  head -c "$CORE_SIZE" "${TMP_DIR}/old.bin" > "$NEW_BIN"
  cat "$GRAPH_BIN" >> "$NEW_BIN"
  TOTAL=$((CORE_SIZE + REMOTE_GRAPH + 8))
  i=0
  while [ $i -lt 8 ]; do
    b=$(( (TOTAL >> (8*i)) & 255 ))
    printf "\\$(printf '%03o' "$b")" >> "$NEW_BIN"
    i=$((i+1))
  done
  chmod 755 "$NEW_BIN"

  cp "$BIN" "${TMP_DIR}/zyvo.bak"
  mv "$NEW_BIN" "$BIN"
  if "$BIN" --version >/dev/null 2>&1; then
    save_meta
    rm -rf "$TMP_DIR"
    echo -e "${GREEN}✔ Delta update applied (v${LATEST_VERSION}) — graph-only download.${NC}"
    echo "Start it with:  ${BINARY_NAME}"
    exit 0
  else
    warn "New binary failed smoke test — rolling back and doing a full download..."
    cp "${TMP_DIR}/zyvo.bak" "$BIN"
    rm -rf "$TMP_DIR"
  fi
fi

# ---------------------------------------------------------------
# 5c. Full path: download + install the complete package
# ---------------------------------------------------------------
ASSET_PATTERN="android-aarch64.tar.zst"
FULL_URL="$(asset_url "android-aarch64.tar.zst")"
if [ -z "$FULL_URL" ]; then
  ASSET_PATTERN="android-aarch64.zip"
  FULL_URL="$(asset_url "android-aarch64.zip")"
fi
[ -n "$FULL_URL" ] || die "No package asset found in the latest release of ${GITHUB_REPO}."

info "Downloading full package: $FULL_URL"
TMP_DIR="$(mktemp -d)"
PKG_FILE="${TMP_DIR}/${BINARY_NAME}.pkg"
download_pkg() {
  curl -fL -C - --retry 3 --retry-delay 2 --progress-bar "$FULL_URL" -o "$PKG_FILE"
}
download_pkg || download_pkg || die "Download failed twice. Check your connection and retry."

if [ "${ASSET_PATTERN##*.}" = "zip" ]; then
  check_pkg() { unzip -t "$1" >/dev/null 2>&1; }
  extract_pkg() { unzip -o "$1" -d "$2"; }
else
  check_pkg() { tar --zstd -tf "$1" >/dev/null 2>&1; }
  extract_pkg() { tar --zstd -xf "$1" -C "$2"; }
fi
if ! check_pkg "$PKG_FILE"; then
  warn "Archive looks corrupted — re-downloading once..."
  rm -f "$PKG_FILE"
  curl -fL --progress-bar "$FULL_URL" -o "$PKG_FILE" || die "Download failed again."
  check_pkg "$PKG_FILE" || die "Archive is still corrupted. Please retry later."
fi

info "Installing..."
extract_pkg "$PKG_FILE" "$TMP_DIR"
USR_DIR="${TMP_DIR}/data/data/com.termux/files/usr"
[ -f "${USR_DIR}/bin/${BINARY_NAME}" ] || die "Downloaded archive does not contain ${BINARY_NAME}."

mkdir -p "$PREFIX/bin" "$PREFIX/libexec/zyvo" "$PREFIX/lib"
cp "${USR_DIR}/bin/${BINARY_NAME}" "$PREFIX/bin/${BINARY_NAME}"
chmod 755 "$PREFIX/bin/${BINARY_NAME}"
if [ -f "${USR_DIR}/libexec/zyvo/zyvo.bin" ]; then
  cp "${USR_DIR}/libexec/zyvo/zyvo.bin" "$BIN"
  chmod 755 "$BIN"
else
  die "Downloaded archive does not contain the zyvo binary."
fi
for so in "${USR_DIR}"/lib/*.so; do
  [ -f "$so" ] && cp "$so" "$PREFIX/lib/"
done
rm -f "$PREFIX/bin/opencode" 2>/dev/null || true
rm -rf "$PREFIX/libexec/opencode" 2>/dev/null || true
rm -rf "$TMP_DIR"

if [ -n "$REMOTE_CORE" ]; then save_meta; fi

# ---------------------------------------------------------------
# 6. Config (model list) + smoke test
# ---------------------------------------------------------------
refresh_config
deploy_skills

info "Verifying installation..."
if "$PREFIX/bin/${BINARY_NAME}" --version; then
  echo ""
  echo -e "${GREEN}✔ ${BINARY_NAME} v${LATEST_VERSION} installed successfully!${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Set an AI provider key (e.g. export ANTHROPIC_API_KEY=...)"
  echo "  2. Start:  ${BINARY_NAME}"
  echo "  Update later with:  ${BINARY_NAME} update"
  echo ""
  echo "Keep the screen on during long sessions:  termux-wake-lock"
else
  die "Installed binary did not run. Please report with the output of:  ${BINARY_NAME} --version"
fi
