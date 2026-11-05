#!/usr/bin/env bash
# Called by both the theme-set and post-update hooks. `apply.sh` is idempotent,
# so running after a theme change or an omarchy update is always safe.
exec "$HOME/.config/omarchy/terminal-glass/apply.sh" --quiet
