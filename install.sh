#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS="$HOME/.config/omarchy/plugins"

for p in sine.indicators sine.elsewhen sine.menu sine.system-update; do
  src="$DIR/plugins/$p"
  [[ -d "$src" ]] || { echo "missing plugin: $src" >&2; exit 1; }
  rm -rf "$PLUGINS/$p"
  cp -r "$src" "$PLUGINS/$p"
  echo "installed $p -> $PLUGINS/$p"
done

cp "$DIR/bar-sizes.json" "$HOME/.config/omarchy/bar-sizes.json"
echo "installed bar-sizes.json -> $HOME/.config/omarchy/bar-sizes.json"

cat <<'EOF'

Done. Place the widgets in the bar (or add them from the shell settings):

  omarchy bar put sine.menu
  omarchy bar put sine.indicators    --section centerBegin
  omarchy bar put sine.elsewhen      --section centerEnd
  omarchy bar put sine.system-update --section centerEnd

Then restart the shell:

  omarchy restart shell
EOF
