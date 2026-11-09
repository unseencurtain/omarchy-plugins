# omarchy-plugins

Personal Omarchy bar plugins. These are forks of Omarchy's built-in bar widgets,
customised for a specific bar layout: smaller middle icons, a larger app-menu
logo, and per-widget sizes driven from a single `bar-sizes.json`.

## Plugins

| Plugin | Built from | What it changes |
| --- | --- | --- |
| `sine.indicators` | `omarchy.indicators` | Middle status icons scaled to `0.75`. Also bridges the indicator buttons (stay-awake, do-not-disturb, night-light) to Omarchy's services through the `IpcRegistry` singleton, because a cloned widget no longer gets a first-party shell facade. |
| `sine.elsewhen` | `omarchy.elsewhen` | World-clock globe icon scaled to `0.75` (installed but not placed on the bar). |
| `sine.system-update` | `omarchy.system-update` | Update icon scaled to `0.75`. |
| `sine.menu` | `omarchy.menu` | App-menu logo scaled to `1.25`. |

Each plugin's `manifest.json` records `omarchy.clonedFrom` so `omarchy` treats
them as local clones rather than the stock widgets.

## Terminal glass

`configs/terminal-glass/` is plain configuration — there is no `apply.sh`, no
hook, and nothing to re-assert. Copy the files into the configs that already
describe the desktop:

| File | Where |
| --- | --- |
| `configs/terminal-glass/terminal-glass.lua` | copy to `~/.config/hypr/terminal-glass.lua` |
| — | in `~/.config/hypr/hyprland.lua`, add `require("hypr.terminal-glass")` directly after `require("default.hypr.toggles")` |
| `configs/terminal-glass/ghostty.conf` | add its `config-file` line after the theme's `config-file` line in `~/.config/ghostty/config` |
| `configs/terminal-glass/glass.conf` | copy to `~/.config/ghostty/glass.conf` |
| `configs/terminal-glass/glass.css` | copy to `~/.config/ghostty/glass.css` |

`looknfeel.lua` stays untouched: it is still required with the other standard
user modules at the top of `hyprland.lua`. Only the order-sensitive glass
module is pulled in after the toggles.

Why static config is enough:

- **The glass module runs last.** `hyprland.lua` requires
  `hypr.terminal-glass` after `require("default.hypr.toggles")`, so the 0.75
  opacity rule and blur reset (`brightness`, `contrast`, `noise`, `vibrancy`,
  `xray`, `special`) win over Omarchy's `opaque`, `transparent`, and `glassy`
  toggles.
- **Ghostty loads `glass.conf` after the theme.** Included config files take
  effect after the file that names them, in the order listed. Naming
  `glass.conf` after the theme include means `background-opacity = 1` beats the
  theme's `0.65`, even after `omarchy-theme-set-glass` rewrites it. Theme files
  and the theme template need no pinning.
- **Only Ghostty changes.** `gtk-custom-css` points at
  `~/.config/ghostty/glass.css`; Ghostty alone requests the backdrop blur, so
  Nautilus and other GTK4 apps keep their stock look.

Reload with the normal tools, not an installer:

```sh
hyprctl reload
killall -SIGUSR2 ghostty   # Ghostty reloads its config live
```

## Per-monitor workspaces

`configs/workspaces/` replaces Omarchy 4.5's fixed ten-slot workspace blocks
with a layout you own. Hyprland workspace IDs are global, so each monitor gets a
contiguous range; the `star.workspaces` bar widget shows that monitor's range.

| File | Where |
| --- | --- |
| `configs/workspaces/monitors.lua` | merge into the sine block in `~/.config/hypr/monitors.lua` |
| `configs/workspaces/workspaces.lua` | merge into the sine block in `~/.config/hypr/workspaces.lua` |

Edit the table in `monitors.lua` to change counts:

```lua
local workspace_layout = {
  { monitor = "eDP-1", count = 6 },
  { monitor = "HDMI-A-1", count = 12 },
}
```

That gives the laptop `1–6` and the external `7–18`; the laptop bar shows `1–6`
and the external bar shows `7–18`. Add more rows for a third or fourth monitor.
The same file stops Omarchy's reconcile pass, so a reload no longer turns
workspace `4` into `14`. `workspaces.lua` keeps `Super+1..0` on the plain global
workspace IDs.

See [`configs/workspaces/README.md`](configs/workspaces/README.md) for the
details and the bar-widget setup.

## Install

```sh
git clone https://github.com/unseencurtain/omarchy-plugins.git
cd omarchy-plugins
./install.sh
```

`install.sh` copies each plugin into `~/.config/omarchy/plugins/` and
`bar-sizes.json` into `~/.config/omarchy/`. It deliberately does not touch the
terminal glass or the workspace layout: those files belong inside existing
config blocks, so place them by hand following `configs/terminal-glass/` and
`configs/workspaces/`.

Then place the widgets in the bar:

```sh
omarchy bar put sine.menu                          # left
omarchy bar put sine.indicators    --section centerBegin
omarchy bar put sine.system-update --section centerEnd
```

Restart the shell (`omarchy restart shell`) or the bar picks the new widgets up
on its next reload.

## Sizing

All sizes come from `~/.config/omarchy/bar-sizes.json`:

```json
{
  "indicators":   { "scale": 0.75 },
  "elsewhen":     { "scale": 0.75 },
  "systemUpdate": { "scale": 0.75 },
  "menu":         { "scale": 1.25 }
}
```

`scale` is a multiplier applied to the widget's glyph only; the bar slot keeps
its width, so icon spacing is unchanged. The file is watched live — save it and
the widgets update without a restart. Delete a section to fall back to the
widget's own `iconScale` setting, then to the theme default.

## Related plugins

These two live in their own repos and are expected to be installed separately:

- [`unseencurtain/star.workspaces`](https://github.com/unseencurtain/star.workspaces) — per-monitor workspaces, shown with their global IDs from the workspace rules; its `workspaces` section in `bar-sizes.json` sets `numberSize` and `glyphSize`.
- [`unseencurtain/unseencurtain.languages`](https://github.com/unseencurtain/unseencurtain.languages) — input-language switcher.

## Notes

- The cloned indicators read service state/toggles through `Commons.IpcRegistry`
  (`idle`, `nightlight`, `notifications` targets). If an Omarchy update renames
  those IPC targets or functions, only `sine.indicators` needs a touch-up; the
  other three are pure visual forks.
- Everything here lives under `~/.config`, so `omarchy update` (which rewrites
  `/usr/share`) does not remove it. The terminal glass is ordinary config, so an
  update cannot change it either, and there is no hook to keep in sync.
