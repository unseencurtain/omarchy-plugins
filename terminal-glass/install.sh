#!/usr/bin/env bash
# Install the terminal glass into ~/.config and wire up the re-assert hooks.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.config/omarchy/terminal-glass"
HOOKS="$HOME/.config/omarchy/hooks"

mkdir -p "$DEST" "$HOOKS/theme-set.d" "$HOOKS/post-update.d"

if [[ $DIR != "$DEST" ]]; then
  cp -a "$DIR"/. "$DEST"/
fi
chmod +x "$DEST/apply.sh" "$DEST/install.sh"

install -m755 "$DIR/hooks/reassert.sh" \
  "$HOOKS/theme-set.d/60-terminal-glass.sh"
install -m755 "$DIR/hooks/reassert.sh" \
  "$HOOKS/post-update.d/60-terminal-glass.sh"

"$DEST/apply.sh"

if pgrep -x ghostty >/dev/null 2>&1; then
  killall -SIGUSR2 ghostty >/dev/null 2>&1 || true
fi

cat <<'EOF'
terminal-glass installed:
  ~/.config/hypr/hyprland.lua                       authoritative block at EOF
  ~/.config/ghostty/config                          opaque background + blur request
  ~/.config/ghostty/glass.css                       GTK backdrop-filter request
  ~/.config/omarchy/themes/*/ghostty.conf           opaque pin in every theme
  ~/.config/omarchy/themed/ghostty.conf.tpl         opaque pin for generated themes
  ~/.config/omarchy/hooks/theme-set.d/60-terminal-glass.sh
  ~/.config/omarchy/hooks/post-update.d/60-terminal-glass.sh
EOF
