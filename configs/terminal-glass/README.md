# Terminal glass: static config, no program

This is the terminal glass as plain configuration. There is no `apply.sh`, no
hook, and nothing to re-assert — the settings live in the config files that
already describe the desktop.

| File | Where |
| --- | --- |
| `terminal-glass.lua` | copy to `~/.config/hypr/terminal-glass.lua` |
| — | in `~/.config/hypr/hyprland.lua`, add `require("hypr.terminal-glass")` directly after `require("default.hypr.toggles")` |
| `ghostty.conf` | add its `config-file` line to `~/.config/ghostty/config`, directly after the theme's `config-file` line |
| `glass.conf` | copy to `~/.config/ghostty/glass.conf` |
| `glass.css` | copy to `~/.config/ghostty/glass.css` |

`looknfeel.lua` stays untouched: it is still required with the other standard
user modules at the top of `hyprland.lua`. Only the order-sensitive glass
module is pulled in after the toggles.

Why this is enough:

- **The glass module runs last.** Omarchy's opaque/transparent/glassy toggles
  are loaded by `require("default.hypr.toggles")`; requiring
  `hypr.terminal-glass` after that makes its 0.75 opacity rule and blur reset
  the final word.
- **Ghostty loads `glass.conf` after the theme.** Included config files take
  effect after the file that names them, in the order they are listed. Naming
  `glass.conf` after `~/.local/state/omarchy/current/theme/ghostty.conf` means
  `background-opacity = 1` beats the theme's `0.65`, even after
  `omarchy-theme-set-glass` rewrites it.
- **No theme pinning.** Theme files and the theme template need no
  `background-opacity` line.

Apply a change with the normal tools, not an installer:

```sh
hyprctl reload
killall -SIGUSR2 ghostty   # Ghostty reloads its config live
```
