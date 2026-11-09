# Per-monitor workspaces

Omarchy 4.5 gives every monitor a fixed block of ten workspaces and renumbers
occupied workspaces when it reconciles (`4` becomes `14` after a reload). This
config replaces that with a user-owned layout: pick a count per monitor, and
let the bar label each monitor's slots `1..N`.

Hyprland workspace IDs are global, so two monitors cannot both own workspace
`1`. Each monitor therefore gets a contiguous range, and the star.workspaces
bar widget translates its range back to local slot numbers.

## Files

| File | Where |
| --- | --- |
| `monitors.lua` | merge into the sine block in `~/.config/hypr/monitors.lua` |
| `workspaces.lua` | merge into the sine block in `~/.config/hypr/workspaces.lua` |

`monitors.lua` must be the file loaded early in `hyprland.lua` (with the other
standard user modules), not the sine block at the bottom. The reconcile guard
has to exist before `config.reloaded` fires.

## Layout

Edit the table in `monitors.lua`:

```lua
local workspace_layout = {
  { monitor = "eDP-1", count = 6 },
  { monitor = "HDMI-A-1", count = 12 },
}
```

This gives the laptop `1–6` and the external `7–18`. The external bar shows
`1–12`; the laptop bar shows `1–6`. Add another row for a third or fourth
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
`Super+Shift+Alt+1..0` to monitor-local slots. `Super+4` on the external goes
to slot 4 of the external, while `Super+4` on a three-slot laptop does nothing.
Slots above 10 are still clickable on the bar; add explicit binds if you want
them on the keyboard.

The stock Omarchy binds resolve slots against its own ten-slot blocks, so they
are replaced rather than supplemented.

## Bar labels

Install [`unseencurtain/star.workspaces`](https://github.com/unseencurtain/star.workspaces).
It reads `hyprctl workspacerules -j`, so this Lua table is the only place the
counts live. Each button's tooltip shows the real global Hyprland workspace ID.

The stock Omarchy workspaces widget would show the global IDs (`7–18`), not the
local slots (`1–12`).

## Reload

```sh
hyprctl reload
```

With the guard in place, occupied workspaces keep their IDs instead of being
renumbered. If Omarchy already renumbered them before you added the guard, it
will not move them back; move them back once and subsequent reloads are stable.
