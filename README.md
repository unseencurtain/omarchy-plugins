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

`terminal-glass/` restores the exact pre-update Ghostty glass and keeps it
immune to Omarchy's appearance modes:

- **Hyprland owns the look.** A marker-delimited block appended to the *end* of
  `~/.config/hypr/hyprland.lua` sets `opacity = "0.75 override 0.75 override"`
  for `com.mitchellh.ghostty` and resets every blur value Omarchy's
  `glass.lua` can change (`brightness`, `contrast`, `noise`, `vibrancy`,
  `xray`, `special`). Because it is last, `opaque`, `transparent`, and
  `glassy` toggles all reload into this block.
- **The background stays opaque.** Ghostty's `background-opacity` is pinned to
  `1` in the user config, the current theme, every
  `~/.config/omarchy/themes/*/ghostty.conf`, and the theme template.
  `omarchy-theme-set-glass` only writes its own `0.65` when no
  `background-opacity` line exists, so it can never add a second layer of
  transparency.
- **Only Ghostty changes.** `gtk-custom-css` points at
  `~/.config/ghostty/glass.css`; Ghostty alone requests the backdrop blur, so
  Nautilus and every other GTK4 app keep their stock look. `apply.sh` also
  strips the global `backdrop-filter` that an earlier version put in
  `~/.config/gtk-4.0/gtk.css`.
- **It re-asserts itself.** Two hooks call
  `~/.config/omarchy/terminal-glass/apply.sh`:

  | Hook | When |
  | --- | --- |
  | `theme-set.d/60-terminal-glass.sh` | after any `omarchy theme set` |
  | `post-update.d/60-terminal-glass.sh` | after every `omarchy update` |

  `apply.sh` is idempotent and only writes a file when its content actually
  differs, so running it by hand is always safe.

## Install

```sh
git clone https://github.com/unseencurtain/omarchy-plugins.git
cd omarchy-plugins
./install.sh
```

`install.sh` copies each plugin into `~/.config/omarchy/plugins/`,
`bar-sizes.json` into `~/.config/omarchy/`, and installs the terminal glass
(see above) into `~/.config/omarchy/terminal-glass/` with its two hooks. On a
brand-new Omarchy install this one command is therefore enough.

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

- [`unseencurtain/star.workspaces`](https://github.com/unseencurtain/star.workspaces) — workspace numbers/glyph; its `workspaces` section in `bar-sizes.json` sets `numberSize` and `glyphSize`.
- [`unseencurtain/unseencurtain.languages`](https://github.com/unseencurtain/unseencurtain.languages) — input-language switcher.

## Notes

- The cloned indicators read service state/toggles through `Commons.IpcRegistry`
  (`idle`, `nightlight`, `notifications` targets). If an Omarchy update renames
  those IPC targets or functions, only `sine.indicators` needs a touch-up; the
  other three are pure visual forks.
- Everything here lives under `~/.config`, so `omarchy update` (which rewrites
  `/usr/share`) does not remove it. The terminal glass additionally re-applies
  itself from `post-update.d`, so even an update that changes Omarchy's glass
  defaults cannot stick.
