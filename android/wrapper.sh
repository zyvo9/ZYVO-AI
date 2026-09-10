#!/data/data/com.termux/files/usr/bin/sh
# zyvo/opencode — launcher wrapper for Android/Termux
#
# Based on guysoft/opencode-termux's wrapper (MIT), with zyvo additions:
#   - TMPDIR/OPENCODE_TMPDIR point at Termux's writable tmp ($PREFIX/tmp)
#   - ZYVO_SESSION_ROOT: browsable session folder on shared storage
#
# The real opencode binary is opencode.bin; this script LD_PRELOAD's libtagfix.so
# (a constructor that calls mallopt to turn off heap tagging) before exec'ing it.
# Without this, Bun/JSC's NaN-boxing clears the 0xB4 top-byte tag on heap
# pointers, causing bionic to SIGABRT on free(): "Pointer tag ... was truncated".

set -e

# zyvo update - self-update via the remote installer
if [ "${1:-}" = "update" ]; then
  echo "==> Updating zyvo..."
  curl -fsSL "https://raw.githubusercontent.com/zyvoai/ZYVO-AI/main/install.sh" | bash
  exit $?
fi

dir="$(cd "$(dirname "$0")" && pwd)"
export ANDROID_ROOT="${ANDROID_ROOT:-/system}"
export TERMUX_VERSION="${TERMUX_VERSION:-opencode-termux}"

# zyvo: Termux's own writable tmp. The Android rootfs /tmp is read-only, and
# Bun's os.tmpdir() may fall back to it — so pin it explicitly (both names).
ZYVO_TMP="${OPENCODE_TMPDIR:-${PREFIX:-/data/data/com.termux/files/usr}/tmp}"
export OPENCODE_TMPDIR="$ZYVO_TMP"
export TMPDIR="$ZYVO_TMP"
export TEMP="$ZYVO_TMP"
export TMP="$ZYVO_TMP"
mkdir -p "$TMPDIR" 2>/dev/null || true

# zyvo: browsable sessions live on shared storage when it's writable
# (grant access once with: termux-setup-storage). Otherwise fall back silently.
# Default root: shared storage (visible in any file manager as
# Internal storage/ZYVO). If the storage permission is missing, fall back
# to a private folder so files still land somewhere predictable.
ZYVO_ROOT="${ZYVO_SESSION_ROOT:-$HOME/storage/shared/ZYVO}"
if ! mkdir -p "$ZYVO_ROOT" 2>/dev/null || [ ! -w "$ZYVO_ROOT" ]; then
  ZYVO_ROOT="$HOME/ZYVO"
  mkdir -p "$ZYVO_ROOT" 2>/dev/null || true
  if [ -w "$ZYVO_ROOT" ]; then
    echo "zyvo: storage permission missing — using $ZYVO_ROOT instead." >&2
    echo "zyvo: run 'termux-setup-storage' once to use Internal storage/ZYVO." >&2
  fi
fi
if [ -d "$ZYVO_ROOT" ] && [ -w "$ZYVO_ROOT" ]; then
  export ZYVO_SESSION_ROOT="$ZYVO_ROOT"
  # Default workspace: every session gets its own folder
  # (<root>/session-<timestamp>) so files stay browsable and separate per
  # session. Only when launched bare from $HOME — if the user cd'd into a
  # project, respect their choice.
  if [ "$PWD" = "$HOME" ]; then
    ZYVO_SESS="$ZYVO_ROOT/session-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$ZYVO_SESS" 2>/dev/null && cd "$ZYVO_SESS" || true
  fi
else
  unset ZYVO_SESSION_ROOT
fi

# UPDATE-FIRST LAUNCH: fetch the latest model list BEFORE zyvo opens.
# Try 1: fast (8s). Try 2: long (40s) — gives a sleeping cloud scanner time
# to wake up. Only after both fail do we open with the current config.
# Never lose the working config — atomic write + backup.
ZYVO_MODELS_URL="${ZYVO_MODELS_URL:-}"
[ -z "$ZYVO_MODELS_URL" ] && [ -f "$HOME/.config/zyvo/models-url" ] && ZYVO_MODELS_URL="$(head -n1 "$HOME/.config/zyvo/models-url" 2>/dev/null)"
if [ -n "$ZYVO_MODELS_URL" ]; then
  ZYVO_CONFIG_URL="${ZYVO_MODELS_URL%/active-models}/zyvo-config"
  echo "zyvo: সর্বশেষ model list নাওয়া হচ্ছে…" >&2
  NEWCFG="$(curl -fsS -m 8 "$ZYVO_CONFIG_URL" 2>/dev/null || true)"
  if [ -z "$NEWCFG" ]; then
    echo "zyvo: scanner জাগছে — একটু অপেক্ষা…" >&2
    NEWCFG="$(curl -fsS -m 40 "$ZYVO_CONFIG_URL" 2>/dev/null || true)"
  fi
  if [ -n "$NEWCFG" ] && [ "$(printf '%.1s' "$NEWCFG")" = "{" ] && ! echo "$NEWCFG" | grep -q '"models":{}'; then
    CFG="$HOME/.config/zyvo/zyvo.json"
    mkdir -p "$(dirname "$CFG")"
    [ -f "$CFG" ] && cp "$CFG" "$CFG.bak"
    printf '%s\n' "$NEWCFG" > "$CFG.new" && mv "$CFG.new" "$CFG"
    echo "zyvo: ✓ সর্বশেষ list বসে গেছে" >&2
  else
    echo "zyvo: scanner পাওয়া যায়নি — বর্তমান list দিয়েই চলছে" >&2
  fi
fi

export OPENCODE_DISABLE_TUI_AUDIO="${OPENCODE_DISABLE_TUI_AUDIO:-1}"

# Locate the native libraries we ship alongside the wrapper.
# In the flat zip layout they sit next to the wrapper; in the Termux package
# layout they are under ../lib.
NATIVE_LIB_DIR=""
for candidate in \
    "$dir/../lib" \
    "${PREFIX:-/data/data/com.termux/files/usr}/lib" \
    "$dir"
do
    if [ -f "$candidate/libtagfix.so" ]; then
        NATIVE_LIB_DIR="$candidate"
        break
    fi
done

if [ -n "$NATIVE_LIB_DIR" ]; then
    export LD_PRELOAD="${NATIVE_LIB_DIR}/libtagfix.so${LD_PRELOAD:+:$LD_PRELOAD}"
    # Bun's JIT-compiled modules need libc++_shared.so. Android's /system/lib64/
    # does not contain it, so point the linker at the directory where we ship it.
    export LD_LIBRARY_PATH="${NATIVE_LIB_DIR}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    # Bun's /$bunfs/root/ virtual paths are not intercepted on Android, so load
    # opentui's renderer library and bun-pty's PTY library from the real filesystem.
    export OPENTUI_LIB_PATH="${NATIVE_LIB_DIR}/libopentui.so"
    if [ -f "${NATIVE_LIB_DIR}/librust_pty_arm64.so" ]; then
        export BUN_PTY_LIB="${NATIVE_LIB_DIR}/librust_pty_arm64.so"
    fi
    # @parcel/watcher only bundles the host-arch native binding in our build;
    # disable it on Android/Termux to avoid a dlopen architecture mismatch.
    export OPENCODE_EXPERIMENTAL_DISABLE_FILEWATCHER="${OPENCODE_EXPERIMENTAL_DISABLE_FILEWATCHER:-true}"
    # If a real Bun binary is shipped next to opencode, use it for plugin installs.
    if [ -x "$NATIVE_LIB_DIR/bun" ]; then
        export OPENCODE_BUN_PATH="$NATIVE_LIB_DIR/bun"
    fi
else
    echo "zyvo: warning: native library directory not found, may crash on Android 11+" >&2
fi

# Locate zyvo.bin. Prefer the package layout first so upgrades do not
# accidentally execute a stale flat-layout binary left in $PREFIX/bin.
for candidate in \
    "$dir/../libexec/zyvo/zyvo.bin" \
    "${PREFIX:-/data/data/com.termux/files/usr}/libexec/zyvo/zyvo.bin" \
    "$dir/zyvo.bin"
do
    if [ -x "$candidate" ]; then
        exec "$candidate" "$@"
    fi
done

echo "zyvo: error: could not find zyvo.bin" >&2
exit 127

# Last resort: binary present but lost its exec bit (cp/unzip landed 644) —
# fix and retry instead of failing.
for candidate in \
    "$dir/../libexec/zyvo/zyvo.bin" \
    "${PREFIX:-/data/data/com.termux/files/usr}/libexec/zyvo/zyvo.bin" \
    "$dir/zyvo.bin"
do
    if [ -f "$candidate" ]; then
        chmod 755 "$candidate" 2>/dev/null || true
        exec "$candidate" "$@"
    fi
done
