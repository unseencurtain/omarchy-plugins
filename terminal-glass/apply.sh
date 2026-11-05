#!/usr/bin/env bash
# Re-assert the terminal glass that belongs to this repo.
#
# Run automatically by:
#   ~/.config/omarchy/hooks/theme-set.d/60-terminal-glass.sh
#   ~/.config/omarchy/hooks/post-update.d/60-terminal-glass.sh
# and once by ./install.sh. Running it by hand is always safe: every change is
# idempotent and only rewrites a file when its content actually differs.
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}"

HYPR="$CONFIG/hypr/hyprland.lua"
GHOSTTY_CONFIG="$CONFIG/ghostty/config"
GLASS_CSS="$CONFIG/ghostty/glass.css"
THEME_CURRENT="$STATE/omarchy/current/theme"
THEMES="$CONFIG/omarchy/themes"
TEMPLATE="$CONFIG/omarchy/themed/ghostty.conf.tpl"
GTK_CSS="$CONFIG/gtk-4.0/gtk.css" # cleanup only; see below

QUIET=0
RELOAD=1
while (( $# > 0 )); do
  case "$1" in
  --quiet) QUIET=1 ;;
  --no-reload) RELOAD=0 ;;
  *)
    echo "terminal-glass: unknown option: $1" >&2
    exit 2
    ;;
  esac
  shift
done

say() { (( QUIET )) || printf '%s\n' "$*"; }

apply_block() { # file snippet marker-start marker-end
  local file="$1" snippet="$2" start="$3" end="$4"
  [[ -f $file ]] || return 0
  python3 - "$file" "$snippet" "$start" "$end" <<'PY'
import re
import sys

path, snippet_path, start, end = sys.argv[1:5]
with open(path, encoding="utf-8") as fh:
    src = fh.read()
orig = src
with open(snippet_path, encoding="utf-8") as fh:
    block = fh.read().strip("\n") + "\n"

pattern = re.compile(
    r"(?ms)^" + re.escape(start) + r".*?^" + re.escape(end) + r"[^\n]*\n?"
)
src = pattern.sub("", src)
new = src.rstrip("\n") + "\n\n" + block
if new != orig:
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(new)
PY
}

hash_of() { sha1sum "$1" | cut -d' ' -f1; }

changed_hypr=0
changed_theme=0
changed_ghostty=0

# --- Hyprland: the authoritative block, at the very end ---------------------
# Omarchy's toggles load after looknfeel.lua. Appending this block last (and
# re-appending it after every update) makes the user's values the final word.
if [[ -f $HYPR ]]; then
  before=$(hash_of "$HYPR")
  python3 - "$HYPR" "$SELF_DIR/hyprland.lua" <<'PY'
import re
import sys

path, snippet_path = sys.argv[1:3]
with open(path, encoding="utf-8") as fh:
    src = fh.read()
orig = src
with open(snippet_path, encoding="utf-8") as fh:
    block = fh.read().strip("\n") + "\n"

src = re.sub(
    r"(?ms)^-- >>> terminal-glass.*?^-- <<< terminal-glass[^\n]*\n?", "", src
)
new = src.rstrip("\n") + "\n\n" + block
if new != orig:
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(new)
PY
  [[ $(hash_of "$HYPR") == "$before" ]] || {
    changed_hypr=1
    say "pinned terminal glass at the end of $HYPR"
  }
fi

# --- Ghostty: opaque background + the blur request --------------------------
if [[ -d $CONFIG/ghostty ]]; then
  mkdir -p "$(dirname "$GLASS_CSS")"
  if ! cmp -s "$SELF_DIR/glass.css" "$GLASS_CSS"; then
    cp -f "$SELF_DIR/glass.css" "$GLASS_CSS"
    say "updated $GLASS_CSS"
  fi

  if [[ -f $GHOSTTY_CONFIG ]]; then
    before=$(hash_of "$GHOSTTY_CONFIG")
    tmp=$(mktemp)
    sed "s|@GLASS_CSS@|$GLASS_CSS|g" "$SELF_DIR/ghostty.conf.snippet" >"$tmp"
    # Drop any previous/uncommented copies first; the managed block re-adds
    # exactly one of each.
    sed -i -E \
      -e '/^[[:space:]]*#?[[:space:]]*background-opacity[[:space:]]*=/d' \
      -e '/^[[:space:]]*#?[[:space:]]*gtk-custom-css[[:space:]]*=/d' \
      "$GHOSTTY_CONFIG"
    apply_block "$GHOSTTY_CONFIG" "$tmp" \
      "# >>> terminal-glass" "# <<< terminal-glass"
    rm -f "$tmp"
    [[ $(hash_of "$GHOSTTY_CONFIG") == "$before" ]] || {
      changed_ghostty=1
      say "pinned background-opacity = 1 in $GHOSTTY_CONFIG"
    }
  fi
fi

# --- Theme files ------------------------------------------------------------
# omarchy-theme-set-glass writes background-opacity = 0.65 *only when none is
# present*. With our opaque pin in every theme, it can never add its alpha.
pin_theme() {
  local file="$1"
  [[ -f $file ]] || return 0

  local before
  before=$(hash_of "$file")

  # Omarchy's glassy block may carry its own alpha and CSS import.
  sed -i '/^# omarchy-glass begin/,/^# omarchy-glass end$/d' "$file"
  sed -i -E '/^[[:space:]]*background-opacity[[:space:]]*=/d' "$file"
  apply_block "$file" "$SELF_DIR/theme-ghostty.conf.snippet" \
    "# >>> terminal-glass" "# <<< terminal-glass"

  [[ $(hash_of "$file") == "$before" ]] || {
    changed_theme=1
    say "pinned background-opacity = 1 in $file"
  }
}

pin_theme "$THEME_CURRENT/ghostty.conf"
if [[ -d $THEMES ]]; then
  shopt -s nullglob
  for file in "$THEMES"/*/ghostty.conf; do
    pin_theme "$file"
  done
  shopt -u nullglob
fi
pin_theme "$TEMPLATE"

# --- Keep this terminal-only ------------------------------------------------
# An earlier version of this installer also put a backdrop-filter into
# ~/.config/gtk-4.0/gtk.css, which made every GTK4 app (Nautilus, ...) request
# blur. The terminal's blur belongs in Ghostty's own gtk-custom-css only, so
# strip that block from the global stylesheet and leave other apps stock.
if [[ -f $GTK_CSS ]] && grep -q '>>> terminal-glass' "$GTK_CSS"; then
  before=$(hash_of "$GTK_CSS")
  python3 - "$GTK_CSS" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    src = fh.read()
src = re.sub(
    r"(?ms)/\* >>> terminal-glass.*?/\* <<< terminal-glass[^\n]*\n?", "", src
)
src = src.rstrip("\n") + "\n"
with open(path, "w", encoding="utf-8") as fh:
    fh.write(src)
PY
  [[ $(hash_of "$GTK_CSS") == "$before" ]] ||
    say "removed the global GTK blur from $GTK_CSS (terminal keeps its own)"
fi

# --- Apply live -------------------------------------------------------------
if (( RELOAD )); then
  if (( changed_hypr )) && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
    hyprctl reload >/dev/null 2>&1 ||
      say "warning: could not reload Hyprland; run: hyprctl reload" >&2
  fi
  # Ghostty reloads its config live on SIGUSR2.
  if (( changed_theme || changed_ghostty )) && pgrep -x ghostty >/dev/null 2>&1; then
    killall -SIGUSR2 ghostty >/dev/null 2>&1 || true
  fi
fi

exit 0
