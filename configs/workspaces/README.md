# Per-monitor workspaces

Omarchy 4.5 gives every monitor a fixed block of ten workspaces and renumbers
occupied workspaces when it reconciles (`4` becomes `14` after a reload). This
config replaces that with a user-owned layout: pick a count per monitor, and
each bar shows its monitor's global workspace IDs.

Hyprland workspace IDs are global, so two monitors cannot both own workspace
`1`. Each monitor therefore gets a contiguous range, and the star.workspaces
bar widget shows that range on its own bar.

## Files

| File | Where |
| --- | --- |
| `monitors.lua` | merge into the sine block in `~/.config/hypr/monitors.lua` |
| `workspaces.lua` | merge into the sine block in `~/.config/hypr/workspaces.lua` |

`~/.config/hypr/monitors.lua` must stay in the top require group of
`hyprland.lua` (with the other standard user modules), not be moved into the
sine block at the bottom. The reconcile guard has to exist before
`config.reloaded` fires.

## Layout

Edit the table in `monitors.lua`:

```lua
local workspace_layout = {
  { monitor = "eDP-1", count = 6 },
  { monitor = "HDMI-A-1", count = 12 },
}
```

This gives the laptop `1–6` and the external `7–18`. The laptop bar shows
`1–6`; the external bar shows `7–18`. Add another row for a third or fourth
monitor:

```lua
local workspace_layout = {
  { monitor = "eDP-1", count = 3 },
  { monitor = "HDMI-A-1", count = 6 },
  { monitor = "DP-1", count = 6 },
  { monitor = "DP-2", count = 6 },
}
```

The order of the table decides the global ranges. Use the connector names from
`hyprctl monitors`.

## Keybinds

`workspaces.lua` rebinds `Super+1..0`, `Super+Shift+1..0`, and
`Super+Shift+Alt+1..0` to the plain global workspace IDs. `Super+4` is always
workspace `4`, regardless of which monitor is focused.

Only ten number keys exist, so this covers workspace IDs `1–10`. Workspaces
above `10` stay clickable on the bar; add explicit binds if you want keyboard
access to them.

The stock Omarchy binds resolve numbers against its own ten-slot blocks, so they
are replaced rather than supplemented.

## Bar labels

Install [`unseencurtain/star.workspaces`](https://github.com/unseencurtain/star.workspaces).
It reads `hyprctl workspacerules -j`, so this Lua table is the only place the
counts live, and it shows the real global IDs (`1–6` on the laptop, `4–9` on the
external in the default three-and-six layout).

## Reload

```sh
hyprctl reload
```

With the guard in place, occupied workspaces keep their IDs instead of being
renumbered. If Omarchy already renumbered them before you added the guard, it
will not move them back; move them back once and subsequent reloads are stable.
